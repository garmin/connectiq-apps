using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    enum {
        ALGORITHM_FIPS_P256
    }

    // public key type
    enum {
        KEY_NO_OOB,
        KEY_OOB_PUBLIC
    }

    // out of bounds authentication mode
    enum {
        AUTH_NO_OOB,
        AUTH_STATIC_OOB,
        AUTH_OUTPUT_OOB,
        AUTH_INPUT_OOB
    }

    // authentication action values
    enum {
        ACTION_BLINK,
        ACTION_BEEP,
        ACTION_VIBRATE,
        ACTION_OUTPUT_NUMERIC,
        ACTION_OUTPUT_ALPHANUMERIC
    }

    class StartPDU extends ProvisioningPDU {

        hidden var algorithm;
        hidden var keyType;
        hidden var authMethod;
        hidden var authAction;
        hidden var authSize;

        function initialize(algorithm, keyType, authMethod, authAction, authSize) {
            ProvisioningPDU.initialize();
            self.type = PROV_START;
            self.algorithm = algorithm;
            self.keyType = keyType;
            self.authMethod = authMethod;
            self.authAction = authAction;
            self.authSize = authSize;
        }

        function serialize() {
            var bytes = [self.type, self.algorithm, self.keyType, self.authMethod, self.authAction, self.authSize]b;
            return bytes;
        }

    }

}