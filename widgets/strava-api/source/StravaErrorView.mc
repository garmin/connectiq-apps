//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.WatchUi;


// View to handle showing the Connect to GCM message
class ErrorView extends WatchUi.View {

    hidden var _message;

    function initialize(message) {
        View.initialize();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ErrorLayout(dc));
        var view = View.findDrawableById("Message");
        view.setText(_message.toString());
    }

}