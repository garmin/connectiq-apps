using Toybox.WatchUi;

class GenericAntPlusHeartRateFieldView extends WatchUi.SimpleDataField {

	hidden var mFitContributions;
    hidden var mHrChannel;

    // Set the label of the data field here.
    function initialize() {
        SimpleDataField.initialize();
        label = "Heart Rate 2";
    
        mFitContributions = new FitContributions(self);
        
        HeartRateSensor.getInstance().pair();

    }

    // The given info object contains all the current workout
    // information. Calculate a value and return it in this method.
    // Note that compute() and onUpdate() are asynchronous, and there is no
    // guarantee that compute() will be called before onUpdate().
    function compute(info) {
        // See Activity.Info in the documentation for available information.
        var heartRate = HeartRateSensor.getInstance().getHeartRate();
        mFitContributions.setHeartRateData(heartRate);
        return heartRate > 0 ? heartRate : "--";
    }
    
    function onNextMultisportLeg() {
    	mFitContributions.onNextMultisportLeg();
    }
    
    function onTimerLap() {
    	mFitContributions.onTimerLap();
    }
    
    function onTimerReset() {
    	mFitContributions.onTimerReset();
    }
    
    function onTimerPause() {
    	mFitContributions.onTimerPause();
    }
    
    function onTimerResume() {
    	mFitContributions.onTimerResume();
    }
    
    function onTimerStart() {
    	mFitContributions.onTimerStart();
    }
    
    function onTimerStop() {
    	mFitContributions.onTimerStop();
    }
}
