using Toybox.System;
using Toybox.Lang;
using Toybox.Cryptography as Crypto;

module BluetoothMeshBarrel {

    class ProvisioningManager {

        private var networkManager;
        private var device;

        private var confirmationInputs = []b;
        private var confirmationSalt;
        private var confirmationKey;
        private var keyPair;
        private var keyAgreement;
        private var ecdhSecret;
        private var deviceRandom;
        private var deviceConfirmation;
        private var deviceKey;
        private var authValue;
        private var provisionerRandom;
        private var provisioningSalt;

        // constructor for the keymanager
        function initialize(networkManager) {
            self.networkManager = networkManager;
            self.reset();
        }

        function reset() {
            self.keyPair = new Crypto.KeyPair({:algorithm => Crypto.KEY_PAIR_ELLIPTIC_CURVE_SECP256R1});
            self.provisionerRandom = Crypto.randomBytes(16);
            self.confirmationInputs = []b;
            self.confirmationSalt = null;
            self.confirmationKey = null;
            self.keyAgreement = null;
            self.ecdhSecret = null;
            self.deviceRandom = null;
            self.deviceConfirmation = null;
            self.deviceKey = null;
            self.authValue = null;
            self.provisioningSalt = null;
            self.device = null;
        }

        // starts the provisioning process by sending invite pdu
        function startProvisioning() {
            var invitePdu = new InvitePDU(0x05);
            self.addPduConfirmationInputs(invitePdu);
            self.device = new Device(self.networkManager.deviceManager.getNextAddress(), 0, [], []b, 0, []);
            self.networkManager.send(ProxyPDU.segment(PROXY_TYPE_PROVISION, [invitePdu.serialize()]));
        }

        // handler
        function handleProvisioningPDU(provPdu) {
            switch (provPdu.getType()) {
                case PROV_CAPABILITIES:
                    self.device.setNumberOfElements(provPdu.getNumberOfElements());
                    self.addPduConfirmationInputs(provPdu);
                    self.networkManager.callback.get().onProvisioningParamsRequested(provPdu);
                    break;
                case PROV_PUBLIC_KEY:
                    self.addPduConfirmationInputs(provPdu);
                    self.addPublicKeyBytes(provPdu.getKey());
                    if (self.networkManager.callback != null && self.networkManager.callback.stillAlive() && self.networkManager.callback.get() != null) {
                        if (self.networkManager.callback.get() has :onAuthValueRequired) {
                            self.networkManager.callback.get().onAuthValueRequired();
                        } else {
                            self.onAuthValueInput(0);
                        }
                    } else {
                        self.onAuthValueInput(0);
                    }
                    break;
                case PROV_CONFIRMATION:
                    self.addDeviceConfirmation(provPdu.getConfirmation());
                    var randomPdu = new RandomPDU(self.getProvisionerRandom());
                    var segmented = ProxyPDU.segment(PROXY_TYPE_PROVISION, [randomPdu.serialize()]);
                    self.networkManager.send(segmented);
                    break;
                case PROV_RANDOM:
                    self.addDeviceRandom(provPdu.getRandom());
                    if (self.validateConfirmation()) {
                        // TODO: add a way for the user to configure which networks the
                        // device will have keys for. Probably add a callback to start the
                        // process of getting the feedback, but then move this sending
                        // network data pdu to the callback's callback. Currently, the default
                        // is to use the primary network key (index 0)
                        var dataPdu = new NetworkDataPDU(self.getEncryptedNetworkData(0, self.networkManager.getIvIndex()));
                        self.networkManager.send(ProxyPDU.segment(PROXY_TYPE_PROVISION, [dataPdu.serialize()]));
                    } else {
                        System.println("verifying the confirmation (self) failed");
                        if (self.networkManager.callback != null && self.networkManager.callback.stillAlive() && self.networkManager.callback.get() != null) {
                            if (self.networkManager.callback.get() has :onProvisioningFailed) {
                                self.networkManager.callback.get().onProvisioningFailed(provPdu.toString());
                            }
                        }
                    }
                    break;
                case PROV_FAILED:
                    System.println("Confirmation verification failed");
                    if (self.networkManager.callback != null && self.networkManager.callback.stillAlive() && self.networkManager.callback.get() != null) {
                        if (self.networkManager.callback.get() has :onProvisioningFailed) {
                            self.networkManager.callback.get().onProvisioningFailed(provPdu.toString());
                        }
                    }
                    self.reset();
                    break;
                case PROV_COMPLETE:
                    self.networkManager.deviceManager.addDevice(self.device);
                    if (self.networkManager.callback != null && self.networkManager.callback.stillAlive() && self.networkManager.callback.get() != null) {
                        if (self.networkManager.callback.get() has :onProvisioningComplete) {
                            self.networkManager.callback.get().onProvisioningComplete(self.device);
                        }
                    }
                    System.println("Device key is: " + hexString(self.device.getDeviceKey(), null));
                    self.reset();
                    break;
                default:
                    break;
            }
        }

