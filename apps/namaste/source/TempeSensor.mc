//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

/*
Temperature device uses ANT+ Environment Device Profile
Device transmits at 0.5 Hz
On receiving any page from a display device, the temperature sensor will transmit at 4 Hz for 30 second timeout.
Receiving any page from the display device shall reset the 30 second timeout value.
The temperature sensor will default transmit data page 1 (basic temperature data page)
Profile supports FIT File protocol
* Daily Monitoring File - Daily averages over the last year
* Monitoring File - detailed data (5 min logging interval) for the last week are available over ANT-FS.
Profile supports broadcast ANT-FS
* Braodcast ANT-FS is requested using data page 70 as per ANT+ Common Pages document and ANT-FS Specification.
*/
using Toybox.Ant;
using Toybox.System;
using Toybox.Time;


// Tempe sensor communicates with a ANT+ temperature sensor
// see https://www.thisisant.com/developer/ant-plus/device-profiles#524_tab
class TempeSensor extends Ant.GenericChannel
{
    const DEVICE_TYPE = 25;
    const PERIOD = 65535;

    hidden var chanAssign;

    var data;
    var searching;
    var pastEventCount;
    var deviceCfg;
    var tempDataAvailable = false;

    // Inner POJO class for capturing
    // temperature information
    class TempeData {
        var eventCount;
        var lowTemp;
        var highTemp;
        var currentTemp;

        function initialize() {
            eventCount = 0;
            lowTemp = 0;
            highTemp = 0;
            currentTemp = 0;
        }
     }

    // Page class to parse the ANT payload
    class TempeDataPage {
        static const PAGE_NUMBER = 1;

        // More information how to get the environment data
        // https://confluence.consumer.garmin.com/display/ant/Environment+Sensor+Device+Profile
        function parse(payload, data) {
            data.eventCount = parseEventCount(payload);
            data.lowTemp = parseLowTemp(payload);
            data.highTemp = parseHighTemp(payload);
            data.currentTemp = parseCurrentTemp(payload);
        }


        hidden function parseEventCount(payload) {
            return payload[2];
        }

        hidden function parseLowTemp(payload) {
            var intHigh = (payload[4] & 0xF0 << 4);
            var lowTemp;
            if (intHigh == 3840) {
                lowTemp = (~payload[3] & 0xFF + 1) * -1;
            } else {
                lowTemp = payload[3] | intHigh;
            }
            lowTemp = lowTemp / 10f;
            if ((lowTemp < -205) || (lowTemp > 205) ) {
                return 0;
            }

            return lowTemp;
        }

        hidden function parseHighTemp(payload) {
            var intHigh = payload[5] & 0x80;
            var highTemp;
            if (intHigh > 0) {
                highTemp = ( (payload[5] << 4) | (payload[4] & 0xF) );
                highTemp = (~highTemp & 0xFF + 1) * -1;
            }
            else {
                highTemp = ( (payload[5] << 4) | (payload[4] & 0xF) );
            }
            highTemp = highTemp / 10f;
            if ((highTemp < -205) || (highTemp > 205) ) {
                return 0;
            }

            return highTemp;
        }

        hidden function parseCurrentTemp(payload) {
            var intHigh = payload[7] & 0x80;
            var currentTemp;
            if (intHigh > 0) {
                currentTemp = ((payload[7] & 0xF) << 8) | payload[6];
                currentTemp = (~currentTemp & 0xFFF + 1) * -1;
            }
            else {
                currentTemp = (payload[7] << 8) | payload[6];
            }
            currentTemp = currentTemp / 100f;
            if ((currentTemp < -327) || (currentTemp > 327) ) {
                return 0;
            }
            return currentTemp;
        }
    }

    // Constructor
    function initialize() {
        // Get the channel
        chanAssign = new Ant.ChannelAssignment(
            Ant.CHANNEL_TYPE_RX_NOT_TX,
            Ant.NETWORK_PLUS);
        GenericChannel.initialize(method(:onMessage), chanAssign);

        // Set the configuration
        deviceCfg = new Ant.DeviceConfig( {
            :deviceNumber => 0,                 //Wildcard our search
            :deviceType => DEVICE_TYPE,
            :transmissionType => 0,
            :messagePeriod => PERIOD,
            :radioFrequency => 57,              //Ant+ Frequency
            :searchTimeoutLowPriority => 10,    //Timeout in 25s
            :searchTimeoutHighPriority => 2,    //Timeout in 5s
            :searchThreshold => 0} );           //Pair to all transmitting sensors
        GenericChannel.setDeviceConfig(deviceCfg);

        data = new TempeData();
        searching = true;
    }

    // Get the current temperature
    // @return -1 if not paired, or current temperature if paired
    function getCurrentTemp() {
        if (searching) {
            return -1;
        } else {
            return data.currentTemp;
        }
    }

    // Start reading from a environment sensor
    function open() {
        // Open the channel
        GenericChannel.open();

        data = new TempeData();
        pastEventCount = 0;
        searching = true;
    }

    // Close the connection
    function closeSensor() {
        GenericChannel.close();
    }


    // Handle incoming information
    function onMessage(msg) {
        // Parse the payload
        var payload = msg.getPayload();

        if( Ant.MSG_ID_BROADCAST_DATA == msg.messageId ) {
            if( TempeDataPage.PAGE_NUMBER == (payload[0].toNumber() & 0xFF) ) {
                // Were we searching?
                if(searching) {
                    searching = false;

                    // Update our device configuration primarily to see the device number of the sensor we paired to
                    deviceCfg = GenericChannel.getDeviceConfig();
                }
                var dp = new TempeDataPage();
                dp.parse( msg.getPayload(), data );
                tempDataAvailable = true;
                // Check if the data has changed and we need to update the ui
                if( pastEventCount != data.eventCount ) {
                    pastEventCount = data.eventCount;
                }
            }
        } // end broadcast data

        else if( Ant.MSG_ID_CHANNEL_RESPONSE_EVENT == msg.messageId ) {
            if( Ant.MSG_ID_RF_EVENT == (payload[0] & 0xFF) ) {
                if( Ant.MSG_CODE_EVENT_CHANNEL_CLOSED == (payload[1] & 0xFF) ) {
                    open();
                }
                else if( Ant.MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH  == (payload[1] & 0xFF) ) {
                    searching = true;
                }
            }
            else{
                //It is a channel response.
            }
        } // end channel response event

    } // end on message

}