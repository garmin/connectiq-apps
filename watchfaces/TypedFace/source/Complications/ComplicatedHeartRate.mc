//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to update the steps
    class HeartRate {
        //! Steps icon
        private var _icon as BitmapType;

        //! Constructor
        public function initialize() {
            _icon = Application.loadResource(Rez.Drawables.heart);
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var info = Activity.getActivityInfo();
            var hr = info.currentHeartRate;

            var hrString = (hr == null) ? "--" : hr.toString();

            return new LabelModel(hrString, _icon);
        }
    }
}