//
// Copyright 2015-2019 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.Application;
using Toybox.WatchUi;

class LidarThereminApp extends Application.AppBase {
    private var _view;
    private var _delegate;
    private var _controller;

    function initialize() {
        AppBase.initialize();

        _view = new LidarThereminView();
        _delegate = new LidarThereminDelegate();
        _controller = new LidarThereminController(_view);
    }

    // onStart() is called on application start up
    function onStart(state) {
        _controller.onStart();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
        _controller.onStop();
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ _view, _delegate ];
    }

}
