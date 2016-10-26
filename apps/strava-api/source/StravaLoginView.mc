//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
using Toybox.WatchUi as Ui;

// Ui delegate for the Login view
class LoginDelegate extends Ui.BehaviorDelegate {
    function initialize() {
        BehaviorDelegate.initialize();
    }

}

// Ui View that displays the message
// that directs the user to the phone
class LoginView extends Ui.View {

    hidden var _transaction;
    hidden var _running;

    // Constructor
    function initialize() {
        View.initialize();
        _transaction = new LoginTransaction(new LoginTransactionDelegate());
        _running = false;
    }

    // Handle layout
    function onLayout(dc) {
        setLayout(Rez.Layouts.LoginLayout(dc));
    }

    // Handle becoming visible
    function onShow() {
        // onShow can be called multiple times, so make sure
        // we only start the transaction once
        if(_running == false) {
            _transaction.go();
            _running = true;
        }
    }
}