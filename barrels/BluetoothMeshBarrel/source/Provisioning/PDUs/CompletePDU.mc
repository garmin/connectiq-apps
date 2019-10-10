using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class CompletePDU extends ProvisioningPDU {

        function initialize() {
            ProvisioningPDU.initialize();
            self.type = PROV_COMPLETE;
        }

        static function decode(bytes) {
            return new CompletePDU();
        }

    }

}