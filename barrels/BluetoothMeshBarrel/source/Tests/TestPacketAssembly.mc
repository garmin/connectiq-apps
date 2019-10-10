module BluetoothMeshBarrel {

    // because these test cases come from the bluetooth spec
    // examples, there are a few things that you need to do
    // before running this test in order for it to pass:
    // - change the address in NetworkManager.mc to 0x0003
    // - change the default ttl in NetworkPDU.mc to 0x04 (in the newInstance function)
    // - comment out the Ble.registerProfile calls in NetworkManager.mc

    (:test)
    function test_PacketAssembly(logger) {
        var pass = true;
        var payload = null;
        var transportPdu = null;
        var networkPdu = null;

        var networkManager = new NetworkManager();
        networkManager.setIvIndex(0x12345678);
        networkManager.setSequenceNumber(0x3129ab);
        networkManager.keyManager.addNetKey([0x7d, 0xd7, 0x36, 0x4c, 0xd8, 0x42, 0xad, 0x18, 0xc1, 0x7c, 0x2b, 0x82, 0x0c, 0x84, 0xc3, 0xd6]b);
        networkManager.keyManager.addAppKey(0, [0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b);
        networkManager.deviceManager.addDevice(new Device(0x1201, 2, [], [0x9d, 0x6d, 0xd0, 0xe9, 0x6e, 0xb2, 0x5d, 0xc1, 0x9a, 0x40, 0xed, 0x99, 0x14, 0xf8, 0xf0, 0x3f]b, 0, []));

        // test the access payload and serialization
        if (pass) {
            var opcode = [0x00]b;
            var parameters = [0x56, 0x34, 0x12, 0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b;
            payload = new AccessPayload(opcode, parameters);

            pass = pass && payload.serialize().equals([0x00, 0x56, 0x34, 0x12, 0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b);

            if (!pass) {
                logger.debug("serialized payload = " + hexString(payload.serialize(), null));
                logger.debug("expected payload = " + hexString([0x00, 0x56, 0x34, 0x12, 0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b, null));
                logger.error("Failed to properly serialize the access payload");
            }
        }

        // test the access transport pdu and encryption
        if (pass) {
            transportPdu = new TransportAccessPDU(false, MIC_SIZE_4, payload);
            var expected = [[0x80, 0x26, 0xac, 0x01, 0xee, 0x9d, 0xdd, 0xfd, 0x21, 0x69, 0x32, 0x6d, 0x23, 0xf3, 0xaf, 0xdf]b, [0x80, 0x26, 0xac, 0x21, 0xcf, 0xdc, 0x18, 0xc5, 0x2f, 0xde, 0xf7, 0x72, 0xe0, 0xe1, 0x73, 0x08]b];
            var segments = transportPdu.encrypt(networkManager, networkManager.deviceManager.getDevice(0x1201));

            for (var i = 0; i < expected.size(); i++) {
                pass = pass && expected[i].equals(segments[i]);
                if (!pass) {
                    logger.error("failed to correctly generate the lower transport pdu - segment " + i.toString());
                    break;
                }
            }

            if (!pass) {
                logger.debug("the resulting lower transport pdus are: ");
                for (var i = 0; i < segments.size(); i++) {
                    logger.debug(hexString(segments[i], null));
                }
                logger.debug("the expected lower transport pdus are: ");
                for (var i = 0; i < expected.size(); i++) {
                    logger.debug(hexString(expected[i], null));
                }
            }
        }

        // test the network pdu and encryption
        if (pass) {
            networkPdu = NetworkPDU.newInstance(networkManager, false, networkManager.deviceManager.getDevice(0x1201), transportPdu);
            var expected = [[0x68, 0xca, 0xb5, 0xc5, 0x34, 0x8a, 0x23, 0x0a, 0xfb, 0xa8, 0xc6, 0x3d, 0x4e, 0x68, 0x63, 0x64, 0x97, 0x9d, 0xea, 0xf4, 0xfd, 0x40, 0x96, 0x11, 0x45, 0x93, 0x9c, 0xda, 0x0e]b, [0x68, 0x16, 0x15, 0xb5, 0xdd, 0x4a, 0x84, 0x6c, 0xae, 0x0c, 0x03, 0x2b, 0xf0, 0x74, 0x6f, 0x44, 0xf1, 0xb8, 0xcc, 0x8c, 0xe5, 0xed, 0xc5, 0x7e, 0x55, 0xbe, 0xed, 0x49, 0xc0]b];
            var segments = networkPdu.encrypt(networkManager);

            for (var i = 0; i < expected.size(); i++) {
                pass = pass && expected[i].equals(segments[i]);
                if (!pass) {
                    logger.error("failed to correctly generate the network pdu - segment " + i.toString());
                    break;
                }
            }

            if (!pass) {
                logger.debug("the resulting encrypted network pdus are: ");
                for (var i = 0; i < segments.size(); i++) {
                    logger.debug(hexString(segments[i], null));
                }
                logger.debug("the expected encrypted network pdus are: ");
                for (var i = 0; i < expected.size(); i++) {
                    logger.debug(hexString(expected[i], null));
                }
            }
        }

        // test the proxy pdu asssembly - note, not in the bluetooth spec examples. expected value is hand coded by me
        if (pass) {
            var expected = [[0x40, 0x68, 0xca, 0xb5, 0xc5, 0x34, 0x8a, 0x23, 0x0a, 0xfb, 0xa8, 0xc6, 0x3d, 0x4e, 0x68, 0x63, 0x64, 0x97, 0x9d, 0xea]b,
                            [0xc0, 0xf4, 0xfd, 0x40, 0x96, 0x11, 0x45, 0x93, 0x9c, 0xda, 0x0e]b,
                            [0x40, 0x68, 0x16, 0x15, 0xb5, 0xdd, 0x4a, 0x84, 0x6c, 0xae, 0x0c, 0x03, 0x2b, 0xf0, 0x74, 0x6f, 0x44, 0xf1, 0xb8, 0xcc]b,
                            [0xc0, 0x8c, 0xe5, 0xed, 0xc5, 0x7e, 0x55, 0xbe, 0xed, 0x49, 0xc0]b];
            networkManager.setSequenceNumber(0x3129ab);
            var segments = ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, networkPdu.encrypt(networkManager));

            for (var i = 0; i < expected.size(); i++) {
                pass = pass && expected[i].equals(segments[i]);
                if (!pass) {
                    logger.error("failed to correctly generate the proxy pdu - segment " + i.toString());
                    break;
                }
            }

            if (!pass) {
                logger.debug("the resulting segmented proxy pdus are: ");
                for (var i = 0; i < segments.size(); i++) {
                    logger.debug(hexString(segments[i], null));
                }
                logger.debug("the expected segmented proxy pdus are: ");
                for (var i = 0; i < expected.size(); i++) {
                    logger.debug(hexString(expected[i], null));
                }
            }
        }

        return pass;

    }

}