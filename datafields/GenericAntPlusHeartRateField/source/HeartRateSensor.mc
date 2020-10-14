using Toybox.Application;
using GenericChannelHeartRateBarrel as HrBarrel;

class HeartRateSensor extends HrBarrel.HeartRateSensorDelegate {

    hidden var mHrChannel = null;
    hidden var mlastHeartRateValue = null;

    hidden static var instance = null;
    static function getInstance() {
        if(instance == null) {
            instance = new HeartRateSensor();
        }
        return instance;
    }

    private function initialize() {
        HrBarrel.HeartRateSensorDelegate.initialize();
        mlastHeartRateValue = 0;
    }

    function pair() {

        if(mHrChannel != null) {
            mHrChannel.release();
            mHrChannel = null;
        }

        var deviceNumber = Application.getApp().getProperty("deviceNumber");
        var proximityPairing = Application.getApp().getProperty("proximityPairing");

		try {
	        mHrChannel = new HrBarrel.AntPlusHeartRateSensor(deviceNumber, proximityPairing);
	        mHrChannel.setDelegate(self);
	        mHrChannel.open();
        }
		catch (e) {
			System.println(e.getErrorMessage());
			System.println(e.printStackTrace());
		}
    }

    function getHeartRate() {
        return mlastHeartRateValue;
    }

    function onHeartRateSensorUpdate( computedHeartRate ) {
        mlastHeartRateValue = computedHeartRate;
    }

    function onHeartRateSensorPaired( extendedDeviceNumber ) {
        Application.getApp().setProperty("deviceNumber", extendedDeviceNumber);
    }
}
