using Toybox.System;
using Toybox.Lang;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application as App;
using Toybox.Timer;

module BluetoothMeshBarrel {

    // Bluetooth Mesh UUID constants
    const PROXY_SERVICE_UUID = Ble.stringToUuid("00001828-0000-1000-8000-00805F9B34FB");
    const PROXY_SERVICE_IN = Ble.stringToUuid("00002ADD-0000-1000-8000-00805F9B34FB");
    const PROXY_SERVICE_OUT = Ble.stringToUuid("00002ADE-0000-1000-8000-00805F9B34FB");
    const PROVISION_SERVICE_UUID = Ble.stringToUuid("00001827-0000-1000-8000-00805F9B34FB");
    const PROVISION_SERVICE_IN = Ble.stringToUuid("00002ADB-0000-1000-8000-00805F9B34FB");
    const PROVISION_SERVICE_OUT = Ble.stringToUuid("00002ADC-0000-1000-8000-00805F9B34FB");

    class NetworkManager {

        public var keyManager;
        public var callback;
        public var deviceManager;
        public var provisioningManager;

        private const IVI_STORAGE = "ivi";
        private const SEQ_STORAGE = "seq";
        private const ADDR_STORAGE = "addr";

        private var ivIndex = 0;        // Holds the current IV index of the network    Int
        private var seqNum = 0;         // Represents the current sequence number       Int
        private var address = 0x7fff;   // Holds the address of the sending device      Int

        private var timer = new Timer.Timer();
        private var timerRunning = false;
        private var queue = [];
        private var writeCharacteristic;
        private var readCharacteristic;
        private var numFailedWrites = 0;

        function initialize() {
            Ble.registerProfile({:uuid => PROXY_SERVICE_UUID, :characteristics => [{:uuid => PROXY_SERVICE_OUT,:descriptors => [Ble.cccdUuid()]}, {:uuid => PROXY_SERVICE_IN}]});
            Ble.registerProfile({:uuid => PROVISION_SERVICE_UUID,:characteristics => [{:uuid => PROVISION_SERVICE_OUT,:descriptors => [Ble.cccdUuid()]}, {:uuid => PROVISION_SERVICE_IN}]});
            self.deviceManager = new DeviceManager();
            self.provisioningManager = new ProvisioningManager(self);
            self.keyManager = new KeyManager();
        }

        // set the object to handle the callbacks
        function setCallback(callback) {
            self.callback = callback;
        }

        // save the current state
        function save() {
            App.Storage.setValue(ADDR_STORAGE, self.address);
            App.Storage.setValue(IVI_STORAGE, self.ivIndex);
            App.Storage.setValue(SEQ_STORAGE, self.seqNum);
            self.deviceManager.save();
            self.keyManager.saveKeys();
            System.println("Network manager state saved");
        }

        // load the saved states
        function load() {
            self.address = App.Storage.getValue(ADDR_STORAGE);
            if (self.address == null) { self.address = 0x7fff; }
            self.ivIndex = App.Storage.getValue(IVI_STORAGE);
            if (self.ivIndex == null) { self.ivIndex = 0x000000; }
            self.seqNum = App.Storage.getValue(SEQ_STORAGE);
            if (self.seqNum == null) { self.seqNum = 0x0000; }
            self.deviceManager.load();
            self.keyManager.loadKeys();
            System.println("Network manager state loaded");
        }

        // getter for the IV Index
        function getIvIndex() {
            return self.ivIndex;
        }

        // getter for the sequence number
        function getSequenceNumber() {
            return self.seqNum;
        }

        // getter for the address
        function getAddress() {
            return self.address;
        }

        // setter for the IV Index
        function setIvIndex(ivIndex) {
            self.ivIndex = ivIndex;
        }

        // setter for the sequence number
        function setSequenceNumber(seqNum) {
            self.seqNum = seqNum;
        }

        // update the sequence number after constructing a packet
        function incrementSequenceNumber() {
            self.seqNum += 1;
        }

        // setter for the local device address
        function setAddress(address) {
            self.address = address;
        }

        // setter for the characteristics to read/write from
        function setCharacteristics(read, write) {
            self.readCharacteristic = read;
            self.writeCharacteristic = write;
            TransportAccessPDU.reset();
            if (read != null) {
                self.readCharacteristic.getDescriptor(Ble.cccdUuid()).requestWrite([1, 0]b);
            }
        }

        // This is the function that handles incoming proxy packets. Pass in
        // raw data from the BLE onCharacteristic changed function
        function processProxyData(bytes) {
            var currentPacket = ProxyPDU.decode(bytes);
            if (currentPacket != null) {
                switch (currentPacket.getType()) {
                    case PROXY_TYPE_NETWORK_PDU:
                        var pdu = NetworkPDU.decrypt(self, currentPacket.getData());
                        if (pdu != null && isValidCallback() && self.callback.get() has :onNetworkPduReceived) {
                            self.callback.get().onNetworkPduReceived(pdu);
                        }
                        break;
                    case PROXY_TYPE_MESH_BEACON:
                        // non secure mesh beacon type is not supported
                        var beacon = MeshBeacon.decode(currentPacket.getData(), self.keyManager.getKey(0, BEACON_KEY));
                        if (beacon != null && beacon.type == BEACON_TYPE_SECURE) {
                            // this part here may need to be changed in the future.
                            // not sure how the secification treats iv updates that come
                            // from networks other than the primary network
                            if (self.keyManager.getKey(0, NETWORK_ID).equals(beacon.netId)) {
                                self.ivIndex = beacon.ivIndex;
                            }
                        }
                        break;
                    case PROXY_TYPE_PROVISION:
                        var provPdu = ProvisioningPDU.decode(currentPacket.getData());
                        if (provPdu != null && self.provisioningManager != null) {
                            self.provisioningManager.handleProvisioningPDU(provPdu);
                        }
                        break;
                    default:
                        System.println("Packet type invalid or not implemented yet!");
                        break;
                }
            }
        }

        // data is an array of byte arrays (segmented packets) to send to the connected devices
        function send(data) {
            if (self.writeCharacteristic != null) {
                queue.addAll(data);
                if (!self.timerRunning) {
                    timer.start(method(:handleQueue), 75, true);
                    self.timerRunning = true;
                }
            }
        }

        // this is the work function that sends the BLE packets
        function handleQueue() {
            if (self.queue.size() > 0) {
                var packet = self.queue[0];
                if (self.writeCharacteristic != null) {
                    try {
                        self.writeCharacteristic.requestWrite(packet, {:writeType => Ble.WRITE_TYPE_DEFAULT});
                        self.queue = self.queue.slice(1, null);
                        self.numFailedWrites = 0;
                    } catch (exception) {
                        // failed writes can occur when the device first connects. The device is in a 'busy' state
                        // where the GATT parameters are being worked out.
                        self.numFailedWrites++;
                        if (self.numFailedWrites > 20) {
                            self.timer.stop();
                            self.timerRunning = false;
                        } else if (self.numFailedWrites > 3) {
                            self.timer.stop();
                            self.timer.start(method(:handleQueue), 1000, true);
                        }
                    }
                }
            } else {
                self.timer.stop();
                self.timerRunning = false;
            }
        }

        // ******** PRIVATE FUNCTIONS ********* //

        private function isValidCallback() {
            return self.callback != null && self.callback.stillAlive() && self.callback.get() != null;
        }

    }

}
