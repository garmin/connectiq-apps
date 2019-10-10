using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class FailedPDU extends ProvisioningPDU {

        hidden var error;

        function initialize(error) {
            ProvisioningPDU.initialize();
            self.type = PROV_FAILED;
            self.error = error;
        }

        function toString() {
            switch (self.error) {
                case 0:
                    return "Prohibited";
                case 1:
                    return "Invalid Data";
                case 2:
                    return "Invalid Format";
                case 3:
                    return "Unexpected";
                case 4:
                    return "Auth Failed";
                case 5:
                    return "Out of Resources";
                case 6:
                    return "Decryption Failed";
                case 7:
                    return "Unexpected Error";
                case 8:
                    return "Cannot Assign Addresses";
                default:
                    return "Error :(";
            }
        }

        static function decode(bytes) {
            return new FailedPDU(bytes[1]);
        }

    }

}