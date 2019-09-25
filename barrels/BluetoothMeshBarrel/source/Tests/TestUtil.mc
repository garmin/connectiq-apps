using Toybox.Test;
using Toybox.System;
using Toybox.Cryptography as Crypto;

module BluetoothMeshBarrel {

    (:test)
    function test_cryptography_util(logger) {
        var pass = true;

        // test the s1 salt function
        if (pass) {
            var expected = [0xb7, 0x3c, 0xef, 0xbd, 0x64, 0x1e, 0xf2, 0xea, 0x59, 0x8c, 0x2b, 0x6e, 0xfb, 0x62, 0xf7, 0x9c]b;
            var input = ['t', 'e', 's', 't']b;
            var actual = s1(input);

            pass = pass && actual.equals(expected);

            if (!pass) {
                logger.debug("salt = " + hexString(actual, null));
                logger.debug("expected = " + hexString(expected, null));
                logger.error("s1 salt function did not generate the expected output");
            }
        }

        // test the k1 function
        if (pass) {
            var expected = [0xf6, 0xed, 0x15, 0xa8, 0x93, 0x4a, 0xfb, 0xe7, 0xd8, 0x3e, 0x8d, 0xcb, 0x57, 0xfc, 0xf5, 0xd7]b;
            var N = [0x32, 0x16, 0xd1, 0x50, 0x98, 0x84, 0xb5, 0x33, 0x24, 0x85, 0x41, 0x79, 0x2b, 0x87, 0x7f, 0x98]b;
            var salt = [0x2b, 0xa1, 0x4f, 0xfa, 0x0d, 0xf8, 0x4a, 0x28, 0x31, 0x93, 0x8d, 0x57, 0xd2, 0x76, 0xca, 0xb4]b;
            var P = [0x5a, 0x09, 0xd6, 0x07, 0x97, 0xee, 0xb4, 0x47, 0x8a, 0xad, 0xa5, 0x9d, 0xb3, 0x35, 0x2a, 0x0d]b;
            var actual = k1(N, salt, P);

            pass = pass && actual.equals(expected);

            if (!pass) {
                logger.debug("k1 = " + hexString(actual, null));
                logger.debug("expected = " + hexString(expected, null));
                logger.error("k1 function failed to generate the expected output");
            }
        }

        // test the k2 function
        if (pass) {
            var expected_nid = 0x7f;
            var expected_encryption_key = [0x9f, 0x58, 0x91, 0x81, 0xa0, 0xf5, 0x0d, 0xe7, 0x3c, 0x80, 0x70, 0xc7, 0xa6, 0xd2, 0x7f, 0x46]b;
            var expected_privacy_key = [0x4c, 0x71, 0x5b, 0xd4, 0xa6, 0x4b, 0x93, 0x8f, 0x99, 0xb4, 0x53, 0x35, 0x16, 0x53, 0x12, 0x4f]b;
            var N = [0xf7, 0xa2, 0xa4, 0x4f, 0x8e, 0x8a, 0x80, 0x29, 0x06, 0x4f, 0x17, 0x3d, 0xdc, 0x1e, 0x2b, 0x00]b;
            var P = [0x00]b;
            var output = k2(N, P);
            var test_nid = output[0];
            var test_encryption_key = output.slice(1, 17);
            var test_privacy_key = output.slice(17, null);

            pass = pass && expected_nid == test_nid && expected_encryption_key.equals(test_encryption_key) && expected_privacy_key.equals(test_privacy_key);

            if (!pass) {
                logger.debug("test_nid = " + test_nid);
                logger.debug("expected_nid = " + expected_nid);
                logger.debug("test_encryption_key = " + hexString(test_encryption_key, null));
                logger.debug("expected_encryption_key = " + hexString(expected_encryption_key, null));
                logger.debug("test_privacy_key = " + hexString(test_privacy_key, null));
                logger.debug("expected_privacy_key = " + hexString(expected_privacy_key, null));
                logger.error("k2 function failed to generate the expected output");
            }
        }

        // test the k3 function
        if (pass) {
            var expected = [0xff, 0x04, 0x69, 0x58, 0x23, 0x3d, 0xb0, 0x14]b;
            var N = [0xf7, 0xa2, 0xa4, 0x4f, 0x8e, 0x8a, 0x80, 0x29, 0x06, 0x4f, 0x17, 0x3d, 0xdc, 0x1e, 0x2b, 0x00]b;
            var actual = k3(N);

            pass = pass && actual.equals(expected);

            if (!pass) {
                logger.debug("k3 = " + hexString(actual, null));
                logger.debug("expected = " + hexString(expected, null));
                logger.error("k3 function failed to generate the expected output");
            }
        }

        // test the k4 function
        if (pass) {
            var expected = 0x38;
            var N = [0x32, 0x16, 0xd1, 0x50, 0x98, 0x84, 0xb5, 0x33, 0x24, 0x85, 0x41, 0x79, 0x2b, 0x87, 0x7f, 0x98]b;
            var actual = k4(N);

            pass = pass && expected == actual;

            if (!pass) {
                logger.debug("k4 = " + actual);
                logger.debug("expected = " + expected);
                logger.error("k4 function failed to generate the expected output");
            }
        }

        // test the AES-CCM encryption function
        if (pass) {
            var expected = [0x56, 0x73, 0x72, 0x8a, 0x62, 0x7f, 0xb9, 0x38, 0x53, 0x55, 0x08, 0xe2, 0x1a, 0x6b, 0xaf, 0x57]b;
            var data = [0xff, 0xff, 0x66, 0x5a, 0x8b, 0xde, 0x6d, 0x91, 0x06, 0xea, 0x07, 0x8a]b;
            var key = [0x09, 0x53, 0xfa, 0x93, 0xe7, 0xca, 0xac, 0x96, 0x38, 0xf5, 0x88, 0x20, 0x22, 0x0a, 0x39, 0x8e]b;
            var nonce = [0x00, 0x03, 0x00, 0x00, 0x07, 0x12, 0x01, 0x00, 0x00, 0x12, 0x34, 0x56, 0x78]b;
            var actual = aes_ccm_enc(key, data, nonce, MIC_SIZE_4);

            pass = pass && actual.equals(expected);

            if (!pass) {
                logger.debug("encrypted = " + hexString(actual, null));
                logger.debug("expected = " + hexString(expected, null));
                logger.error("aes-ccm function failed to encrypt the data properly");
            }
        }

        // test the AES-CCM decryption function
        if (pass) {
            var expected = [0xff, 0xff, 0x66, 0x5a, 0x8b, 0xde, 0x6d, 0x91, 0x06, 0xea, 0x07, 0x8a]b;
            var data = [0x56, 0x73, 0x72, 0x8a, 0x62, 0x7f, 0xb9, 0x38, 0x53, 0x55, 0x08, 0xe2, 0x1a, 0x6b, 0xaf, 0x57]b;
            var key = [0x09, 0x53, 0xfa, 0x93, 0xe7, 0xca, 0xac, 0x96, 0x38, 0xf5, 0x88, 0x20, 0x22, 0x0a, 0x39, 0x8e]b;
            var nonce = [0x00, 0x03, 0x00, 0x00, 0x07, 0x12, 0x01, 0x00, 0x00, 0x12, 0x34, 0x56, 0x78]b;
            var actual = aes_ccm_dec(key, data, nonce, MIC_SIZE_4);

            pass = pass && actual.equals(expected);

            if (!pass) {
                logger.debug("encrypted = " + hexString(actual, null));
                logger.debug("expected = " + hexString(expected, null));
                logger.error("aes-ccm function failed to decrypt and validate the data properly");
            }
        }

        // test encryption and decryption of the same data
        if (pass) {
            var original = [0xff, 0xff, 0x66, 0x5a, 0x8b, 0xde, 0x6d, 0x91, 0x06, 0xea, 0x07, 0x8a]b;
            var key = [0x09, 0x53, 0xfa, 0x93, 0xe7, 0xca, 0xac, 0x96, 0x38, 0xf5, 0x88, 0x20, 0x22, 0x0a, 0x39, 0x8e]b;
            var nonce = [0x00, 0x03, 0x00, 0x00, 0x07, 0x12, 0x01, 0x00, 0x00, 0x12, 0x34, 0x56, 0x78]b;
            var data = aes_ccm_enc(key, original, nonce, MIC_SIZE_4);
            var test = aes_ccm_dec(key, data, nonce, MIC_SIZE_4);

            pass = pass && original.equals(test);

            if (!pass) {
                logger.error("failed to encrypt then decrypt the data properly");
            }
        }

        // test the to bytes util function
        if (pass) {
            var expected = [0x00, 0x01, 0x05]b;
            var val = 0x105;
            var actual = toBytes(val, 3);

            pass = pass && expected.equals(actual);

            if (!pass) {
                logger.debug("actual = " + hexString(actual, null));
                logger.debug("expected = " + hexString(expected, null));
                logger.error("toBytes failed to encode the data correctly");
            }
        }

        if (pass) {
            var expected = 0x105;
            var val = [0x00, 0x01, 0x05]b;
            var actual = fromBytes(val, 0, 3);
            pass = pass && expected == actual;

            if (!pass) {
                logger.debug("actual = " + actual.toString());
                logger.debug("expected = " + expected.toString());
                logger.error("fromBytes failed to decode the data correctly");
            }
        }

        return pass;
    }

//  (:test)
//  function test_packet_assembly(logger) {
//      var nm = new NetworkManager();
//      nm.setNetKey([0x12, 0xd2, 0xcb, 0xe8, 0x33, 0x2d, 0x20, 0xeb, 0x72, 0xd4, 0x86, 0x68, 0x05, 0x49, 0x19, 0xe7]b);
//      nm.setAppKey([0xd1, 0xc6, 0x89, 0x54, 0xc7, 0xe1, 0x5c, 0x54, 0x79, 0xc0, 0x92, 0x57, 0x87, 0x6b, 0x35, 0x38]b);
//      nm.setSequenceNumber(123);
//      nm.setIvIndex(0);
//
//      var packet = GenericOnOff.setUnacknowledged(nm, GenericOnOff.ON, 0x0005);
//      logger.debug("packet is: " + hexString(packet, null));
//
//      return true;
//  }
//
//  (:test)
//  function test_unsegmented_access_message(logger) {
//      var expected = [0x68, 0x48, 0xcb, 0xa4, 0x37, 0x86, 0x0e, 0x56, 0x73, 0x72, 0x8a, 0x62, 0x7f, 0xb9, 0x38, 0x53, 0x55, 0x08, 0xe2, 0x1a, 0x6b, 0xaf, 0x57]b;
//
//      var nm = new NetworkManager();
//      nm.setNetKey([0x7d, 0xd7, 0x36, 0x4c, 0xd8, 0x42, 0xad, 0x18, 0xc1, 0x7c, 0x2b, 0x82, 0x0c, 0x84, 0xc3, 0xd6]b);
//      nm.setAppKey([0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b);
//      nm.setIvIndex(0x12345678);
//      nm.setAddress(0x1201);
//      nm.setSequenceNumber(0x000007);
//
//      var payload = new AccessPayload([0x04]b, [0x00, 0x00, 0x00, 0x00]b);
//      logger.debug("payload: " + hexString(payload.serialize(), null));
//      var transportPdu = new TransportPDU(false, true, nm.getKey(KEY_AID), payload);
//      logger.debug("transportPdu: " + hexString(transportPdu.encrypt(nm, 0xffff), null));
//      var networkPdu = NetworkPDU.newInstance(nm, 0xffff, transportPdu);
//
//      var encrypted = networkPdu.encrypt(nm);
//
//      logger.debug("expected value: " + hexString(expected, null));
//      logger.debug("actually value: " + hexString(encrypted, null));
//
//      return expected.equals(encrypted);
//  }
//
//  (:test)
//  function test_proxy_pdu_segmenter(logger) {
//      var expected = [ [0x40, 0x68, 0x48, 0xcb, 0xa4, 0x37, 0x86, 0x0e, 0x56, 0x73, 0x72, 0x8a, 0x62, 0x7f, 0xb9, 0x38, 0x53, 0x55, 0x08, 0xe2]b, [0xc0, 0x1a, 0x6b, 0xaf, 0x57]b, ];
//
//      var nm = new NetworkManager();
//      nm.setNetKey([0x7d, 0xd7, 0x36, 0x4c, 0xd8, 0x42, 0xad, 0x18, 0xc1, 0x7c, 0x2b, 0x82, 0x0c, 0x84, 0xc3, 0xd6]b);
//      nm.setAppKey([0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, s0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b);
//      nm.setIvIndex(0x12345678);
//      nm.setAddress(0x1201);
//      nm.setSequenceNumber(0x000007);
//
//      var payload = new AccessPayload([0x04]b, [0x00, 0x00, 0x00, 0x00]b);
//      var transportPdu = new TransportPDU(false, true, nm.getKey(KEY_AID), payload);
//      var networkPdu = NetworkPDU.newInstance(nm, 0xffff, transportPdu);
//
//      var encrypted = networkPdu.encrypt(nm);
//      var actual = ProxyPDU.segment(PROXY_TYPE_NETWORK_PDU, encrypted);
//
//      logger.debug("expected value: " + expected.toString());
//      logger.debug("actually value: " + actual.toString());
//
//      // easiest way to check equivalence of 2D array
//      return expected.toString().equals(actual.toString());
//  }
//
//  (:test)
//  function test_packet_encrypt_decrypt(logger) {
//      var nm = new NetworkManager();
//      nm.setNetKey([0x7d, 0xd7, 0x36, 0x4c, 0xd8, 0x42, 0xad, 0x18, 0xc1, 0x7c, 0x2b, 0x82, 0x0c, 0x84, 0xc3, 0xd6]b);
//      nm.setAppKey([0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b);
//      nm.setIvIndex(0x12345678);
//      nm.setAddress(0x1201);
//      nm.setSequenceNumber(0x000007);
//
//      var payload = new AccessPayload([0x04]b, [0x00, 0x00, 0x00, 0x00]b);
//      var transportPdu = new TransportPDU(false, true, nm.getKey(KEY_AID), payload);
//      var networkPdu = NetworkPDU.newInstance(nm, 0xffff, transportPdu);
//
//      var encrypted = networkPdu.encrypt(nm);
//      var decrypted = NetworkPDU.decrypt(nm, encrypted);
//
//      return networkPdu.equals(decrypted);
//
//  }
//
//  (:test)
//  function test_key_generation(logger) {
//      var expected = [0x31, 0xe6, 0x8e, 0x38, 0x9d, 0xe5, 0xad, 0x15, 0x01, 0xd1, 0xac, 0x53, 0x1a, 0xf2, 0xa7, 0x15, 0xf9, 0x0e, 0xc8, 0x6d, 0x46, 0x6d, 0x69, 0x73, 0x94, 0xb0, 0x50, 0x79, 0xa0, 0x02, 0xf2, 0xa8, 0x15, 0x86, 0x0c, 0x92, 0x64, 0x36, 0xae, 0x4f, 0x42, 0x40, 0x63, 0xef, 0x9c, 0x12, 0xc4, 0x85, 0x07, 0x23, 0xb2, 0x1b, 0xbd, 0x6a, 0xd7, 0x4e, 0x2d, 0x53, 0xf1, 0xaa, 0x86, 0x7e, 0x3a, 0xbe]b;
//      var privKey = [0x1d, 0x41, 0x5f, 0x23, 0x2d, 0xaf, 0x51, 0x1b, 0xe0, 0x7c, 0x88, 0x5e, 0xfe, 0x1b, 0xd2, 0xad, 0xe0, 0x89, 0xc0, 0xfe, 0x05, 0xff, 0x93, 0x1e, 0x4c, 0xa6, 0x9e, 0xf9, 0x79, 0x13, 0xba, 0xb0]b;
//      var keyPair = new Crypto.KeyPair({:algorithm => Crypto.KEY_PAIR_ELLIPTIC_CURVE_SECP256R1, :privateKey => privKey});
//      logger.debug("Private key: " + hexString(keyPair.getPrivateKey().getBytes(), 1));
//      logger.debug("Public key: " + hexString(keyPair.getPublicKey().getBytes(), 1));
//      return keyPair.getPublicKey().getBytes().equals(expected);
//  }
}