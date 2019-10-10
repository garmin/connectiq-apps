using Toybox.Application;
using Toybox.Lang;
using BluetoothMeshBarrel as Mesh;
using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Timer;
using Toybox.WatchUi as Ui;

using Toybox.Cryptography as Crypto;

class BluetoothMeshApp extends Application.AppBase {

    hidden var networkManager;
    hidden var meshDelegate;

    function initialize() {
        AppBase.initialize();
        self.networkManager = new Mesh.NetworkManager();
        self.networkManager.load();
        if (self.networkManager.keyManager.getNetKeyCount() == 0) {
            self.networkManager.keyManager.clearKeys();
            self.networkManager.keyManager.addNetKey([0x54, 0x58, 0xd9, 0x7b, 0xfc, 0x39, 0x96, 0x68, 0xf6, 0x22, 0x37, 0x6c, 0xf9, 0xf7, 0xbe, 0x0b]b);
            self.networkManager.keyManager.addAppKey([0xd7, 0x8e, 0xba, 0x44, 0x60, 0xdf, 0xef, 0x93, 0x9c, 0x73, 0x2a, 0xc4, 0x38, 0xe3, 0x68, 0x19]b);
            self.networkManager.deviceManager.reset();
            self.networkManager.deviceManager.addGroup(0xc000);
            self.networkManager.deviceManager.addGroup(0xc001);
            self.networkManager.deviceManager.addGroup(0xc002);
            self.networkManager.setIvIndex(0x0000);
            self.networkManager.setSequenceNumber(0x0001);
        }

        self.meshDelegate = new MyMeshDelegate(self.networkManager);

        var addresses = self.networkManager.deviceManager.getAddresses();
        for (var i = 0; i < addresses.size(); i++) {
            deviceStates.add({:address => addresses[i], :state => STATE_UNKNOWN});
        }
        for (var i = 0; i < self.networkManager.deviceManager.getGroups().size(); i++) {
            deviceStates.add({:address => self.networkManager.deviceManager.getGroups()[i], :state => STATE_UNKNOWN});
        }
    }

    // onStart() is called on application start up
    function onStart(state) {
        Ble.setDelegate(self.meshDelegate);
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        self.networkManager.save();
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new BluetoothMeshView(self.meshDelegate), new BluetoothMeshDelegate(self.meshDelegate) ];
    }

}