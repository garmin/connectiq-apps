using Toybox.System;
using Toybox.Lang;
using Toybox.Application as App;

module BluetoothMeshBarrel {

    const NET_KEYS_STORAGE = "netkeys";
    const APP_KEYS_STORAGE = "appkeys";

    const NETWORK_KEY = "netkey";
    const ENCRYPTION_KEY = "enckey";
    const PRIVACY_KEY = "prvkey";
    const BEACON_KEY = "bcnkey";
    const IDENTITY_KEY = "idkey";
    const NETWORK_ID = "ntwkid";
    const NET_ID = "nid";

    const APPLICATION_KEY = "appkey";
    const APPLICATION_ID = "appid";


//  format of the netkeys array (after parsing):
//  stored as just an array of ByteArrays representing each key
//  [
//      {
//          "netkey" => [0xde, 0xad, 0xbe, 0xef..],
//          "enckey" => [0xde, 0xad, 0xbe, 0xef..],   <--- not stored, calculated & cached
//          "prvkey" => [0xde, 0xad, 0xbe, 0xef..],   <--- not stored, calculated & cached
//          "bcnkey" => [0xde, 0xad, 0xbe, 0xef..],   <--- not stored, calculated & cached
//          "idkey" => [0xde, 0xad, 0xbe, 0xef..],    <--- not stored, calculated & cached
//          "nid" => 0x12,                            <--- not stored, calculated & cached
//          "ntwkid" => [0xde, 0xad, 0xbe, 0xef..],   <--- not stored, calculated & cached
//      },
//  ]

//  format of the appkeys array (after parsing):
//  app keys are stored in application storage as an array of ByteArrays
//  [
//      {
//          "appkey" => [0xde, 0xad, 0xbe, 0xef..],
//          "aid" => 0x34                     <--- not stored, calculated & cached
//      },
//      {
//          "appkey" => [0xde, 0xad, 0xbe, 0xef..],
//          "aid" => 0x34                     <--- not stored, calculated & cached
//      }
//  ]
//
//

//  Recommended way to import keys from other provisioners:
//  - Create an "import net key", "net key index" and "import app key" setting
//  - Register onSettingsChanged in your main Application class
//  - if "import net key" setting is changed, parse & add it to the key manager
//  - if "import app key" setting is changed, parse & add to the key manager at
//    the net key index of the "net key index" setting (require non-null)
//  - if "net key index" setting is changed, do nothing

    class KeyManager {

        private var netKeys = [];
        private var appKeys = [];

        // load the keys from storage
        function loadKeys() {
            // get keys from storage and turn null value into empty array
            var tempNetKeys = App.Storage.getValue(NET_KEYS_STORAGE);
            if (tempNetKeys == null) {
                tempNetKeys = [];
            }
            // iterate through array to calculate the derived keys
            for (var i = 0; i < tempNetKeys.size(); i++) {
                var netKeyData = calculateNetKeyData(tempNetKeys[i]);
                self.netKeys.add(netKeyData);
            }

            // get keys from storage and turn null value into empty array
            var tempAppKeys = App.Storage.getValue(APP_KEYS_STORAGE);
            if (tempAppKeys == null) {
                tempAppKeys = [];
            }
            // iterate through array to calculate the derived keys
            for (var i = 0; i < tempAppKeys.size(); i++) {
                var appKeyData = calculateAppKeyData(tempAppKeys[i]);
                self.appKeys.add(appKeyData);
            }
        }

        // saves the keys to device storage
        function saveKeys() {
            // create slimmed-down data structure to save the keys into
            var netKeysToSave = [];
            var appKeysToSave = [];
            for (var i = 0; i < self.netKeys.size(); i++) {
                netKeysToSave.add(self.netKeys[i][NETWORK_KEY]);
            }

            for (var i = 0; i < self.appKeys.size(); i++) {
                appKeysToSave.add(self.appKeys[i][APPLICATION_KEY]);
            }

            App.Storage.setValue(NET_KEYS_STORAGE, netKeysToSave);
            App.Storage.setValue(APP_KEYS_STORAGE, appKeysToSave);
        }

        // deletes all of the keys stored by the app
        function clearKeys() {
            self.netKeys = [];
            self.appKeys = [];
        }

        // adds a new net key to the known keys structure, returns the index of the key
        function addNetKey(netKey) {
            if (!(netKey instanceof Lang.ByteArray) || netKey.size() != 16) {
                throw new Lang.InvalidValueException("Key is not a valid mesh network key");
            }
            var keyData = calculateNetKeyData(netKey);
            self.netKeys.add(keyData);
            return self.netKeys.size() - 1;
        }

        // updates the value of the netkey at the given index
        function updateNetKey(netKeyIndex, newNetKey) {
            if (!(newNetKey instanceof Lang.ByteArray) || newNetKey.size() != 16) {
                throw new Lang.InvalidValueException("Key is not a valid mesh network key");
            } else if (netKeyIndex >= self.netKeys.size()) {
                throw new Lang.ValueOutOfBoundsException();
            }

            self.netKeys[netKeyIndex] = calculateNetKeyData(newNetKey);
        }

