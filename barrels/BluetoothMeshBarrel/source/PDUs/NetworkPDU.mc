using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {


    class NetworkPDU {

        private var ivi;                // Least significant bit of the IV index        1 Bit           Number
        private var nid;                // The nid field derived from netkey            7 Bits          Number
        private var ctl;                // Flag indicating whether is a control message 1 Bit           Boolean
        private var ttl;                // Time to live field                           7 Bits          Number
        private var seq;                // The sequence number of this NetPDU           3 Bytes         Number
        private var src;                // The source address                           2 Bytes         Number
        private var dst;                // The destination device/address               2 Bytes         Device
        private var transportPdu;       // The lower level transport data               1-16 Bytes      ByteArray
        private var netMic;             // The encryption MIC                           4-8 Bytes       ByteArray

        function initialize(ivi, nid, ctl, ttl, seq, src, dst, transportPdu) {
            self.ivi = ivi;
            self.nid = nid;
            self.ctl = ctl;
            self.ttl = ttl;
            self.seq = seq;
            self.src = src;
            self.dst = dst;
            self.transportPdu = transportPdu;
        }

        function getIvi() {
            return self.ivi;
        }

        function getNid() {
            return self.nid;
        }

        function getCtl() {
            return self.ctl;
        }

        function getTtl() {
            return self.ttl;
        }

        function getSeq() {
            return self.seq;
        }

        function getSrc() {
            return self.src;
        }

        function getDst() {
            return self.dst;
        }

        function getTransportPdu() {
            return self.transportPdu;
        }

        function equals(object) {
            if (!(object instanceof NetworkPDU)) { return false; }
            if (object.getIvi() != self.ivi) { return false; }
            if (object.getNid() != self.nid) { return false; }
            if (object.getCtl() != self.ctl) { return false; }
            if (object.getTtl() != self.ttl) { return false; }
            if (object.getSeq() != self.seq) { return false; }
            if (object.getSrc() != self.src) { return false; }
            if (object.getDst() != self.dst) { return false; }
            if (!object.getTransportPdu().equals(self.transportPdu)) { return false; }
            return true;
        }

        static function newInstance(networkManager, ctl, dst, transportPdu) {
            var ivi = networkManager.getIvIndex() & 0x00000001;
            var nid = networkManager.keyManager.getKey(dst.getNetKeyIndex(), NET_ID);
            var ttl = 0x04;
            var src = networkManager.getAddress();
            return new NetworkPDU(ivi, nid, ctl, ttl, 0, src, dst, transportPdu);
        }

        function encrypt(networkManager) {
            var pdus = [];
            var encTransportPdus = null;
            if (self.ctl) {
                encTransportPdus = self.transportPdu.serialize();
            } else {
                encTransportPdus = self.transportPdu.encrypt(networkManager, self.dst);
            }

            for (var i = 0; i < encTransportPdus.size(); i++) {
                // the maximum payload size is 16 bytes. If there is an instance where the
                // payload is greater than 16 bytes, there is probably something wrong
                // with the lower transport pdu encryption/segmentation algorithm
                if (encTransportPdus[i].size() > 16) {
                    throw new Lang.InvalidValueException();
                }

                var nonce = [0x00, (self.ctl ? 1 : 0) * 128 + self.ttl]b;
                nonce.addAll(toBytes(networkManager.getSequenceNumber(), 3));
                nonce.addAll(toBytes(self.src, 2));
                nonce.addAll([0x00, 0x00]b);
                nonce.addAll(toBytes(networkManager.getIvIndex(), 4));
                var encData = toBytes(self.dst.getAddress(), 2);
                encData.addAll(encTransportPdus[i]);
                var encrypted = aes_ccm_enc(networkManager.keyManager.getKey(self.dst.getNetKeyIndex(), ENCRYPTION_KEY), encData, nonce, self.ctl ? MIC_SIZE_8 : MIC_SIZE_4);

                var obfuscated = [(self.ctl ? 1 : 0) * 128 + self.ttl]b;
                obfuscated.addAll(toBytes(networkManager.getSequenceNumber(), 3));
                obfuscated.addAll(toBytes(self.src, 2));

                var privPlaintext = [0x00, 0x00, 0x00, 0x00, 0x00]b;
                privPlaintext.addAll(toBytes(networkManager.getIvIndex(), 4));
                privPlaintext.addAll(encrypted.slice(0, 7));
                var pecb = aes(networkManager.keyManager.getKey(self.dst.getNetKeyIndex(), PRIVACY_KEY), privPlaintext);

                for (var j = 0; j < obfuscated.size(); j++) {
                    obfuscated[j] ^= pecb[j];
                }

                var bytes = [self.ivi * 128 + self.nid]b;
                bytes.addAll(obfuscated);
                bytes.addAll(encrypted);

                pdus.add(bytes);
                networkManager.incrementSequenceNumber();
            }

            return pdus;
        }

        static function decrypt(networkManager, bytes) {
            var ivi = bytes[0] >> 7;
            var nid = bytes[0] & 0x7f;
            var unobfuscated = bytes.slice(1, 7);
            var privPlaintext = [0x00, 0x00, 0x00, 0x00, 0x00]b;
            privPlaintext.addAll(toBytes(networkManager.getIvIndex(), 4));
            privPlaintext.addAll(bytes.slice(7, 14));
            var netKeyIndex = networkManager.keyManager.getNetKeyIndex(nid);
            var pecb = aes(networkManager.keyManager.getKey(netKeyIndex, PRIVACY_KEY), privPlaintext);
            for (var i = 0; i < unobfuscated.size(); i++) {
                unobfuscated[i] ^= pecb[i];
            }
            var ctl = (unobfuscated[0] >> 7) > 0;
            var ttl = unobfuscated[0] & 0x7f;
            var seq = fromBytes(unobfuscated, 1, 3);
            var src = fromBytes(unobfuscated, 4, 2);
            src = networkManager.deviceManager.getDevice(src);

            var packet = null;
            if (src != null) {
                var nonce = [0x00, (ctl ? 1 : 0) * 128 + ttl]b;
                nonce.addAll(toBytes(seq, 3));
                nonce.addAll(toBytes(src.getAddress(), 2));
                nonce.addAll([0x00, 0x00]b);
                nonce.addAll(toBytes(networkManager.getIvIndex(), 4));

                var decrypted = aes_ccm_dec(networkManager.keyManager.getKey(src.getNetKeyIndex(), ENCRYPTION_KEY), bytes.slice(7, null), nonce, ctl ? MIC_SIZE_8 : MIC_SIZE_4);

                if (decrypted != null) {
                    var dst = fromBytes(decrypted, 0, 2);
                    var transportPdu = ctl ? TransportControlPDU.decode(decrypted.slice(2, null)) : TransportAccessPDU.decrypt(networkManager, seq, src, dst, decrypted.slice(2, null));
                    if (transportPdu != null) {
                        packet = new NetworkPDU(ivi, nid, ctl, ttl, seq, src, dst, transportPdu);
                    }
                }
            } else {
                System.println("Receieved packet from unknown device with address " + fromBytes(unobfuscated, 4, 2) + ", cannot decrypt");
            }
            return packet;
        }

    }

}