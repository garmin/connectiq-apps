using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class ConfirmationPDU extends ProvisioningPDU {

        hidden var confirmation;

        function initialize(confirmation) {
            ProvisioningPDU.initialize();
            self.type = PROV_CONFIRMATION;
            self.confirmation = confirmation;
        }

        function getConfirmation() {
            return self.confirmation;
        }

        function serialize() {
            var bytes = [self.type]b;
            bytes.addAll(confirmation);
            return bytes;
        }

        static function decode(bytes) {
            return new ConfirmationPDU(bytes.slice(1, null));
        }

    }

}