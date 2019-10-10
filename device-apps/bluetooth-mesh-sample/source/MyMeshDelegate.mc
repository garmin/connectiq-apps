using Toybox.System;
using Toybox.Lang;
using BluetoothMeshBarrel as Mesh;
using Toybox.WatchUi as Ui;

var deviceStates = [];

class MyMeshDelegate extends Mesh.MeshDelegate {

    private var deviceToConfigure;

    private var count = 0;
    private var configShowGroups = true;

    // overrides
    function initialize(networkManager) {
        MeshDelegate.initialize(networkManager);
    }

    function onScanFinished() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        if (self.scanResults.size() > 0) {
            if (self.mode == MODE_PROXY) {
                var bestRssi = 0;
                for (var i = 1; i < self.scanResults.size(); i++) {
                    if (self.scanResults[i].getRssi() > self.scanResults[i].getRssi()) {
                        bestRssi = i;
                    }
                }
                connectToDevice(bestRssi);
            } else if (self.mode == MODE_PROVISION) {
                // present a list to the user?
                var menu = new Ui.Menu2({:title=>"Provision Device"});
                for (var i = 0; i < self.scanResults.size(); i++) {
                    menu.addItem(
                        new Ui.MenuItem(
                            self.scanResults[i].getDeviceName() != null ? self.scanResults[i].getDeviceName() : "Unnamed Device",
                            null,
                            "provision_" + i.toString(),
                            null
                        )
                    );
                }
                Ui.pushView(menu, new MyMenuDelegate(self), Ui.SLIDE_IMMEDIATE);
            }

        } else {
            errorText = "No devices found";
            Ui.requestUpdate();
        }
    }

    function startScanning(mode) {
        MeshDelegate.startScanning(mode);
        Ui.pushView(new Ui.ProgressBar("Scanning...", null), null, Ui.SLIDE_IMMEDIATE);
    }

    function onConnected() {
        infoText = "Connected";
        Ui.requestUpdate();
        if (self.mode == MODE_PROVISION) {
            Ui.pushView(new Ui.ProgressBar("Provisioning...", null), null, Ui.SLIDE_IMMEDIATE);
        } else if (self.mode == MODE_PROXY) {
            requestStatus(Mesh.Device.ALL_DEVICES);
        }
    }

    function onDisconnected() {
        infoText = "Disconnected";
        Ui.requestUpdate();
    }

    function requestStatus(device) {
         var packet = GenericOnOff.getStatus(self.networkManager, device);
         var segmented = Mesh.ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, packet);
         self.networkManager.send(segmented);
    }

    // networkPdu will never be null, always a NetworkPDU type
    function onNetworkPduReceived(networkPdu) {
        var transportPdu = networkPdu.getTransportPdu();
        if (!networkPdu.getCtl()) {
            var payload = transportPdu.getPayload();
            if (payload.getOpcode().equals(Mesh.GenericOnOff.GENERIC_ONOFF_STATUS_OPCODE)) {

                // find the device in deviceStates, if it exists
                var index = -1;
                for (var i = 0; i < deviceStates.size(); i++) {
                    if (deviceStates[i][:address] == networkPdu.getSrc().getAddress()) {
                        index = i;
                        break;
                    }
                }

                // update the device state or add if it doesn't exist
                if (index != -1) {
                    deviceStates[index][:state] = payload.getParameters()[0];
                } else {
                    deviceStates.add({:address => networkPdu.getSrc().getAddress(), :state => payload.getParameters()[0]});
                }
                ControlDelegate.updateUi();
            } else if (payload.getOpcode().equals(Mesh.CompositionData.COMPOSITION_DATA_STATUS_OPCODE)) {
                Ui.popView(Ui.SLIDE_IMMEDIATE);
                // now ask user for which app key to give the device
                var data = Mesh.CompositionData.decode(payload.getParameters());
                self.deviceToConfigure = networkPdu.getSrc();
                self.deviceToConfigure.setElements(data.getElements());

                // make a menu for choosing which app key to use
                var menu = new Ui.Menu2({:title=>"Bind AppKey"});
                var netKeyIndex = deviceToConfigure.getNetKeyIndex();
                for (var i = 0; i < self.networkManager.keyManager.getAppKeyCount(); i++) {
                    menu.addItem(new Ui.MenuItem("AppKey " + i.toString(), hexString(self.networkManager.keyManager.getAppKey(i), null), "app_key_menu_" + i.toString(), null));
                }
                Ui.pushView(menu, new MyMenuDelegate(self), Ui.SLIDE_IMMEDIATE);
                errorText = "Received composition data";
                Ui.requestUpdate();
            } else if (payload.getOpcode().equals(Mesh.AppKeyConfig.APP_KEY_CONFIG_STATUS_OPCODE)) {
                // bind the app key to the different elements
                var elements = self.deviceToConfigure.getElements();
                for (var i = 0; i < elements.size(); i++) {
                    for (var j = 0; j < elements[i][ELEMENT_SIGID].size(); j++) {
                        if (elements[i][ELEMENT_SIGID][j] == 0x1000 || elements[i][ELEMENT_SIGID][j] == 0x1001) {
                            var payload = Mesh.AppKeyConfig.getBindAppKeyConfig(i + self.deviceToConfigure.getAddress(), 0, elements[i][ELEMENT_SIGID][j]);
                            var transportPdu = new Mesh.TransportAccessPDU(false, MIC_SIZE_4, payload);
                            var networkPdu = Mesh.NetworkPDU.newInstance(self.networkManager, false, self.deviceToConfigure, transportPdu);
                            var segmented = Mesh.ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkPdu.encrypt(self.networkManager));
                            self.networkManager.send(segmented);
                        }
                    }
                }
            } else if (payload.getOpcode().equals(Mesh.AppKeyConfig.APP_KEY_CONFIG_BIND_STATUS_OPCODE)) {
                // two bind status packets are received, because two elements are configured. But we only want
                // to show the menu once, so use configShowGroups to limit when it is shown
                if (self.configShowGroups) {
                    Ui.popView(Ui.SLIDE_IMMEDIATE);
                    // create a menu to ask which groups to add the device to
                    var menu = new Ui.Menu2({:title => "Add Device to Groups"});
                    menu.addItem(new Ui.MenuItem("Group A", null, "groups_0", null));
                    menu.addItem(new Ui.MenuItem("Group B", null, "groups_1", null));
                    menu.addItem(new Ui.MenuItem("Group C", null, "groups_2", null));
                    Ui.pushView(menu, new MyMenuDelegate(self), Ui.SLIDE_IMMEDIATE);
                    errorText = "Received Bind Status";
                    Ui.requestUpdate();
                }
                // toggle configShowGroups, next time the menu will not be shown
                self.configShowGroups = !self.configShowGroups;
            } else if (payload.getOpcode().equals(Mesh.AppKeyConfig.PUBLISH_CONFIG_STATUS_OPCODE) ||
                       payload.getOpcode().equals(Mesh.AppKeyConfig.SUBSCRIPTION_STATUS_OPCODE)) {
                // do nothing, for now
            } else {
                System.println("Received an unknown network pdu");
                System.println("Opcode: " + hexString(payload.getOpcode(), null));
                System.println("Parameters: " + hexString(payload.getParameters(), null));
                errorText = "Received Network Pdu";
                Ui.requestUpdate();
            }
        }
    }

    function onProvisioningParamsRequested(capabilities) {
        self.networkManager.provisioningManager.onProvisioningModeSelected(new Mesh.StartPDU(0x00, 0x00, 0x02, 0x00, capabilities.getOutputOobSize()));
    }

    function onAppKeySelected(appKeyIndex) {
        var netKeyIndex = self.deviceToConfigure.getNetKeyIndex();
        var payload = Mesh.AppKeyConfig.getAddAppKeyConfig(netKeyIndex, appKeyIndex, self.networkManager.keyManager.getAppKey(appKeyIndex));
        var transportPdu = new Mesh.TransportAccessPDU(false, MIC_SIZE_4, payload);
        var networkPdu = Mesh.NetworkPDU.newInstance(self.networkManager, false, self.deviceToConfigure, transportPdu);
        var segmented = Mesh.ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkPdu.encrypt(self.networkManager));
        self.networkManager.send(segmented);
        self.deviceToConfigure.setAppKeyIndices(self.deviceToConfigure.getAppKeyIndices().add(appKeyIndex));
        Ui.pushView(new Ui.ProgressBar("Configuring...", null), null, Ui.SLIDE_IMMEDIATE);
    }

    function onAuthValueRequired() {
        var title = new Ui.Text({:text=>Rez.Strings.ProvisionPickerTitle, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});
        var factory = new NumberFactory(0, 5, 1, null);
        var picker = new Ui.Picker({:title=>title, :pattern=>[factory]});
        Ui.pushView(picker, new ProvisionPickerDelegate(self.networkManager), Ui.SLIDE_IMMEDIATE);
    }

    function configureGroup(id) {
        var elements = self.deviceToConfigure.getElements();
        for (var i = 0; i < elements.size(); i++) {
            for (var j = 0; j < elements[i][ELEMENT_SIGID].size(); j++) {
                if (elements[i][ELEMENT_SIGID][j] == 0x1000) {
                    var payload = Mesh.AppKeyConfig.getSubscribeAddConfig(i + self.deviceToConfigure.getAddress(), self.networkManager.deviceManager.getGroups()[id], 0x1000);
                    var transportPdu = new Mesh.TransportAccessPDU(false, MIC_SIZE_4, payload);
                    var networkPdu = Mesh.NetworkPDU.newInstance(self.networkManager, false, self.deviceToConfigure, transportPdu);
                    var segmented = Mesh.ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkPdu.encrypt(self.networkManager));
                    self.networkManager.send(segmented);
                } else if (elements[i][ELEMENT_SIGID][j] == 0x1001) {
                    var payload = Mesh.AppKeyConfig.getPublishAddConfig(i + self.deviceToConfigure.getAddress(), self.networkManager.deviceManager.getGroups()[id], 0x1001);
                    var transportPdu = new Mesh.TransportAccessPDU(false, MIC_SIZE_4, payload);
                    var networkPdu = Mesh.NetworkPDU.newInstance(self.networkManager, false, self.deviceToConfigure, transportPdu);
                    var segmented = Mesh.ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkPdu.encrypt(self.networkManager));
                    self.networkManager.send(segmented);
                }
            }
        }
    }

    function configureDevice(id) {
        self.deviceToConfigure = self.networkManager.deviceManager.getDevice(id);
        var compositionData = Mesh.CompositionData.getCompositionData();
        var transportPdu = new Mesh.TransportAccessPDU(false, MIC_SIZE_4, compositionData);
        var networkData = Mesh.NetworkPDU.newInstance(self.networkManager, false, self.deviceToConfigure, transportPdu).encrypt(self.networkManager);
        var segmented = Mesh.ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkData);
        self.networkManager.send(segmented);
        Ui.pushView(new Ui.ProgressBar("Configuring...", null), null, Ui.SLIDE_IMMEDIATE);
    }

    function onProvisioningFailed(reason) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        self.disconnect();
        errorText = "Error: " + reason;
        Ui.requestUpdate();
    }

    function onProvisioningComplete(device) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        self.disconnect();
        errorText = "Provision Complete!";
        deviceStates.add({:address => device.getAddress(), :state => STATE_UNKNOWN});
        Ui.requestUpdate();
        self.startScanning(MODE_PROXY);
    }

}