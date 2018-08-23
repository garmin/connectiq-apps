//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Communications;
using Toybox.Application;
using Toybox.System;

// TransactionDelegate class that handles response to the athlete's stats summary
class StravaSummaryDelegate extends TransactionDelegate {
    hidden var _view;

    // Constructor
    function initialize(view) {
        TransactionDelegate.initialize();
        _view = view;
    }

    // Handle a error from the server
    function handleError(code) {
        var msg = WatchUi.loadResource( Rez.Strings.error );
        msg += code;
        Ui.switchToView(new ErrorView(msg), null, Ui.SLIDE_IMMEDIATE);
    }

    // Response handler.
    function handleResponse( data ) {
        // Construct the model class and populate the results
        var result = new StravaModel();
        result.swim = data["recent_swim_totals"]["distance"].toNumber();
        result.bike = data["recent_ride_totals"]["distance"].toNumber();
        result.run  = data["recent_run_totals"]["distance"].toNumber();
        result.total = result.swim + result.bike + result.run;
        // Pass the results onto the view
        _view.updateModel(result);
        _view = null;
    }
}

// Transaction class to request the athlete's summary stats
class StravaSummaryTransaction extends Transaction {

    // Constructor
    function initialize(delegate) {
        // Initialize the parent class
        Transaction.initialize(delegate);
        // The action is based on the athlete id, so get that.
        var athleteId = Application.getApp().getProperty("athlete_id");
        // Define the transaction action
        _action = "athletes/" + athleteId + "/stats";
    }
}

