using Toybox.System;
using Toybox.Lang;

module BluetoothMeshBarrel {

    class GenericOnOff {

        enum {
            OFF,
            ON
        }

        static const GENERIC_ONOFF_GET_OPCODE = [0x82, 0x01]b;
        static const GENERIC_ONOFF_SET_ACK_OPCODE = [0x82, 0x02]b;
        static const GENERIC_ONOFF_SET_UACK_OPCODE = [0x82, 0x03]b;
        static const GENERIC_ONOFF_STATUS_OPCODE = [0x82, 0x04]b;

        static function GENERIC_ONOFF_PARAMS(state, transactionId) { return [state, transactionId]b; }

        static var transactionId = 0;

        // prepares a generic on off set acknowledged packet for sending
        static function setAcknowledged(networkManager, state, dst) {
            if(!(networkManager instanceof NetworkManager and state instanceof Lang.Number and dst instanceof Device)) {
                throw new Lang.UnexpectedTypeException();
            }
            var params = GENERIC_ONOFF_PARAMS(state, transactionId);
            var payload = new AccessPayload(GENERIC_ONOFF_SET_ACK_OPCODE, params);
            transactionId = (transactionId + 1) % 0xff;

            return processPdu(networkManager, dst, payload);
        }

        // prepares a generic on off set unacknowledged packet for sending
        static function setUnacknowledged(networkManager, state, dst) {
            if(!(networkManager instanceof NetworkManager and state instanceof Lang.Number and dst instanceof Device)) {
                throw new Lang.UnexpectedTypeException();
            }
            var params = GENERIC_ONOFF_PARAMS(state, transactionId);
            var payload = new AccessPayload(GENERIC_ONOFF_SET_UACK_OPCODE, params);
            transactionId = (transactionId + 1) % 0xff;
            return processPdu(networkManager, dst, payload);
        }

        // prepares a generic on off get status packet for sending
        static function getStatus(networkManager, dst) {
            if(!(networkManager instanceof NetworkManager && dst instanceof Device)) {
                throw new Lang.UnexpectedTypeException("something went wrong!");
            }
            var payload = new AccessPayload(GENERIC_ONOFF_GET_OPCODE, []b);
            transactionId++;

            return processPdu(networkManager, dst, payload);
        }

        // prepares a packet for sending. Returns an encrypted network pdu
        private static function processPdu(networkManager, dst, payload) {
            var transportPdu = new TransportAccessPDU(true, MIC_SIZE_4, payload);
            var networkPdu = NetworkPDU.newInstance(networkManager, false, dst, transportPdu);
            return networkPdu.encrypt(networkManager);
        }

    }
}