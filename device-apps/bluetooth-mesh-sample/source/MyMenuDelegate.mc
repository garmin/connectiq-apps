using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi as Ui;
using BluetoothMeshBarrel as Mesh;

class MyMenuDelegate extends Ui.Menu2InputDelegate {

    private var mesh;

    function initialize(meshDelegate) {
        self.mesh = meshDelegate;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        var id = item.getId();
        if (id.find("main_menu") != null) {
            var idLen = id.length();
            var num = id.substring(10, idLen).toNumber();
            handleMainMenu(num);
        } else if (id.find("app_key_menu") != null) {
            var idLen = id.length();
            var num = id.substring(13, idLen).toNumber();
            handleAppKeyConfig(num);
        } else if (id.find("device_config") != null) {
            var idLen = id.length();
            var num = id.substring(14, idLen).toNumber();
            handleDeviceConfig(num);
        } else if (id.find("groups") != null) {
            var idLen = id.length();
            var num = id.substring(7, idLen).toNumber();
            self.mesh.configureGroup(num);
            Ui.popView(Ui.SLIDE_IMMEDIATE);
        } else if (id.find("provision") != null) {
            var idLen = id.length();
            var num = id.substring(10, idLen).toNumber();
            self.mesh.connectToDevice(num);
            Ui.popView(Ui.SLIDE_IMMEDIATE);
        }
    }

    private function handleMainMenu(id) {
        switch (id) {
            case 1:
                Ui.popView(Ui.SLIDE_IMMEDIATE);
                self.mesh.requestStatus(self.mesh.networkManager.deviceManager.getDevice(0x01));
                break;
            case 2:
                Ui.popView(Ui.SLIDE_IMMEDIATE);
                self.mesh.startScanning(Mesh.MODE_PROVISION);
                break;
            case 3:
                self.mesh.deleteAllData();
                self.mesh.networkManager.deviceManager.addGroup(0xc000);
                self.mesh.networkManager.deviceManager.addGroup(0xc001);
                self.mesh.networkManager.deviceManager.addGroup(0xc002);
                break;
            default:
                System.println("that isn't a valid main menu option!");
        }
    }

    private function handleAppKeyConfig(id) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        self.mesh.onAppKeySelected(id);
    }

    private function handleDeviceConfig(id) {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        self.mesh.configureDevice(id);
    }

}