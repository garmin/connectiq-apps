using Toybox.Application;

class GenericAntPlusHeartRateFieldApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new GenericAntPlusHeartRateFieldView() ];
    }
    
    // Triggered by settings change in GCM
    function onSettingsChanged() { 
	     HeartRateSensor.getInstance().pair();
	}
	
	function getSettingsView() {
		return [ new AppSettingsView(), new AppSettingsDelegate() ];
	}
}
