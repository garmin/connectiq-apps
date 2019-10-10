using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    enum {
        PROXY_SAR_COMPLETE,
        PROXY_SAR_FIRST,
        PROXY_SAR_CONTINUATION,
        PROXY_SAR_LAST
    }

    enum {
        PROXY_TYPE_NETWORK_PDU,
        PROXY_TYPE_MESH_BEACON,
        PROXY_TYPE_PROXY_CONFIG,
        PROXY_TYPE_PROVISION
    }

    class ProxyPDU {

        private static var currentPdu;

        private var sar;
        private var type;
        private var data;

        function initialize(sar, type, data) {
            self.sar = sar;
            self.type = type;
            self.data = data;
        }

        function getSar() {
            return self.sar;
        }

        function getType() {
            return self.type;
        }

        function getData() {
            return self.data;
        }

        function setSar(sar) {
            self.sar = sar;
        }

        function setType(type) {
            self.type = type;
        }

        function setData(data) {
            self.data = data;
        }

        function serialize() {
            var bytes = [(self.sar << 6) + self.type]b;
            bytes.addAll(self.data);
            return bytes;
        }

        static function decode(data) {
            var sar = (data[0] >> 6) & 0x03;
            var type = data[0] & 0x3f;
            var packet = null;
            switch (sar) {
                case PROXY_SAR_COMPLETE: /* INTENTIONAL FALLTHROUGH */
                case PROXY_SAR_FIRST:
                    currentPdu = new ProxyPDU(sar, type, data.slice(1, null));
                    break;
                case PROXY_SAR_CONTINUATION:
                case PROXY_SAR_LAST: /* INTENTIONAL FALLTHROUGH */
                    currentPdu.setSar(sar);
                    currentPdu.setType(type);
                    currentPdu.setData(currentPdu.getData().addAll(data.slice(1, null)));
                    break;
            }

            if (sar == PROXY_SAR_COMPLETE || sar == PROXY_SAR_LAST) {
                packet = new ProxyPDU(currentPdu.getSar(), currentPdu.getType(), currentPdu.getData());
                currentPdu = null;
            }
            return packet;
        }

        static function segment(type, data) {
            if (!(data instanceof Lang.Array)) {
                throw new Lang.UnexpectedTypeException();
            } else {
                if (data.size() > 0 && !(data[0] instanceof Lang.ByteArray)) {
                    throw new Lang.UnexpectedTypeException();
                }
            }
            var pdus = [];
            for (var i = 0; i < data.size(); i++) {
                if (data[i].size() > 19) {
                    for (var j = 0; j < data[i].size(); j += 19) {
                        var sar = null;
                        var segmented = null;
                        if (j == 0) {
                            sar = PROXY_SAR_FIRST;
                            segmented = data[i].slice(0, 19);
                        } else if (j + 19 < data[i].size()) {
                            sar = PROXY_SAR_CONTINUATION;
                            segmented = data[i].slice(j, j + 19);
                        } else {
                            sar = PROXY_SAR_LAST;
                            segmented = data[i].slice(j, null);
                        }
                        var pdu = new ProxyPDU(sar, type, segmented);
                        pdus.add(pdu.serialize());
                    }
                } else {
                    var pdu = new ProxyPDU(PROXY_SAR_COMPLETE, type, data[i]);
                    pdus.add(pdu.serialize());
                }
            }
            return pdus;
        }

    }

}