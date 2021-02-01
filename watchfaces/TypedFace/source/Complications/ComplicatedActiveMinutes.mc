//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to update the weekly active minutes
    class ActiveMinutes {
        //! Active minutes icon
        private var _icon as BitmapType;

        //! Constructor
        public function initialize() {
            _icon = Application.loadResource(Rez.Drawables.activeMinutes);
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var info = ActivityMonitor.getInfo();
            var activeMinutesWeek = info.activeMinutesWeek;
            var activeMinutesPercent = 0;
            if (activeMinutesWeek != null) {
                activeMinutesPercent = (activeMinutesWeek.total.toFloat() / info.activeMinutesWeekGoal.toFloat()) * 100;
            }

            if (activeMinutesPercent > 100.0) {
                activeMinutesPercent = 100.0;
            }
            return new PercentModel(activeMinutesPercent.toNumber(), _icon);
        }
    }
}