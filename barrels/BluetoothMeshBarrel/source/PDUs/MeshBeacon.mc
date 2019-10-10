using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    enum {
        BEACON_TYPE_UNPROVISIONED,
        BEACON_TYPE_SECURE
    }

    class MeshBeacon {

        public var type;

        static function decode(bytes, beaconKey) {
            if (bytes[0] == BEACON_TYPE_SECURE) {
                return SecureMeshBeacon.decode(bytes, beaconKey);
            } else if (bytes[0] == BEACON_TYPE_UNPROVISIONED) {
                return new UnprovisionedDeviceBeacon();
            } else {
                throw new Lang.InvalidValueException();
            }
        }

    }

    class SecureMeshBeacon extends MeshBeacon {

        public var keyRefresh;
        public var ivUpdate;
        public var netId;
        public var ivIndex;

        function initialize(keyRefreshFlag, ivUpdateFlag, netId, ivIndex) {
            MeshBeacon.initialize();
            self.type = BEACON_TYPE_SECURE;
            self.keyRefresh = keyRefreshFlag;
            self.ivUpdate = ivUpdateFlag;
            self.netId = netId;
            self.ivIndex = ivIndex;
        }

        static function decode(bytes, beaconKey) {
            var keyRefresh = (bytes[1] & 0x01) > 0;
            var ivUpdate =  (bytes[1] & 0x02) > 0;
            var netId = bytes.slice(2, 10);
            var calcCmac = aes_cmac(bytes.slice(1, 14), beaconKey);
            var messageCmac = bytes.slice(-8, null);
            var beacon = null;
            if (messageCmac.equals(calcCmac.slice(0, 8))) {
                var ivIndex = fromBytes(bytes, 10, 4);
                beacon = new SecureMeshBeacon(keyRefresh, ivUpdate, netId, ivIndex);
            }
            return beacon;
        }

    }

    class UnprovisionedDeviceBeacon extends MeshBeacon {

        function initialize() {
            MeshBeacon.initialize();
            self.type = BEACON_TYPE_UNPROVISIONED;
        }

    }

}