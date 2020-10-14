module GenericChannelHeartRateBarrel {

    // Represents the data available from any ANT+ Heart Rate strap
	class LegacyHeartData {
	        private static const COMPUTED_HR_INDEX = 7;
	        private static const INVALID_HR = 0;
	        
	        var computedHeartRate;
	        
	        function initialize() {
	            computedHeartRate = INVALID_HR;
	        }
	        
	        // Parses the computed heart rate value from the sensor
	        // @param payload, application data from an ANT broadcast message
	        function parse( payload ) {
	            computedHeartRate = payload[COMPUTED_HR_INDEX];
	        }
	        
	        // Sets the computed heart rate value to INVALID
	        function reset() {
	            computedHeartRate = INVALID_HR;
	        }
	}
}