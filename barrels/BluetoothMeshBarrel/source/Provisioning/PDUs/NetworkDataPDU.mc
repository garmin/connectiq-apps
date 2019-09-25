using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class NetworkDataPDU extends ProvisioningPDU {

        hidden var encryptedData;

        function initialize(encryptedNetData) {
            ProvisioningPDU.initialize();
            self.type = PROV_DATA;
            self.encryptedData = encryptedNetData;
        }

        function serialize() {
            var bytes = [self.type]b;
            bytes.addAll(self.encryptedData);
            return bytes;
        }

    }

}