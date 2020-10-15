using Toybox.Ant;

module GenericChannelHeartRateBarrel {

    class AntPlusHeartRateSensor extends Toybox.Ant.GenericChannel {
        // Channel configuration
        private const CHANNEL_PERIOD = 8070;    // ANT+ HR Channel Period
        private const DEVICE_TYPE = 120;        // ANT+ HR Device Type
        private const RADIO_FREQUENCY = 57;     // ANT+ Radio Frequency
        private const SEARCH_TIMEOUT = 1;       // 2.5 second search timeout
        private const DISABLED = 0;

        // Message indexes
        private const MESSAGE_ID_INDEX = 0;
        private const MESSAGE_CODE_INDEX = 1;

        // Proximity bin defines
        private const WILDCARD_PAIRING = 0;
        private const CLOSEST_SEARCH_BIN = 1;
        private const FARTHEST_SEARCH_BIN = 10;
        private const PROXIMITY_DISABLED = 0;

        // Variables
        hidden var chanAssign;
        hidden var deviceCfg;
        hidden var deviceNumber;
        hidden var transmissionType;
        hidden var searchThreshold;
        hidden var hrSensorDelegate;
        hidden var onUpdateCallback;
        hidden var onPairedCallback;
        hidden var isClosed;    // Tracks when the app wants us to stay closed
        hidden var isPaired;    // Paired is an event we only fire once

        var data;

        // Initializes AntPlusHeartRateSensor, configures and opens channel
        // @param extendedDeviceNumber, a 20-bit ANT+ defined integer used for identification
        // @param isProximityPairing, true enables pairing based on signal strength from strongest to weakest
        function initialize( extendedDeviceNumber, isProximityPairing ) {

            if (extendedDeviceNumber == WILDCARD_PAIRING) {
                deviceNumber = WILDCARD_PAIRING;
                transmissionType = WILDCARD_PAIRING;
            } else {
                parseExtendedDeviceNumber( extendedDeviceNumber );
            }

            if ( isProximityPairing ) {
                searchThreshold = CLOSEST_SEARCH_BIN;
            } else {
                searchThreshold = WILDCARD_PAIRING;
            }

            data = new LegacyHeartData();

            // Create channel assignment
            chanAssign = new Toybox.Ant.ChannelAssignment(
            Toybox.Ant.CHANNEL_TYPE_RX_NOT_TX,
            Toybox.Ant.NETWORK_PLUS);

            // Initialize the channel through the superclass
            GenericChannel.initialize( method(:onMessage), chanAssign );

            // Set the configuration
            deviceCfg = new Toybox.Ant.DeviceConfig( {
                :deviceNumber => deviceNumber,
                :deviceType => DEVICE_TYPE,
                :transmissionType => transmissionType,
                :messagePeriod => CHANNEL_PERIOD,
                :radioFrequency => RADIO_FREQUENCY,
                :searchTimeoutLowPriority => SEARCH_TIMEOUT,
                :searchTimeoutHighPriority => DISABLED,
                :searchThreshold => searchThreshold} );
            GenericChannel.setDeviceConfig( deviceCfg );

            // The channel was initialized into a CLOSED state
            isClosed = true;

            // The channel has not paired with a device yet
            isPaired = false;

            hrSensorDelegate = null;
            onUpdateCallback = null;
        }

        // Opens the generic channel
        function open() {
            isClosed = false;   // Externally opening the channel means it is no longer CLOSED
            deviceCfg.searchThreshold = searchThreshold;
            GenericChannel.setDeviceConfig( deviceCfg );
            GenericChannel.open();
        }

        // Closes the generic channel
        function close() {
            isClosed = true;    // Externally closing the channel means it will stay CLOSED
            GenericChannel.close();
        }

        // Release the generic channel
        // Once the channel is released it cannot be re-opened or closed again
        function release() {
            GenericChannel.release();
        }

