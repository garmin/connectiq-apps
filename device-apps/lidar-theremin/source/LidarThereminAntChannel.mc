//
// Copyright 2015-2019 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Ant;
using Toybox.Time;

class LidarThereminAntChannel extends Ant.GenericChannel {
    private const DEVICE_TYPE = 16;
    private const PERIOD = 8192;
    private const RADIO_FREQUENCY = 66;

    private const MEAS_PG = 16;
    private const SET_MEAS_MODE_PG = 48;
    private const TRIG_MEAS_PG = 49;

    private var _chanAssign;
    private var _data;
    private var _searching;
    private var _pastEventCount;
    private var _deviceCfg;
    private var _measurementCallback;
    private var _model;

    // keeps track of how many messages we've sent to the lidar
    private var _controlSeq = 0;


    public function initialize() {

        // Get the channel
        _chanAssign = new Ant.ChannelAssignment(
            Ant.CHANNEL_TYPE_RX_NOT_TX, // slave bidirectional
            Ant.NETWORK_PUBLIC);
        GenericChannel.initialize(method(:onMessage), _chanAssign);

        // Set the configuration
        _deviceCfg = new Ant.DeviceConfig( {
            :deviceNumber => 0,                 //Wildcard our search
            :deviceType => DEVICE_TYPE,
            :transmissionType => 0,
            :messagePeriod => PERIOD,
            :radioFrequency => RADIO_FREQUENCY,
            :searchTimeoutLowPriority => 12,    //Timeout in 30s
            :searchThreshold => 0} );           //Pair to all transmitting sensors
        GenericChannel.setDeviceConfig(_deviceCfg);
        _model = new LidarThereminModel();
        _searching = true;
    }

    public function open() {
        // Open the channel
        GenericChannel.open();
        _pastEventCount = 0;
        _searching = true;
    }

    public function closeSensor() {
        GenericChannel.close();
        _measurementCallback = null;
    }

    public function onMessage(msg) {
        // Parse the payload
        var payload = msg.getPayload();

        if (msg.deviceType == DEVICE_TYPE and payload[0] == MEAS_PG) {
            // if this is our first message and from a rangefinder,
            // connect to that device specifically
            if (_searching) {
                // send Set Measurement Mode page. See rangefinder documentation for detail, but:
                // Byte 1 is data page number. Byte 2 is sequence number
                // Bytes 2 and 3 and 5 and 6 are 0xFF, reserved for future use
                // Byte 4 is measurement mode. 0x00 is async, 0x01 is sync, and 0xFF is always on
                // Byte 7 is measurement delay interval, only applicable if in sync mode
                sendAcknowledge([SET_MEAS_MODE_PG, _controlSeq, 0xFF, 0xFF, 0x01, 0xFF, 0xFF, 0x00]);

                _deviceCfg = new Ant.DeviceConfig( {
                    :deviceNumber => msg.deviceNumber,
                    :deviceType => DEVICE_TYPE,
                    :transmissionType => 0,
                    :messagePeriod => PERIOD,
                    :radioFrequency => RADIO_FREQUENCY,
                    :searchTimeoutLowPriority => 12,    //Timeout in 30s
                    :searchThreshold => 0} );           //Pair to all transmitting sensors
                GenericChannel.setDeviceConfig(_deviceCfg);
                _searching = false;
            }

            processMeasurement(payload);
        }
    }

    public function requestMeasurement() {
        // Trigger measurement
        // Byte 1 is data page number. Byte 2 is sequence number
        // The rest are 0xFF, reserved for future use
        sendAcknowledge([TRIG_MEAS_PG, _controlSeq, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF]);
    }

    public function sendAcknowledge(data) {
        var message = new Ant.Message();
        message.setPayload(data);
        GenericChannel.sendAcknowledge(message);
        _controlSeq = (_controlSeq + 1) % 255;
    }

    public function processMeasurement(payload) {
        // byte 7 is the MSB of distance, byte 6 is the LSB
        var distance = payload[7] << 8 + payload[6];

        _model.setDistance(distance);
        _measurementCallback.invoke(_model);
    }

    public function setMeasurementCallback(callback) {
        _measurementCallback = callback;
    }
}