using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class TransportControlPDU {

        private var opcode;
        private var parameters;

        // both opcode and parameters are ByteArrays
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
            bytes.addAll(self.opcode);
            bytes.addAll(self.parameters);
            return [bytes];
        }

        static function decode(bytes) {
            var opcode = bytes.slice(0, 1);
            var parameters = bytes.slice(1, null);
            return new TransportControlPDU(opcode, parameters);
        }

        static function getAcknowledgement(seqZero, blockAck) {
            var opcode = [0]b;
            var parameters = toBytes(((seqZero & 0x1fff)<< 2), 2);
            parameters.addAll(toBytes(blockAck, 4));
            return new TransportControlPDU(opcode, parameters);
        }

    }

}