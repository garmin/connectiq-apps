//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

// Main view for the application
class StravaView extends Ui.View {
    var _transaction;
    var _divisors;
    var _labels;

    // Constructor
    function initialize() {
        View.initialize();

        var type = System.getDeviceSettings().distanceUnits;
        if( type == System.UNIT_METRIC ) {
            _divisors = {
                :swim => 1,
                :bike => 1000.0,
                :run => 1000.0,
                :total=>1000.0
            };
            _labels = {
                :swim=>"m",
                :bike=>"km",
                :run=>"km",
                :total=>"km"
            };
        } else {
            _divisors = {
                :swim => .914,
                :bike => 1609.0,
                :run => 1609.0,
                :total=>1609.0
            };
            _labels = {
                :swim=>"yd",
                :bike=>"mi",
                :run=>"mi",
                :total=>"mi"
            };
        }

    }


    // Function used to convert between units
    hidden function convert(model, name) {
        var value = model[name];
        return " " + (value / _divisors[name]).toNumber() + " " + _labels[name];
    }

    // Function called when the information is returned by the transaction
    function updateModel(model) {
        var view = View.findDrawableById("swim");
        view.setText( convert( model, :swim ) );
        view = View.findDrawableById("bike");
        view.setText( convert( model, :bike ) );
        view = View.findDrawableById("run");
        view.setText( convert( model, :run) );
        view = View.findDrawableById("total");
        view.setText( convert( model, :total) );
        Ui.requestUpdate();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.Summary(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        if (_transaction == null) {
            _transaction = new StravaSummaryTransaction( new StravaSummaryDelegate(self) );
            _transaction.go();
        }
    }

    // Update the view
    function onUpdate(dc) {
        // Get and show the current time

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }


}
