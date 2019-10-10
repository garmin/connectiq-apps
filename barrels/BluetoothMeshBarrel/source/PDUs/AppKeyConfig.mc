using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class AppKeyConfig {

        static const APP_KEY_CONFIG_ADD_OPCODE = [0x00]b;
        static const APP_KEY_CONFIG_STATUS_OPCODE = [0x80, 0x03]b;
        static const APP_KEY_CONFIG_BIND_OPCODE = [0x80, 0x3d]b;
        static const APP_KEY_CONFIG_BIND_STATUS_OPCODE = [0x80, 0x3e]b;
        static const PUBLISH_CONFIG_OPCODE = [0x03]b;
        static const SUBSCRIBE_CONFIG_OPCODE = [0x80, 0x1b]b;
        static const PUBLISH_CONFIG_STATUS_OPCODE = [0x80, 0x19]b;
        static const SUBSCRIPTION_STATUS_OPCODE = [0x80, 0x1f]b;

        static function getAddAppKeyConfig(netKeyIndex, appKeyIndex, appKey) {
            var parameters = [appKeyIndex & 0xff, ((netKeyIndex & 0x0f) << 4) + ((appKeyIndex >> 8) & 0x0f), ((netKeyIndex >> 4) & 0xff)]b;
            parameters.addAll(appKey);
            var payload = new AccessPayload(APP_KEY_CONFIG_ADD_OPCODE, parameters);
            return payload;
        }

        static function getBindAppKeyConfig(elementAddress, appKeyIndex, modelId) {
            var parameters = toBytesLittleEndian(elementAddress, 2);
            parameters.addAll(toBytesLittleEndian(appKeyIndex, 2));
            parameters.addAll(toBytesLittleEndian(modelId, 2));
            var payload = new AccessPayload(APP_KEY_CONFIG_BIND_OPCODE, parameters);
            return payload;
        }

        static function getSubscribeAddConfig(elementAddress, subscribeAddress, modelId) {
            var parameters = toBytesLittleEndian(elementAddress, 2);
            parameters.addAll(toBytesLittleEndian(subscribeAddress, 2));
            parameters.addAll(toBytesLittleEndian(modelId, 2));
            var payload = new AccessPayload(SUBSCRIBE_CONFIG_OPCODE, parameters);
            return payload;
        }

        // some of the configuration of this packet is hard coded for this use case
        // see bluetooth mesh documentation for details on how to adapt it
        static function getPublishAddConfig(elementAddress, publishAddress, modelId) {
            var parameters = toBytesLittleEndian(elementAddress, 2);
            parameters.addAll(toBytesLittleEndian(publishAddress, 2));
            parameters.addAll([0, 0]b); // app key index, credential flag, rfu
            parameters.addAll([0x50, 0x00, 0x43]b); // publish ttl, publish period, retransmit count, interval
            parameters.addAll(toBytesLittleEndian(modelId, 2));
            var payload = new AccessPayload(PUBLISH_CONFIG_OPCODE, parameters);
            return payload;
        }
    }

}