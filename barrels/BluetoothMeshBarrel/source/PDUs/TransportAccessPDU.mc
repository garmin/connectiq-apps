using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class TransportAccessPDU {

        private static var currentPdu = null;
        private static var firstSeq = null;
        private static var ack = 0;

        // Lower transport unsegmented access message fields:
        private var seg = false;
        private var segCount;
        private var segOffset;
        private var akf;        // Flag for whether application key is used to secure payload. 1 = appkey, 0 = devkey   1 bit       Boolean
        private var szmic;      // Flag indicating size of the MIC                                                      1 bit       Boolean (or null - defaults to false)
        private var payload;    // Payload to deliver                                                                   variable    AccessPayload type

        function initialize(akf, szmic, payload) {
            self.akf = akf;
            self.szmic = szmic;
            self.payload = payload;
        }

        function equals(object) {
            var equal = false;
            if (object instanceof TransportAccessPDU) {
                equal = object.getPayload().equals(self.payload);
            }
            return equal;
        }

        function getAkf() {
            return self.akf;
        }

        function getSzmic() {
            return self.szmic;
        }

        function getPayload() {
            return self.payload;
        }

        function getSegmentsCount() {
            return self.segCount;
        }

        function getCurrentSegment() {
            return self.segOffset;
        }

        function setPayload(payload) {
            self.payload = payload;
        }

        function setCurrentSegment(currentSegment) {
            self.segOffset = currentSegment;
        }

        function setSegmentCount(count) {
            self.segCount = count;
        }

        // this is one of the most important - if this field is false, then
        // all of the other getters for segment related things will return null.
        // So use this as a check before getting those fields.
        function isSegmented() {
            return self.seg;
        }

        function setSeg(seg) {
            self.seg = seg;
        }

        function isReassembled() {
            return self.segCount == self.segOffset;
        }

        // gets the encrypted packets that can be packaged up into network pdus and sent to the device
        // returns an Array of ByteArrays, each ByteArray is a separate lower transport pdu to send
        function encrypt(networkManager, dst) {
            var segmented = (self.payload.serialize().size() + 4 * self.szmic + 4) > 15;
            var key = null;
            var nonce = null;
            var aid = 0x00;
            if (self.akf) {
                // TODO: add a way to developers to specify which app key they want to use
                // TODO: add error handling in the case there are no keys bound yet
                key = networkManager.keyManager.getAppKey(0);
                aid = networkManager.keyManager.getAppID(0);
                nonce = [0x01, (segmented ? self.szmic : 0) << 7]b;
            } else {
                key = dst.getDeviceKey();
                nonce = [0x02, (segmented ? self.szmic : 0) << 7]b;
            }
            nonce.addAll(toBytes(networkManager.getSequenceNumber(), 3));
            nonce.addAll(toBytes(networkManager.getAddress(), 2));
            nonce.addAll(toBytes(dst.getAddress(), 2));
            nonce.addAll(toBytes(networkManager.getIvIndex(), 4));
            var encryptedPayload = aes_ccm_enc(key, payload.serialize(), nonce, self.szmic);
            var pdus = [];
            if (segmented) {
                var segments = (encryptedPayload.size() / 12) + (((encryptedPayload.size() % 12) == 0) ? -1 : 0);
                var seqZero = networkManager.getSequenceNumber() & 0x1FFF;
                for (var offset = 0; offset <= segments; offset++) {
                    var pdu = [(self.akf ? 0xC0 : 0x80) + aid]b;
                    pdu.add((self.szmic * 0x80) + ((seqZero >> 6) & 0x7f));
                    pdu.add(((seqZero & 0x3f) << 2) + ((offset >> 3) & 0x03));
                    pdu.add(((offset << 5) & 0xE0) + (segments & 0x1F));
                    if (offset != segments) {
                        pdu.addAll(encryptedPayload.slice(offset * 12, (offset + 1) * 12));
                    } else {
                        pdu.addAll(encryptedPayload.slice(offset * 12, null));
                    }
                    pdus.add(pdu);

                }
            } else {
                var pdu = [(self.akf ? 0x40 : 0x00) + aid]b;
                pdu.addAll(encryptedPayload);
                pdus.add(pdu);
            }
            return pdus;
        }

        // This makes the assumption that only one segmented packet is being received at a time
        // ie, cannot handle the case where two devices are sending segmented messages at the same time.
        // It could be fixed in the future by using the seqZero and src fields to see which message
        // the additional data belongs to.
        static function decrypt(networkManager, seqNum, src, dst, bytes) {
            // something is wrong here if greater than 16 bytes
            if (bytes.size() > 16) {
                throw new Lang.InvalidValueException();
            }

            var seg = (bytes[0] >> 7) > 0;
            var akf = ((bytes[0] >> 6) & 0x01) > 0;
            var szmic = MIC_SIZE_4;

            var packet = null;
            var key = null;
            var nonce = null;
            var aid = 0x00;

            if (akf) {
                key = networkManager.keyManager.getAppKey(0);
                aid = networkManager.keyManager.getAppID(0);
                nonce = [0x01, 0x00]b;
            } else {
                key = src.getDeviceKey();
                nonce = [0x02, 0x00]b;
            }

            if (seg) {
                if (firstSeq == null) {
                    firstSeq = seqNum;
                }
                nonce.addAll(toBytes(firstSeq, 3));
            } else {
                nonce.addAll(toBytes(seqNum, 3));
            }
            nonce.addAll(toBytes(src.getAddress(), 2));
            nonce.addAll(toBytes(dst, 2));
            nonce.addAll(toBytes(networkManager.getIvIndex(), 4));

            if ((bytes[0] & 0x3f) == aid) {
                if (!seg) {
                    var decryptedOutput = aes_ccm_dec(key, bytes.slice(1, null), nonce, szmic);
                    var payload = AccessPayload.decode(decryptedOutput);
                    if (payload != null) {
                        packet = new TransportAccessPDU(akf, szmic, payload);
                    }
                    currentPdu = null;
                    firstSeq = null;
                } else {
                    szmic = (bytes[1] >> 7) & 0x01;
                    var segmentedPayload = bytes.slice(4, null);
                    var seqZero = ((bytes[1] & 0x7f) << 6) + ((bytes[2]  & 0xfc) >> 2);
                    var offset = ((bytes[2] & 0x03) << 3) + ((bytes[3] & 0xe0) >> 5);
                    var segments = (bytes[3] & 0x1f);

                    nonce[2] = (szmic & 0x01) << 7;

                    // acknowledge the receipt of the segment
                    if (dst == networkManager.getAddress()) {
                        ack = ack | (0x01 << offset);
                        var packet = TransportControlPDU.getAcknowledgement(seqZero, ack);
                        var networkPdu = NetworkPDU.newInstance(networkManager, true, src, packet);
                        var segmented = ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkPdu.encrypt(networkManager));
                        networkManager.send(segmented);
                    }

                    if (offset == 0) {
                        currentPdu = new TransportAccessPDU(akf, szmic, segmentedPayload);
                        currentPdu.setSegmentCount(segments);
                        currentPdu.setCurrentSegment(offset);
                    } else if (currentPdu != null && offset == currentPdu.getCurrentSegment() + 1 && segments == currentPdu.getSegmentsCount()) {
                        currentPdu.setPayload(currentPdu.getPayload().addAll(segmentedPayload));
                        currentPdu.setCurrentSegment(offset);
                        if (offset == segments) {
                            var decryptedOutput = aes_ccm_dec(key, currentPdu.getPayload(), nonce, szmic);
                            if (decryptedOutput != null) {
                                var accessPayload = AccessPayload.decode(decryptedOutput);
                                packet = new TransportAccessPDU(currentPdu.getAkf(), currentPdu.getSzmic(), accessPayload);
                            } else {
                                System.println("fully reassembled but failed to decrypt");
                            }
                            currentPdu = null;
                            firstSeq = null;
                            ack = 0;
                        }
                    } else {
                        // in this case, the something is not right. Either we are receiving a new segmented transport message
                        // while still using the collector for an old (or different) pdu, or the segment received is not the
                        // next one in the sequence that is expected.
                        System.println("currentPdu is null: " + (currentPdu == null));
                        System.println("received seqZero: " + seqZero);
                        System.println("received offset: " + offset);
                        System.println("recieved segments: " + segments);
                        if (currentPdu != null) {
                            System.println("collector offset: " + currentPdu.getCurrentSegment());
                            System.println("collector segments: " + currentPdu.getSegmentsCount());
                        }
                        currentPdu = null;
                        firstSeq = null;
                        ack = 0;
                    }
                }
            }
            return packet;
        }

        public static function reset() {
            firstSeq = null;
            currentPdu = null;
        }
    }

}