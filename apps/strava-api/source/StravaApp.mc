//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Application as App;

const ApiUrl = "https://www.strava.com/api/v3/";
const RedirectUri = "https://localhost";

// The Application class is the bootstrap for the
// widget. It handles app lifecycle
class StravaApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        var athleteId = getProperty("athlete_id");

        if(!System.getDeviceSettings().phoneConnected) {
            return [new ConnectToGcmView() ];
        } else if ( athleteId == null ) {
            return [ new LoginView(), new LoginDelegate() ];
        } else {
            return [ new StravaView() ];
        }
    }

}