        // Sets the delegate handler for asynchronous sensor events
        // An application can only have 1 registered delegate. Subsequent calls to this function will override the current delegate.
        // Setting this to null will remove any registered delegate.
        function setDelegate( delegate ) {
            hrSensorDelegate = delegate;

            if ( hrSensorDelegate != null ) {
                onUpdateCallback = hrSensorDelegate.method(:onHeartRateSensorUpdate);
                onPairedCallback = hrSensorDelegate.method(:onHeartRateSensorPaired);
            } else {
                onUpdateCallback = null;
                onPairedCallback = null;
            }
        }

        // Returns the current extended device number.
        // This will change to the sensor's value once paired.
        function getExtendedDeviceNumber () {
            return (deviceNumber | ((transmissionType & 0xF0) << 12));
        }

        // On new ANT Message, parses the message
        // @param msg, a Toybox.Ant.Message object
        function onMessage( msg ) {
            // Parse the payload
            var payload = msg.getPayload();

            if ( Toybox.Ant.MSG_ID_CHANNEL_RESPONSE_EVENT == msg.messageId ) {
                if ( Toybox.Ant.MSG_ID_RF_EVENT == payload[MESSAGE_ID_INDEX] ) {
                    // React to changes in the ANT channel state
                    switch(payload[MESSAGE_CODE_INDEX]) {

                        // Drop to search occurs after 2s elapse or 8 RX_FAIL events, whichever comes first
                        case Toybox.Ant.MSG_CODE_EVENT_RX_FAIL_GO_TO_SEARCH:
                            // Reset HR data after missing over 2s of messages
                            data.reset();
                            if ( onUpdateCallback != null ) {
                                onUpdateCallback.invoke(data.computedHeartRate);
                            }
                            break;

                        // Search timeout occurs after SEARCH_TIMEOUT duration passes without pairing
                        case Toybox.Ant.MSG_CODE_EVENT_RX_SEARCH_TIMEOUT:
                            // Only change the search threshold if proximity pairing is enabled
                            if ( searchThreshold != PROXIMITY_DISABLED ) {
                                // Expand search radius after each channel close event due to search timeout
                                if ( searchThreshold < FARTHEST_SEARCH_BIN ) {
                                    searchThreshold++;
                                } else {
                                    // Pair to any signal strength if we've searched every bin
                                    searchThreshold = WILDCARD_PAIRING;
                                }

                            }
                            break;

                        // Close event occurs after a search timeout or if it was requested
                        case Toybox.Ant.MSG_CODE_EVENT_CHANNEL_CLOSED:
                            // Reset HR data after the channel closes
                            data.reset();

                            if ( onUpdateCallback != null ) {
                                onUpdateCallback.invoke(data.computedHeartRate);
                            }

                            // If ANT closed the channel, re-open it to continue pairing
                            if(!isClosed) {
                                open();
                            }
                            break;
                    }
                }

            } else if ( Toybox.Ant.MSG_ID_BROADCAST_DATA == msg.messageId ) {
                data.parse( payload );    // Parse payload into data

                if ( onUpdateCallback != null ) {
                    onUpdateCallback.invoke(data.computedHeartRate);  // Pass data to callback
                }

                if ( !isPaired ) {
                    isPaired = true;    // Only fire paired event once

                    deviceNumber = msg.deviceNumber;
                    transmissionType = msg.transmissionType;

                    if ( onPairedCallback != null ) {
                        onPairedCallback.invoke(getExtendedDeviceNumber());
                    }
                }
            }
        }

        // Parses the 20-bit extended device number into its two separate components
        // @param extendedDeviceNumber, a 20-bit ANT+ defined integer used for identification
        private function parseExtendedDeviceNumber( extendedDeviceNumber ) {
            // Parse the extended device number for the upper nibble
            transmissionType = ((extendedDeviceNumber >> 12) & 0xF0) | 0x01;
            deviceNumber = extendedDeviceNumber & 0xFFFF;
        }
    }
}
