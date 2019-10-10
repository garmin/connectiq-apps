using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi as Ui;
using BluetoothMeshBarrel as Mesh;

class ControlDelegate extends Ui.BehaviorDelegate {

    static var currentPage = 0;
    var networkManager;

    function initialize(networkManager) {
        BehaviorDelegate.initialize();
        self.networkManager = networkManager;
        updateUi();
    }

    function onSelect() {
        // toggle or turn on the current device
        var address = deviceStates[currentPage][:address];
        var device;
        if (address >= 0xc000) {
            device = new Mesh.Device(address, 0, null, null, 0, [0]);
        } else {
            device = self.networkManager.deviceManager.getDevice(address);
        }
        switch(deviceStates[currentPage][:state]) {
            case STATE_OFF:
            case STATE_UNKNOWN: /* INTENTIONAL FALLTHROUGH */
                turnOn(device);
                if (address >= 0xc000) {
                    deviceStates[currentPage][:state] = STATE_ON;
                }
                deviceState = STATE_ON;
                break;
            case STATE_ON:
                // turn off
                turnOff(device);
                if (address >= 0xc000) {
                    deviceStates[currentPage][:state] = STATE_OFF;
                }
                deviceState = STATE_ON;
                break;
        }

        updateUi();
        return true;
    }

    function onNextPage() {
        // move the next selectable item
        currentPage += 1;
        if (currentPage >= deviceStates.size()) {
            currentPage = 0;
        }
        if (deviceStates[currentPage][:address] >= 0xc000) {
            deviceStates[currentPage][:state] = STATE_UNKNOWN;
        }
        updateUi();
        return true;
    }

    function onPreviousPage() {
        // move to the previous selectable item
        currentPage -= 1;
        if (currentPage < 0) {
            currentPage = deviceStates.size() - 1;
        }
        if (deviceStates[currentPage][:address] >= 0xc000) {
            deviceStates[currentPage][:state] = STATE_UNKNOWN;
        }
        updateUi();
        return true;
    }

    static function updateUi() {
        switch (deviceStates[currentPage][:address]) {
            // these groups are hard coded
            case 0xc000:
                deviceText = "Group A";
                break;
            case 0xc001:
                deviceText = "Group B";
                break;
            case 0xc002:
                deviceText = "Group C";
                break;
            default:
                deviceText = "Device " + deviceStates[currentPage][:address];
                break;
        }
        deviceState = deviceStates[currentPage][:state];
        Ui.requestUpdate();
    }

    function turnOn(device) {
        var packet = Mesh.GenericOnOff.setAcknowledged(self.networkManager, Mesh.GenericOnOff.ON, device);
        var segmented = Mesh.ProxyPDU.segment(Mesh.PROXY_TYPE_NETWORK_PDU, packet);
        self.networkManager.send(segmented);
    }

    function turnOff(device) {
        var packet = Mesh.GenericOnOff.setAcknowledged(self.networkManager, Mesh.GenericOnOff.OFF, device);
        var segmented = Mesh.ProxyPDU.segment(Mesh.PROXY_TYPE_NETWORK_PDU, packet);
        self.networkManager.send(segmented);
    }

}