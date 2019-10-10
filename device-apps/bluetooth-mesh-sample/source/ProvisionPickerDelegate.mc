using Toybox.System;
using Toybox.Lang;
using Toybox.WatchUi as Ui;

class ProvisionPickerDelegate extends Ui.PickerDelegate {

    hidden var networkManager;

    function initialize(networkManager) {
        PickerDelegate.initialize();
        self.networkManager = networkManager;
    }

    function onCancel() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

    function onAccept(values) {
        self.networkManager.provisioningManager.onAuthValueInput(values[0]);
        Ui.popView(Ui.SLIDE_IMMEDIATE);
    }

}