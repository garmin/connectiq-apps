using Toybox.System;
using Toybox.Lang;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Timer;
using Toybox.Cryptography as Crypto;

module BluetoothMeshBarrel {

    enum {
        MODE_PROXY,
        MODE_PROVISION
    }

    class MeshDelegate extends Ble.BleDelegate {

        private var timer = new Timer.Timer();
        public var networkManager;

        hidden var scanResults = [];
        hidden var mode = null;
        hidden var device;
        hidden var currentPacket;
        hidden var connected = false;
        hidden var scanning = false;

        function initialize(networkManager) {
            BleDelegate.initialize();
            self.networkManager = networkManager;
            self.networkManager.setCallback(self.weak());
        }

        // start scanning for BLE devices. The mode specifies how advertising packets
        // are filtered out. MODE_PROXY will only provide results for proxy nodes (nodes
        // advertising the Mesh Proxy service) whiel MODE_PROVISION will only provide
        // results for nodes waiting to be provisioned
        function startScanning(mode) {
            self.disconnect();
            self.scanResults = [];
            Ble.setScanState(Ble.SCAN_STATE_SCANNING);
            // scan for five seconds
            timer.start(method(:timerDone), 5000, false);
            self.mode = mode;
            self.scanning = true;
        }

        // callback function for the timer
        function timerDone() {
            self.scanning = false;
            self.onScanFinished();
        }

        // helper function to see if a ScanResult has a specific service
        private function hasService(iterator, serviceUuid) {
            for (var uuid = iterator.next(); uuid != null; uuid = iterator.next()) {
                if (uuid.equals(serviceUuid)) {
                    return true;
                }
            }
            return false;
        }

        // overrides the superclass - filters the results
        function onScanResults(iterator) {
            for (var scanResult = iterator.next(); scanResult != null; scanResult = iterator.next()) {
                // find all unique devices that have the proxy or provision service
                var serviceUuid = null;
                if (self.mode == MODE_PROXY) {
                    serviceUuid = PROXY_SERVICE_UUID;
                } else if (self.mode == MODE_PROVISION) {
                    serviceUuid = PROVISION_SERVICE_UUID;
                }

                if (serviceUuid != null && hasService(scanResult.getServiceUuids(), serviceUuid)) {
                    var add = true;
                    for (var i = 0; i < self.scanResults.size(); i++) {
                        if (self.scanResults[i].isSameDevice(scanResult)) {
                            add = false;
                            break;
                        }
                    }
                    if (add) {
                        self.scanResults.add(scanResult);
                    }
                }
            }
        }

        // pairs with the device at the specified index of the scan results
        function connectToDevice(index) {
            self.disconnect();
            Ble.pairDevice(self.scanResults[index]);
            self.scanResults = [];
        }

        // unpair the current device
        function disconnect() {
            if (self.connected) {
                Ble.unpairDevice(self.device);
                self.device = null;
                self.connected = false;
                self.onDisconnected();
            }
        }

        // callback function for the BLE delegate (overrides superclass)
        function onConnectedStateChanged(device, state) {
            // if connected, send connection info to the network manager
            if (state == Ble.CONNECTION_STATE_CONNECTED && device != null) {
                self.device = device;
                var read = null;
                var write = null;
                if (self.mode == MODE_PROXY) {
                    var service = self.device.getService(PROXY_SERVICE_UUID);
                    if (service != null) {
                        read = service.getCharacteristic(PROXY_SERVICE_OUT);
                        write = service.getCharacteristic(PROXY_SERVICE_IN);
                    }
                } else if (self.mode == MODE_PROVISION) {
                    var service = device.getService(PROVISION_SERVICE_UUID);
                    if (service != null) {
                        read = service.getCharacteristic(PROVISION_SERVICE_OUT);
                        write = service.getCharacteristic(PROVISION_SERVICE_IN);
                    }
                }
                if (read != null && write != null) {
                    self.networkManager.setCharacteristics(read, write);
                    self.connected = true;
                    // if provisioning, start the process
                    if (self.mode == MODE_PROVISION) {
                        self.networkManager.provisioningManager.startProvisioning();
                    }
                    self.onConnected();
                }
            } else {  // clear the connection parameters
                if (device != null) {
                    Ble.unpairDevice(device);
                }
                self.device = null;
                self.connected = false;
                self.networkManager.setCharacteristics(null, null);
                self.onDisconnected();
            }
        }

        // callback function from the BLE Delegate. Accepts data, figures out what to do with it
        function onCharacteristicChanged(characteristic, value) {
            if (characteristic.getUuid().equals(PROXY_SERVICE_OUT) || characteristic.getUuid().equals(PROVISION_SERVICE_OUT)) {
                self.networkManager.processProxyData(value);
            }
        }

        function isConnected() {
            return self.connected;
        }

        function isScanning() {
            return self.scanning;
        }

        // clears all known data of the mesh network
        function deleteAllData() {
            self.networkManager.keyManager.clearKeys();
            self.networkManager.deviceManager.reset();
            self.networkManager.provisioningManager.reset();
            self.networkManager.save();
        }


        // *************** USER IMPLEMENTABLE FUNCTIONS ***************** //


        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onNetworkPduReceived(bytes) {

        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onScanFinished() {
            // use the connectToDevice(index) function and the
            // devices in the scanResults array to continue connecting
        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onConnected() {

        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onDisconnected() {

        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onProvisioningFailed(reason) {
            // default implementation:
            System.println("Provisioning failed");
        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onProvisioningParamsRequested(capabilities) {
            // default implementation:
            // FIPS P-256 Elliptic Curve with no OOB public key, output OOB auth (blink)
            // with maximum size specified by the device
            System.println("Warning: using default onProvisioningParamsRequested function");
            self.networkManager.provisioningManager.onProvisioningModeSelected(new StartPDU(0x00, 0x00, 0x00, 0x00, 0x00));
        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onAuthValueRequired() {
            System.println("Authentication value is required!");
            System.println("Override onAuthValueRequired() in MeshDelegate to prompt the user for the auth value");
            System.println("Use the onAuthValueCallback(authValue) method to continue the provisioning process");
        }

        // THIS IS A USER-OVERRIDEABLE FUNCTION
        function onProvisioningComplete(device) {

        }

    }

}