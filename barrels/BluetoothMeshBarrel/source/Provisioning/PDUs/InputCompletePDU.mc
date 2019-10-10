using Toybox.Lang;
using Toybox.System;

module BluetoothMeshBarrel {

    class InputCompletePDU extends ProvisioningPDU {

        function initialize() {
            ProvisioningPDU.initialize();
            self.type = PROV_INPUT_COMPLETE;
        }

        static function decode(bytes) {
            return new InputCompletePDU();
        }

    }

}