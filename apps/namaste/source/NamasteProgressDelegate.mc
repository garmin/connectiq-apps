//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;

// This handles input while the progress bar is up
class NamasteProgressDelegate extends WatchUi.BehaviorDelegate {

    // Constructor
    function initialize() {
        BehaviorDelegate.initialize();
    }

    // Block the back button handling while the progress bar is up.
    function onBack() {
        return true;
    }

}