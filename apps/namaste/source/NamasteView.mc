//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.WatchUi as Ui;
using Toybox.Application;
using Toybox.Timer;
using Toybox.Lang;

class NamasteView extends Ui.View {

    hidden var mModel;
    hidden var mController;
    hidden var mLabel;
    hidden var mPrompt;
    hidden var mTimer;

    // Initialize the View
    function initialize() {
        // Call the superclass initialize
        View.initialize();
        // Get the model and controller from the Application
        mModel = Application.getApp().model;
        mController = Application.getApp().controller;
        // Initialize the label
        mLabel = null;
        mPrompt = Ui.loadResource(Rez.Strings.prompt);
        mTimer = new Timer.Timer();

    }

    // Load your resources here
    function onLayout(dc) {
        // Load the layout from the resource file
        setLayout(Rez.Layouts.MainLayout(dc));
        // Cache the label away
        mLabel = View.findDrawableById("MainLabel");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        mTimer.start(method(:onTimer), 1000, true);
    }

    // Update the view
    function onUpdate(dc) {
        // If we are running, show a running clock
        if(mController.isRunning() ) {
            // Format time
            var time = mController.getTime();
            var timeString = Lang.format("$1$:$2$", [time / 60, (time % 60).format("%02d")]);
            // Update the time
            mLabel.setText(timeString);
        } else {
            mLabel.setText( mPrompt );
        }

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        mTimer.stop();
    }

    // Handler for the timer callback
    function onTimer() {
        Ui.requestUpdate();
    }

}
