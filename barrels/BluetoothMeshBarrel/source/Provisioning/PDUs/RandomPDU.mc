using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class RandomPDU extends ProvisioningPDU {

        hidden var random;

        function initialize(random) {
            ProvisioningPDU.initialize();
            self.type = PROV_RANDOM;
            self.random = random;
        }

        function getRandom() {
            return self.random;
        }

        function serialize() {
            var bytes = [self.type]b;
            bytes.addAll(self.random);
            return bytes;
        }

        static function decode(bytes) {
            return new RandomPDU(bytes.slice(1, null));
        }

    }

}