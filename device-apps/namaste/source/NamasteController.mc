//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Timer;
using Toybox.Application;
using Toybox.WatchUi;

using Toybox.WatchUi;
using Toybox.System;

// Controller class for the Namaste app. Controls
// the UI flow of the app and controlls FIT
// recording
class NamasteController
{
    var mTimer;
    var mModel;
    var mRunning;

    // Initialize the controller
    function initialize() {

        // Allocate a timer
        mTimer = null;
        // Get the model from the application
        mModel = Application.getApp().model;
        // We are not running (yet)
        mRunning = false;
    }

    // Start the recording process
    function start() {
        // Start the model's processing
        mModel.start();
        // Flag that we are running
        mRunning = true;
    }

    // Stop the recording process
    function stop() {
        // Stop the model's processing
        mModel.stop();
        // Flag that we are not running
        mRunning = false;
    }

    // Save the recording
    function save() {
        // Save the recording
        mModel.save();
        // Give the system some time to finish the recording. Push up a progress bar
        // and start a timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Saving...", null), new NamasteProgressDelegate(), WatchUi.SLIDE_DOWN);
        mTimer = new Timer.Timer();
        mTimer.start(method(:onExit), 3000, false);
    }

    function discard() {
        // Discard the recording
        mModel.discard();
        // Give the system some time to discard the recording. Push up a progress bar
        // and start a timer to allow all processing to finish
        WatchUi.pushView(new WatchUi.ProgressBar("Discarding...", null), new NamasteProgressDelegate(), WatchUi.SLIDE_DOWN);
        mTimer = new Timer.Timer();
        mTimer.start(method(:onExit), 3000, false);
    }

    // Are we running currently?
    function isRunning() {
        return mRunning;
    }

    // Get the recording time elapsed
    function getTime() {
        return mModel.getTimeElapsed();
    }

    // Handle the start/stip button
    function onStartStop() {
        if(mRunning) {
            stop();
            WatchUi.pushView(new Rez.Menus.MainMenu(), new NamasteMenuDelegate(), WatchUi.SLIDE_UP);
        } else {
            start();
        }
    }

    // Handle timing out after exit
    function onExit() {
        System.exit();
    }

}