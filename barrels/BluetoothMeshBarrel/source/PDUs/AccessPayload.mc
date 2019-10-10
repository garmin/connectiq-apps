using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class AccessPayload {

        hidden var opcode;      // 1, 2 or 3 byte opcode                    1-3 Bytes       ByteArray
        hidden var parameters;  // parameters (up to 300 some bytes)        Variable        ByteArray

        function initialize(opcode, parameters) {
            self.opcode = opcode;
            self.parameters = parameters;
        }

        function getOpcode() {
            return self.opcode;
        }

        function getParameters() {
            return self.parameters;
        }

        function serialize() {
            var bytes = []b;
            bytes.addAll(opcode);
            bytes.addAll(parameters);
            return bytes;
        }

        function equals(object) {
            var equal = false;
            if (object instanceof AccessPayload) {
                equal = (object.getOpcode().equals(self.opcode) && object.getParameters().equals(self.parameters));
            }
            return equal;
        }

        static function decode(bytes) {
            var payload = null;
            if (bytes != null) {
                if ((bytes[0] >> 7) > 0) {
                    if ((bytes[0] >> 6) > 2) {
                        payload = new AccessPayload(bytes.slice(0, 3), bytes.slice(3, null));
                    } else {
                        payload = new AccessPayload(bytes.slice(0, 2), bytes.slice(2, null));
                    }
                } else {
                    payload = new AccessPayload([bytes[0]]b, bytes.slice(1, null));
                }
            }
            return payload;
        }
    }

}