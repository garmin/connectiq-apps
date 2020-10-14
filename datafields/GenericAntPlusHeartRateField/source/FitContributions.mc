using Toybox.WatchUi;
using Toybox.FitContributor as Fit;

const HEART_RATE_FIELD_RECORD_ID = 0;
const HEART_RATE_FIELD_SESSION_MIN_ID = 1;
const HEART_RATE_FIELD_SESSION_MAX_ID = 2;
const HEART_RATE_FIELD_SESSION_AVG_ID = 3;
const HEART_RATE_FIELD_LAP_MIN_ID = 4;
const HEART_RATE_FIELD_LAP_MAX_ID = 5;
const HEART_RATE_FIELD_LAP_AVG_ID = 6;

const HEART_RATE_NATIVE_NUM_RECORD_MESG = 3;

const HEART_RATE_NATIVE_NUM_SESSION_MIN_MESG = 64;
const HEART_RATE_NATIVE_NUM_SESSION_MAX_MESG = 17;
const HEART_RATE_NATIVE_NUM_SESSION_AVG_MESG = 16;

const HEART_RATE_NATIVE_NUM_LAP_MIN_MESG = 63;
const HEART_RATE_NATIVE_NUM_LAP_MAX_MESG = 16;
const HEART_RATE_NATIVE_NUM_LAP_AVG_MESG = 15;

const HEART_RATE_UNITS = "BPM";

class FitContributions {

    hidden var mHeartRateRecordField;
    hidden var mMinHeartRateSessionField;
    hidden var mMaxHeartRateSessionField;
    hidden var mAvgHeartRateSessionField;
    hidden var mMinHeartRateLapField;
    hidden var mMaxHeartRateLapField;
    hidden var mAvgHeartRateLapField;
    
	hidden var mTimerRunning = false;
	hidden var mSessionStats;
	hidden var mLapStats;

    function initialize(dataField) {
       
        mHeartRateRecordField = dataField.createField("heart_rate", HEART_RATE_FIELD_RECORD_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_RECORD_MESG, :mesgType=>Fit.MESG_TYPE_RECORD, :units=>HEART_RATE_UNITS });
        
        mMinHeartRateSessionField = dataField.createField("min_heart_rate", HEART_RATE_FIELD_SESSION_MIN_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_SESSION_MIN_MESG, :mesgType=>Fit.MESG_TYPE_SESSION, :units=>HEART_RATE_UNITS });
        mMaxHeartRateSessionField = dataField.createField("max_heart_rate", HEART_RATE_FIELD_SESSION_MAX_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_SESSION_MAX_MESG, :mesgType=>Fit.MESG_TYPE_SESSION, :units=>HEART_RATE_UNITS });
        mAvgHeartRateSessionField = dataField.createField("avg_heart_rate", HEART_RATE_FIELD_SESSION_AVG_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_SESSION_AVG_MESG, :mesgType=>Fit.MESG_TYPE_SESSION, :units=>HEART_RATE_UNITS });
        
        mMinHeartRateLapField = dataField.createField("min_heart_rate", HEART_RATE_FIELD_LAP_MIN_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_LAP_MIN_MESG, :mesgType=>Fit.MESG_TYPE_LAP, :units=>HEART_RATE_UNITS });
        mMaxHeartRateLapField = dataField.createField("max_heart_rate", HEART_RATE_FIELD_LAP_MAX_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_LAP_MAX_MESG, :mesgType=>Fit.MESG_TYPE_LAP, :units=>HEART_RATE_UNITS });
        mAvgHeartRateLapField = dataField.createField("avg_heart_rate", HEART_RATE_FIELD_LAP_AVG_ID, Fit.DATA_TYPE_UINT8, { :nativeNum=>HEART_RATE_NATIVE_NUM_LAP_AVG_MESG, :mesgType=>Fit.MESG_TYPE_LAP, :units=>HEART_RATE_UNITS });

		mSessionStats = new MinMaxAvg(false);
		mLapStats = new MinMaxAvg(false);
    }
    
    function setHeartRateData(heartrate) {
    	mHeartRateRecordField.setData(heartrate > 0 ? heartrate : 0xFF);
    	
    	if(mTimerRunning) {
    		mSessionStats.setData(heartrate);
    		mLapStats.setData(heartrate);
    		
			mMinHeartRateSessionField.setData(mSessionStats.min());
			mMaxHeartRateSessionField.setData(mSessionStats.max());
			mAvgHeartRateSessionField.setData(mSessionStats.avg());
			
			mMinHeartRateLapField.setData(mSessionStats.min());
			mMaxHeartRateLapField.setData(mSessionStats.max());
			mAvgHeartRateLapField.setData(mSessionStats.avg());
    	}
    }
    
    function onNextMultisportLeg() {
    	mSessionStats.reset();
    	mLapStats.reset();
    }

    function onTimerLap() {
    	mLapStats.reset();
    }
    
    function onTimerReset() {
    	mSessionStats.reset();
    	mLapStats.reset();
    }
    
    function onTimerPause() {
    	mTimerRunning = false;
    }
    
    function onTimerResume() {
        mTimerRunning = true;
    }
    
    function onTimerStart() {
        mTimerRunning = true;
    }

    function onTimerStop() {
        mTimerRunning = false;
    } 
}
