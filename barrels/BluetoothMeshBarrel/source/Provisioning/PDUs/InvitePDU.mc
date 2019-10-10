using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class InvitePDU extends ProvisioningPDU {

        hidden var duration;

        function initialize(duration) {
            ProvisioningPDU.initialize();
            self.type = PROV_INVITE;
            self.duration = duration;
        }

        function serialize() {
            return [self.type, self.duration]b;
        }

    }

}