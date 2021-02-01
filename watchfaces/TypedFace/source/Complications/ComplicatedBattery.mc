//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to generate the battery model
    class Battery {

        //! Battery states
        enum BatteryStates {
            BATTERY_QUARTER,
            BATTERY_HALF,
            BATTERY_FULL,
            BATTERY_CHARGING,
            BATTERY_MAX
        }

        //! Battery icons
        private var _icons as Array<BitmapType>;    

        //! Constructor
        public function initialize() {
            _icons = new Array<BitmapType>[BATTERY_MAX];

            _icons[BATTERY_QUARTER] = Application.loadResource(Rez.Drawables.batteryQuarter);
            _icons[BATTERY_HALF] = Application.loadResource(Rez.Drawables.batteryHalf);
            _icons[BATTERY_FULL] = Application.loadResource(Rez.Drawables.batteryFull);
            _icons[BATTERY_CHARGING] = Application.loadResource(Rez.Drawables.batteryCharging);
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var stats = System.getSystemStats();
            var battery = stats.battery;
            var icon;

            if (stats.charging) {
                icon = BATTERY_CHARGING;
            } else if (battery > 60) {
                icon = BATTERY_FULL;
            } else if (battery > 25 && battery <= 60) {
                icon = BATTERY_HALF;
            } else {
                icon = BATTERY_QUARTER;
            }

            // Return the new model
            return new PercentModel(battery.toNumber(), _icons[icon]);
        }    

    }

}