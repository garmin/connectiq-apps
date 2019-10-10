using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class CapabilitiesPDU extends ProvisioningPDU {

        hidden var numberElements;
        hidden var algorithms;
        hidden var keyType;
        hidden var staticOobType;
        hidden var outputOobSize;
        hidden var outputOobAction;
        hidden var inputOobSize;
        hidden var inputOobAction;

        function initialize(numberElements, algorithms, keyType, staticOobType, outputOobSize, outputOobAction, inputOobSize, inputOobAction) {
            ProvisioningPDU.initialize();
            self.type = PROV_CAPABILITIES;
            self.numberElements = numberElements;
            self.algorithms = algorithms;
            self.keyType = keyType;
            self.staticOobType = staticOobType;
            self.outputOobSize = outputOobSize;
            self.outputOobAction = outputOobAction;
            self.inputOobSize = inputOobSize;
            self.inputOobAction = inputOobAction;
        }

        static function decode(bytes) {
            var numberElements = bytes[1];
            var algorithms = fromBytes(bytes, 2, 2);
            var keyType = bytes[4];
            var staticOobType = bytes[5];
            var outputOobSize = bytes[6];
            var outputOobAction = fromBytes(bytes, 7, 2);
            var inputOobSize = bytes[9];
            var inputOobAction = fromBytes(bytes, 10, 2);

            return new CapabilitiesPDU(numberElements, algorithms, keyType, staticOobType, outputOobSize, outputOobAction, inputOobSize, inputOobAction);
        }

        function getNumberOfElements() {
            return self.numberElements;
        }

        function getAlgorithms() {
            return self.algorithms;
        }

        function getKeyType() {
            return self.keyType;
        }

        function getStaticOobType() {
            return self.staticOobType;
        }

        function getOutputOobSize() {
            return self.outputOobSize;
        }

        function getOutputOobAction() {
            return self.outputOobAction;
        }

        function getInputOobSize() {
            return self.inputOobSize;
        }

        function getInputOobAction() {
            return self.inputOobAction;
        }

        function serialize() {
            var bytes = [self.type]b;
            bytes.add(self.numberElements);
            bytes.addAll(toBytes(self.algorithms, 2));
            bytes.add(self.keyType);
            bytes.add(self.staticOobType);
            bytes.add(self.outputOobSize);
            bytes.addAll(toBytes(self.outputOobAction, 2));
            bytes.add(self.inputOobSize);
            bytes.addAll(toBytes(self.inputOobAction, 2));
            return bytes;
        }

        function toString() {
            var output = "{";
            output += " type: " + self.type.toString();
            output += ", elements: " + self.numberElements.toString();
            output += ", algorithms: " + self.algorithms.toString();
            output += ", keyType: " + self.keyType.toString();
            output += ", staticOobType: " + self.staticOobType.toString();
            output += ", outputOobSize: " + self.outputOobSize.toString();
            output += ", outputOobAction: " + self.outputOobAction.toString();
            output += ", inputOobSize: " + self.inputOobSize.toString();
            output += ", inputOobAction: " + self.inputOobAction.toString();
            output += " }";
            return output;
        }


    }


}