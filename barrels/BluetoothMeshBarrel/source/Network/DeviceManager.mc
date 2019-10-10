using Toybox.System;
using Toybox.Lang;
using Toybox.Application as App;

module BluetoothMeshBarrel {

    class DeviceManager {

        // constant for saving in storage
        private const DEVICES_STORAGE = "meshdevices";
        private const GROUPS_STORAGE = "meshgroups";

        private var devices = [];
        private var groups = [];

        // save to storage
        function save() {
            var devicesToSave = [];
            for (var i = 0; i < self.devices.size(); i++) {
                devicesToSave.add(self.devices[i].toDictionary());
            }
            App.Storage.setValue(DEVICES_STORAGE, devicesToSave);
            App.Storage.setValue(GROUPS_STORAGE, self.groups);
        }

        // load from storage
        function load() {
            self.groups = App.Storage.getValue(GROUPS_STORAGE);
            if (self.groups == null) {
                self.groups = [];
            }
            var loadedDevices = App.Storage.getValue(DEVICES_STORAGE);
            if (loadedDevices == null) {
                loadedDevices = [];
            }
            self.devices = [];
            for (var i = 0; i < loadedDevices.size(); i++) {
                // prints the value of each device stored at startup for debug
                // System.println(loadedDevices[i].toString());
                self.devices.add(Device.newInstance(loadedDevices[i]));
            }

        }

        // inform the device manager know that there is a new group
        function addGroup(address) {
            if (!(address instanceof Lang.Number && address >= 0xc000 && address < 0xff00)) {
                throw new Lang.UnexpectedTypeException("Group addresses must be a number between 0xc000 and 0xfeff, inclusive");
            }

            self.groups.add(address);
        }

        // remove the group from the device manager
        function removeGroup(address) {
            if (!(address instanceof Lang.Number && address >= 0xc000 && address < 0xff00)) {
                throw new Lang.UnexpectedTypeException("Group addresses must be a number between 0xc000 and 0xfeff, inclusive");
            }
            self.groups.remove(address);
        }

        // returns the groups that have been established
        function getGroups() {
            return self.groups;
        }

        // Adds the device to the list of known devices
        // Throws an exception if the argument is not a
        // Device object
        function addDevice(device) {
            if (device instanceof Device) {
                self.devices.add(device);
            } else {
                throw new Lang.UnexpectedTypeException();
            }
        }

        // removes the specified device from the list of devices
        // identifier can be either a Device object or an address
        // of the device to be removed
        function removeDevice(identifier) {
            if (identifier instanceof Device) {
                if (!self.devices.remove(identifier)) {
                    throw new Lang.InvalidValueException();
                }
            } else if (identifier instanceof Lang.Number) {
                for (var i = 0; i < self.devices.size(); i++) {
                    if (self.devices[i].getAddress() == identifier) {
                        self.devices.remove(self.devices[i]);
                    }
                }
            } else {
                throw new Lang.UnexpectedTypeException();
            }
        }


        // determines if the device with the specified address is
        // known to the system. Throws exception if the address is
        // not an instance of Lang.Number
        function hasDevice(address) {
            if (!(address instanceof Lang.Number)) {
                throw new Lang.UnexpectedTypeException();
            }
            for (var i = 0; i < self.devices.size(); i++) {
                if (self.devices[i].getAddress() == address) {
                    return true;
                }
            }
        }

        // gets the device by the address, if it is known
        // if not known or bad address, then it will return
        // null
        function getDevice(address) {
            if (!(address instanceof Lang.Number)) {
                throw new Lang.UnexpectedTypeException();
            }
            for (var i = 0; i < self.devices.size(); i++) {
                if (self.devices[i].getAddress() == address) {
                    return self.devices[i];
                }
            }
            return null;
        }

        // gets the base address of the next item that is provisioned
        function getNextAddress() {
            var nextAddress = 1;
            if (self.devices.size() > 1) {
                var highestAddressIndex = 0;
                for (var i = 1; i < self.devices.size(); i++) {
                    if (self.devices[i].getAddress() > self.devices[highestAddressIndex].getAddress()) {
                        highestAddressIndex = i;
                    }
                }
                nextAddress = self.devices[highestAddressIndex].getAddress() + self.devices[highestAddressIndex].getNumberOfElements();
            } else if (self.devices.size() == 1) {
                nextAddress = self.devices[0].getAddress() + self.devices[0].getNumberOfElements();
            }
            return nextAddress;
        }

        // clear the list of known devices
        function reset() {
            self.devices = [];
            self.groups = [];
        }

        // get the number of known devices
        function deviceCount() {
            return self.devices.size();
        }

        // returns an array of known addresses
        function getAddresses() {
            var addresses = [];
            for (var i = 0; i < self.devices.size(); i++) {
                addresses.add(self.devices[i].getAddress());
            }
            return addresses;
        }

    }

}