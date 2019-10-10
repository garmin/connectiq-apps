using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    const ELEMENT_LOC = "loc";
    const ELEMENT_SIGID = "sigids";
    const ELEMENT_VENDID = "vendids";

    enum {
        FEATURE_RELAY,
        FEATURE_PROXY,
        FEATURE_FRIEND,
        FEATURE_LOW_POWER
    }

    class CompositionData {

        static const COMPOSITION_DATA_GET_OPCODE = [0x80, 0x08]b;
        static const COMPOSITION_DATA_STATUS_OPCODE = [0x02]b;

        private var company;
        private var elements;
        private var features;

        function initialize(company, features, elements) {
            self.company = company;
            self.features = features;
            self.elements = elements;
        }

        function getCompany() {
            return self.company;
        }

        function getCompanyString() {
            switch (self.company) {
                case 0x0059:
                    return "Nordic Semiconductor";
                default:
                    return "";
            }
        }

        function getFeatures() {
            var feats = [];
            for (var i = 0; i < 4; i++) {
                if ((self.features >> i) & 0x01 > 0) {
                    feats.add(i);
                }
            }
            return feats;
        }

        function getElements() {
            return self.elements;
        }

        static function getCompositionData() {
            return new AccessPayload(COMPOSITION_DATA_GET_OPCODE, [0x00]b);
        }

        static function decode(parameters) {
            var company = fromBytesLittleEndian(parameters, 1, 2);
            var features = fromBytesLittleEndian(parameters, 9, 2);
            var elements = [];
            var index = 11;
            while (index < parameters.size()) {
                var loc = fromBytesLittleEndian(parameters, index, 2);
                var numS = parameters[index + 2];
                var numV = parameters[index + 3];
                var sigIDs = [];
                var vendIDs = [];

                // parse the sig ids
                index += 4;
                var i = index;
                index += 2 * numS;
                while (i < index) {
                    sigIDs.add(fromBytesLittleEndian(parameters, i, 2));
                    i += 2;
                }

                index += 4 * numV;
                while (i < index) {
                    vendIDs.add(fromBytesLittleEndian(parameters, i, 4));
                    i += 4;
                }

                elements.add({ELEMENT_LOC => loc, ELEMENT_SIGID => sigIDs, ELEMENT_VENDID => vendIDs});
            }

            return new CompositionData(company, features, elements);
        }

    }

}