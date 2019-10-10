using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi as Ui;
using BluetoothMeshBarrel as Mesh;

class BluetoothMeshDelegate extends Ui.BehaviorDelegate {

    private var mesh;

    function initialize(meshDelegate) {
        self.mesh = meshDelegate;
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new Ui.Menu2({:title=>"Bluetooth Mesh"});
        var delegate;
        menu.addItem(
            new Ui.MenuItem(
                "Provision device",
                "Add to network",
                "main_menu_2",
                null
            )
        );
        menu.addItem(
            new Ui.MenuItem(
                "Erase data",
                "(All of it)",
                "main_menu_3",
                null
            )
        );

        for (var i = 0; i < self.mesh.networkManager.deviceManager.deviceCount(); i++) {
            var address = self.mesh.networkManager.deviceManager.getAddresses()[i].toString();
            menu.addItem(
                new Ui.MenuItem(
                    "Configure device",
                    "Address: " + address,
                    "device_config_" + address,
                    null
                )
            );
        }

        Ui.pushView(menu, new MyMenuDelegate(self.mesh), Ui.SLIDE_LEFT);
        return true;
    }

    function onSelect() {
        if (!mesh.isConnected()) {
            mesh.startScanning(Mesh.MODE_PROXY);
        } else {
            Ui.pushView(new ControlView(), new ControlDelegate(self.mesh.networkManager), Ui.SLIDE_IMMEDIATE);
        }
        return true;
    }

}