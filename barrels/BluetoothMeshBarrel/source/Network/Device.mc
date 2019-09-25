using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class Device {

        public static const ALL_DEVICES = new Device(0xffff, 0, null, null, 0, [0]);

        // constants for saving the data in storage
        private static const DEVICE_ADDRESS = "devaddr";
        private static const DEVICE_ELEMENTS = "develem";
        private static const DEVICE_ELEMENTS_NUM = "develemnum";
        private static const DEVICE_KEY = "devkey";
        private static const DEVICE_NET_KEY = "nkindex";
        private static const DEVICE_APP_KEYS = "akindex";

        private var address;            // 16 bit integer
        private var numElements;        // integer for number of elements for now. In the future, this will be inforation about the elements and the models they contain
        private var elements = [];      // the elements that the device contains. Array of Dictionaries
        private var deviceKey;          // ByteArray, 16 bytes
        private var netKey;             // Integer of index of net key
        private var appKeys = [];       // Array of Integers

        function initialize(address, numElements, elements, devKey, netKeyIndex, appKeyIndices) {
            self.address = address;
            self.numElements = numElements;
            self.elements = elements;
            self.deviceKey = devKey;
            self.netKey = netKeyIndex;
            self.appKeys = appKeyIndices;
        }

        function getAddress() {
            return self.address;
        }

        function setAddress(address) {
            self.address = address;
        }

        function getNumberOfElements() {
            return self.numElements;
        }

        function setElements(elements) {
            self.elements = elements;
        }

        function getElements() {
            return self.elements;
        }

        function setNumberOfElements(numElements) {
            self.numElements = numElements;
        }

        function getDeviceKey() {
            return self.deviceKey;
        }

        function setDeviceKey(key) {
            self.deviceKey = key;
        }

        function getNetKeyIndex() {
            return self.netKey;
        }

        function setNetKeyIndex(index) {
            self.netKey = index;
        }

        function getAppKeyIndices() {
            return self.appKeys;
        }

        function setAppKeyIndices(indices) {
            self.appKeys = indices;
        }

        // for saving the data in storage
        function toDictionary() {
            return {
                DEVICE_ADDRESS => self.address,
                DEVICE_ELEMENTS => self.elements,
                DEVICE_ELEMENTS_NUM => self.numElements,
                DEVICE_KEY => self.deviceKey,
                DEVICE_NET_KEY => self.netKey,
                DEVICE_APP_KEYS => self.appKeys
            };
        }

        // for parsing the data out of storage
        static function newInstance(dictionary) {
            var addr = dictionary[DEVICE_ADDRESS];
            var elemNum = dictionary[DEVICE_ELEMENTS_NUM];
            var elems = dictionary[DEVICE_ELEMENTS];
            if (elems == null) { elems = []; }
            var devKey = dictionary[DEVICE_KEY];
            var netKeyIndex = dictionary[DEVICE_NET_KEY];
            var appKeys = dictionary[DEVICE_APP_KEYS];
            if (appKeys == null) { appKeys = []; }
            return new Device(addr, elemNum, elems, devKey, netKeyIndex, appKeys);
        }

    }

}