        // callback for the auth value of the device
        function onAuthValueInput(authValue) {
            self.authValue = authValue;
            var confirmationPdu = new ConfirmationPDU(self.getProvisionerConfirmation());
            var segmented = ProxyPDU.segment(PROXY_TYPE_PROVISION, [confirmationPdu.serialize()]);
            self.networkManager.send(segmented);
        }

        // callback for auth parameters
        function onProvisioningModeSelected(startPdu) {
            if (!(startPdu instanceof StartPDU)) {
                throw new Lang.UnexpectedTypeException();
            }
            self.addPduConfirmationInputs(startPdu);
            self.networkManager.send(ProxyPDU.segment(PROXY_TYPE_PROVISION, [startPdu.serialize()]));
            var publicKeyPdu = new PublicKeyPDU(self.getPublicKeyBytes());
            self.addPduConfirmationInputs(publicKeyPdu);
            self.networkManager.send(ProxyPDU.segment(PROXY_TYPE_PROVISION, [publicKeyPdu.serialize()]));
        }

        // *********** PRIVATE FUNCTIONS ************ //

        // add the pdu to the confirmation inputs
        private function addPduConfirmationInputs(pdu) {
            if (!(pdu instanceof ProvisioningPDU)) {
                throw new Lang.UnexpectedTypeException();
            }
            self.confirmationInputs.addAll(pdu.serialize().slice(1, null));
            self.confirmationSalt = s1(self.confirmationInputs);
        }

        // get the byte array of the public ecdh key
        private function getPublicKeyBytes() {
            return self.keyPair.getPublicKey().getBytes();
        }

        // add the public key of the other device. also calculates the secret and confirmation keys
        private function addPublicKeyBytes(bytes) {
            self.keyAgreement = new Crypto.KeyAgreement({:protocol => Crypto.KEY_AGREEMENT_ECDH, :privateKey => self.keyPair.getPrivateKey()});
            var publicKey = Crypto.createPublicKey(Crypto.KEY_PAIR_ELLIPTIC_CURVE_SECP256R1, bytes);
            self.keyAgreement.addKey(publicKey);
            self.ecdhSecret = self.keyAgreement.generateSecret();
            self.confirmationKey = k1(self.ecdhSecret, self.confirmationSalt, ['p', 'r', 'c', 'k']b);
        }

        // getter for the confirmation key (which is available after the public key of the other device is added)
        private function getConfirmationKey() {
            return self.confirmationKey;
        }

        // get the secret generated (available after adding public key bytes)
        private function getEcdhSecret() {
            return self.ecdhSecret;
        }

        // calcualtes this device's confirmation based off of inputs and random value
        private function getProvisionerConfirmation() {
            var bytes = []b;
            bytes.addAll(self.provisionerRandom);
            bytes.addAll(toBytes(self.authValue, 16));
            return aes_cmac(bytes, self.confirmationKey);
        }

        // add the device's random
        private function addDeviceRandom(deviceRandom) {
            self.deviceRandom = deviceRandom;
            // calculate the provisioner salt
            var bytes = []b;
            bytes.addAll(self.confirmationSalt);
            bytes.addAll(self.provisionerRandom);
            bytes.addAll(self.deviceRandom);
            self.provisioningSalt = s1(bytes);
        }

        // add the confirmation data to be verified
        private function addDeviceConfirmation(confirmation) {
            self.deviceConfirmation = confirmation;
        }

        // validate that the confirmation is the value that is expected
        // performs authentication that the device is what we think it is
        private function validateConfirmation() {
            var bytes = []b;
            bytes.addAll(self.deviceRandom);
            bytes.addAll(toBytes(self.authValue, 16));
            var cmac = aes_cmac(bytes, self.confirmationKey);
            return cmac.equals(self.deviceConfirmation);
        }

        // get this device's random value for provisioning
        private function getProvisionerRandom() {
            return self.provisionerRandom;
        }

        // get the device key for the provisioned device
        function getDeviceKey() {
            return k1(self.ecdhSecret, self.provisioningSalt, ['p', 'r', 'd', 'k']b);
        }

        // get the encrypted network data (bytearray) to send to the device
        // netKey is a 16 byte ByteArray, ivIndex is a Number
        private function getEncryptedNetworkData(netKeyIndex, ivIndex) {
            self.device.setDeviceKey(self.getDeviceKey());
            var bytes = []b;
            bytes.addAll(self.networkManager.keyManager.getKey(netKeyIndex, NETWORK_KEY));
            bytes.addAll(toBytes(netKeyIndex, 2));
            bytes.addAll([0x00]b); // flags
            bytes.addAll(toBytes(ivIndex, 4));
            bytes.addAll(toBytes(self.device.getAddress(), 2));
            return aes_ccm_enc(self.getSessionKey(), bytes, self.getSessionNonce(), MIC_SIZE_8);
        }

        // get the session key to encrypt the network data with
        private function getSessionKey() {
            return k1(self.ecdhSecret, self.provisioningSalt, ['p', 'r', 's', 'k']b);
        }

        // get the session nonce to encrypt the network data with
        private function getSessionNonce() {
            return k1(self.ecdhSecret, self.provisioningSalt, ['p', 'r', 's', 'n']b).slice(-13, null);
        }

    }

}