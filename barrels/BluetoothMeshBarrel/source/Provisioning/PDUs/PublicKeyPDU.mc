using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class PublicKeyPDU extends ProvisioningPDU {

        hidden var key;

        function initialize(key) {
            ProvisioningPDU.initialize();
            self.type = PROV_PUBLIC_KEY;
            self.key = key;
        }

        function getKey() {
            return self.key;
        }

        function serialize() {
            var bytes = [self.type]b;
            bytes.addAll(self.key);
            return bytes;
        }

        static function decode(bytes) {
            // the first byte is the type
            var key = bytes.slice(1, null);
            return new PublicKeyPDU(key);
        }

    }

}