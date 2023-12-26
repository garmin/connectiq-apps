//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Application;
import Toybox.Time.Gregorian;
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.System;

module Complicated {

    //! Class to update the steps
    class Date {
        //! Steps icon
        private var _icon as BitmapType;

        //! Constructor
        public function initialize() {
            _icon = Application.loadResource(Rez.Drawables.calendar);
        }

        //! Update the model 
        public function updateModel() as Complicated.Model {
            var info = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var dateString = Lang.format("$1$/$2$", [info.month, info.day]);
            return new LabelModel(dateString, _icon);
        }
    }
}