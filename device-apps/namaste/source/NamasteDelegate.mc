//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.WatchUi as Ui;
using Toybox.ActivityRecording;
using Toybox.Application;

// The NamasteDelegate forwards the inputs to the
// NamasteController. One might say it _delegates_
// its responsibilities... what, okay, I'll stop
class NamasteDelegate extends Ui.BehaviorDelegate {

    // Controller class
    var mController;

    // Constructor
    function initialize() {
        // Initialize the superclass
        BehaviorDelegate.initialize();
        // Get the controller from the application class
        mController = Application.getApp().controller;
    }

    // Input handling of start/stop is mapped to onSelect
    function onSelect() {
        // Pass the input to the controller
        mController.onStartStop();
        return true;
    }

    // Block access to the menu button
    function onMenu() {
        return true;
    }

}