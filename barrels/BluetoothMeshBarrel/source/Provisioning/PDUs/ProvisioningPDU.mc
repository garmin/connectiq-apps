using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    enum {
        PROV_INVITE,
        PROV_CAPABILITIES,
        PROV_START,
        PROV_PUBLIC_KEY,
        PROV_INPUT_COMPLETE,
        PROV_CONFIRMATION,
        PROV_RANDOM,
        PROV_DATA,
        PROV_COMPLETE,
        PROV_FAILED
    }

    class ProvisioningPDU {

        hidden var type;

        function getType() {
            return self.type;
        }

        function serialize() {
            System.println("Not supported by this type!");
        }

        static function decode(bytes) {
            switch (bytes[0]) {
                case PROV_CAPABILITIES:
                    return CapabilitiesPDU.decode(bytes);
                case PROV_PUBLIC_KEY:
                    return PublicKeyPDU.decode(bytes);
                case PROV_INPUT_COMPLETE:
                    return InputCompletePDU.decode(bytes);
                case PROV_CONFIRMATION:
                    return ConfirmationPDU.decode(bytes);
                case PROV_RANDOM:
                    return RandomPDU.decode(bytes);
                case PROV_FAILED:
                    return FailedPDU.decode(bytes);
                case PROV_COMPLETE:
                    return CompletePDU.decode(bytes);
                default:
                    System.println("Ha not supported yet fool");
                    System.println(hexString(bytes, null));
                    return null;
            }
        }

    }

}