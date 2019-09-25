module BluetoothMeshBarrel {

    (:test)
    function test_KeyManager(logger) {
        var pass = true;
        var km = new KeyManager();

        var netKey = [0x7d, 0xd7, 0x36, 0x4c, 0xd8, 0x42, 0xad, 0x18, 0xc1, 0x7c, 0x2b, 0x82, 0x0c, 0x84, 0xc3, 0xd6]b;
        var appKey = [0x63, 0x96, 0x47, 0x71, 0x73, 0x4f, 0xbd, 0x76, 0xe3, 0xb4, 0x05, 0x19, 0xd1, 0xd9, 0x4a, 0x48]b;
        var expectedKeyObject = {
            NETWORK_KEY => netKey,
            ENCRYPTION_KEY => [0x09, 0x53, 0xfa, 0x93, 0xe7, 0xca, 0xac, 0x96, 0x38, 0xf5, 0x88, 0x20, 0x22, 0x0a, 0x39, 0x8e]b,
            PRIVACY_KEY => [0x8b, 0x84, 0xee, 0xde, 0xc1, 0x00, 0x06, 0x7d, 0x67, 0x09, 0x71, 0xdd, 0x2a, 0xa7, 0x00, 0xcf]b,
            NET_ID => 0x68,
            NETWORK_ID => [0x3e, 0xca, 0xff, 0x67, 0x2f, 0x67, 0x33, 0x70]b,
            IDENTITY_KEY => [0x84, 0x39, 0x6c, 0x43, 0x5a, 0xc4, 0x85, 0x60, 0xb5, 0x96, 0x53, 0x85, 0x25, 0x3e, 0x21, 0x0c]b,
            BEACON_KEY => [0x54, 0x23, 0xd9, 0x67, 0xda, 0x63, 0x9a, 0x99, 0xcb, 0x02, 0x23, 0x1a, 0x83, 0xf7, 0xd2, 0x54]b,
        };
        var expectedAppKeyObject = {
            APPLICATION_KEY => appKey,
            APPLICATION_ID => 0x26
        };

        // test proper initialization
        if (pass) {
            pass = pass && km.netKeys.size() == 0;
            if (!pass) {
                logger.error("new key manager does not initialize empty key array");
            }
        }

        // test adding network key
        if (pass) {
            km.addNetKey(netKey);
            pass = pass && km.netKeys.size() == 1;
            pass = pass && netKeyObjectsEqual(expectedKeyObject, km.netKeys[0]);
            pass = pass && km.appKeys.size() == 0;
            if (!pass) {
                logger.error("key manager failed to generate expected derived netKeys from the added net key");
                logger.debug("expected: " + expectedKeyObject.toString());
                logger.debug("actual: " + km.netKeys[0].toString());
            }
        }

        // test saving the netKeys doesn't cause an exception
        if (pass) {
            try {
                km.saveKeys();
                pass = true;
            } catch (e) {
                pass = false;
                logger.error("saving the netKeys caused an exception");
            }
        }

        // test clearing the netKeys resets the key manager to an empty array
        if (pass) {
            km.clearKeys();
            pass = km.netKeys.size() == 0;
            if (!pass) {
                logger.error("clearing the netKeys did not clear the netKeys array");
                logger.debug(km.netKeys.toString());
            }
        }

        // test loading the netKeys restores the saved state
        if (pass) {
            km.loadKeys();
            pass = pass && km.netKeys.size() == 1;
            pass = pass && netKeyObjectsEqual(expectedKeyObject, km.netKeys[0]);
            pass = pass && km.appKeys.size() == 0;
            if (!pass) {
                logger.error("loading the netKeys failed to properly restore the saved values");
                logger.debug("expected: " + expectedKeyObject.toString());
                logger.debug("actual: " + km.netKeys[0].toString());
            }
        }

        // test adding an app key
        if (pass) {
            km.addAppKey(0, appKey);
            pass = pass && appKeyObjectsEqual(km.appKeys, expectedAppKeyObject);
            pass = pass && km.appKeys.size() == 1;
            if (!pass) {
                logger.error("Adding a new app key failed to correctly add the key");
                logger.debug("expected: " + expectedAppKeyObject.toString());
                logger.debug("actual: " + km.netKeys[0].toString());
            }
        }

        // test getting the index of the net key using nid
        if (pass) {
            pass = 0 == km.getNetKeyIndex(expectedKeyObject[NET_ID]);
            if (!pass) {
                logger.error("key manager failed to get the key index from nid");
            }
        }

        // test getting the index of the net key using the net key
        if (pass) {
            pass = 0 == km.getNetKeyIndex(netKey);
            if (!pass) {
                logger.error("key manager failed to get the key index from net key");
            }
        }

        return pass;
    }

    // ****************** UTILITY FUNCTIONS ****************** //

    function netKeyObjectsEqual(a, b) {
        var pass = true;
        pass = pass && a[NETWORK_KEY].equals(b[NETWORK_KEY]);
        pass = pass && a[ENCRYPTION_KEY].equals(b[ENCRYPTION_KEY]);
        pass = pass && a[PRIVACY_KEY].equals(b[PRIVACY_KEY]);
        pass = pass && a[NET_ID].equals(b[NET_ID]);
        pass = pass && a[NETWORK_ID].equals(b[NETWORK_ID]);
        pass = pass && a[IDENTITY_KEY].equals(b[IDENTITY_KEY]);
        pass = pass && a[BEACON_KEY].equals(b[BEACON_KEY]);
        return pass;
    }

    function appKeyObjectsEqual(a, b) {
        var pass = true;
        pass = pass && a[APPLICATION_KEY].equals(b[APPLICATION_KEY]);
        pass = pass && a[APPLICATION_ID].equals(b[APPLICATION_ID]);
        return pass;
    }


}