        // add the app key to the corresponding net key, returns the index of the new app key
        function addAppKey(appKey) {
            if (!(appKey instanceof Lang.ByteArray) || appKey.size() != 16) {
                throw new Lang.InvalidValueException("Key is not a valid mesh network key");
            }
            var newAppKeyData = calculateAppKeyData(appKey);
            self.appKeys.add(newAppKeyData);
            return self.appKeys.size() - 1;
        }

        // updates the value of the appkey at the given index
        function updateAppKey(appKeyIndex, newAppKey) {
            if (!(newAppKey instanceof Lang.ByteArray) || newAppKey.size() != 16) {
                throw new Lang.InvalidValueException("Key is not a valid mesh network key");
            } else if (appKeyIndex >= self.appKeys.size()) {
                throw new Lang.ValueOutOfBoundsException();
            }

            self.appKeys[appKeyIndex] = calculateAppKeyData(newAppKey);
        }

        // get the count of known net keys
        function getNetKeyCount() {
            return self.netKeys.size();
        }

        // get the count of known app keys for the given net key
        function getAppKeyCount() {
            return self.appKeys.size();
        }

        // get the net key or derived keys for the given net key index
        // possible values include NETWORK_KEY, ENCRYPTION_KEY,
        // PRIVACY_KEY, BEACON_KEY, IDENTITY_KEY, NETWORK_ID, NET_ID
        function getKey(netKeyIndex, key) {
            if (netKeyIndex >= self.netKeys.size()) {
                throw new Lang.ValueOutOfBoundsException("Requested key index is out of bounds");
            }
            return self.netKeys[netKeyIndex][key];
        }

        // gets the app key for the given net and app key indices
        function getAppKey(appKeyIndex) {
            if (appKeyIndex >= self.appKeys.size()) {
                throw new Lang.ValueOutOfBoundsException();
            }
            return self.appKeys[appKeyIndex][APPLICATION_KEY];
        }

        // gets the app key id for the given net and app key indices
        function getAppID(appKeyIndex) {
            if (appKeyIndex >= self.appKeys.size()) {
                throw new Lang.ValueOutOfBoundsException();
            }
            return self.appKeys[appKeyIndex][APPLICATION_ID];
        }

        // gets the index of the net key indentified by the identifier.
        // Identifier can be either the nid value of the key or the
        // net key itself. If index = -1, identifier does not exist in
        // the known keys
        function getNetKeyIndex(identifier) {
            var index = null;
            var id_field;
            if (identifier instanceof Lang.Number) {
                id_field = NET_ID;
            } else if (identifier instanceof Lang.ByteArray && identifier.size() == 16) {
                id_field = NETWORK_KEY;
            } else {
                throw new Lang.UnexpectedTypeException("identifier must be either the key or net id");
            }

            // iterate through all keys to find the identifier, if exists
            for (var i = 0; i < self.netKeys.size(); i++) {
                if (identifier.equals(self.netKeys[i][id_field])) {
                    index = i;
                    break;
                }
            }
            return index;
        }

        // gets the index of the app key identified by the identifier.
        // Identifier can either be the aid value of the key or the
        // app key itself. Returns null if identifier does not exist in
        // the known keys
        function getAppKeyIndex(identifier) {
            var index = null;
            var id_field;
            if (identifier instanceof Lang.Number) {
                id_field = APPLICATION_ID;
            } else if (identifier instanceof Lang.ByteArray && identifier.size() == 16) {
                id_field = APPLICATION_KEY;
            } else {
                throw new Lang.InvalidValueException();
            }

            // iterate through the keys to find the requested key, if exists
            for (var i = 0; i < self.appKeys.size(); i++) {
                if (identifier.equals(self.appKeys[i][id_field])) {
                    index = i;
                    break;
                }
            }
            return index;
        }

        // Calculates the derived keys from the netkey and the appkeys
        private function calculateNetKeyData(netKey) {
            var keyData = {};

            // network key derived key calculations
            keyData[NETWORK_KEY] = netKey;
            var k2_output = k2(netKey, [0x00]b);
            keyData[NET_ID] = k2_output[0];
            keyData[ENCRYPTION_KEY] = k2_output.slice(1, 17);
            keyData[PRIVACY_KEY] = k2_output.slice(17, 33);
            keyData[NETWORK_ID] = k3(netKey);

            // identity and beacon key calculations
            var ik_salt = s1(['n', 'k', 'i', 'k']b);
            keyData[IDENTITY_KEY] = k1(netKey, ik_salt, ['i', 'd', '1', '2', '8', 0x01]b);
            var bk_salt = s1(['n', 'k', 'b', 'k']b);
            keyData[BEACON_KEY] = k1(netKey, bk_salt, ['i', 'd', '1', '2', '8', 0x01]b);

            return keyData;
        }

        // helper function to calculate the app key data from an app key
        private function calculateAppKeyData(appKey) {
            var keyData = {};
            keyData[APPLICATION_KEY] = appKey;
            keyData[APPLICATION_ID] = k4(appKey);
            return keyData;
        }

    }

}