//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Lang;
import Toybox.Graphics;

//! Module for all the complications.
//! Fun fact! Avril Lavigne's "Complicated" came out in 2002 and is now considered "Dad Rock". How does that make you feel?
module Complicated {
    //! Model for complications that have the following appearance:
    //! 1. An arc fill around a circle
    //! 2. A icon or number in the middle
    //! This class is the standard return value for all of them.
    class PercentModel {
        //! Percent to fill the arc.
        public var percent as Number;
        //! Graphics.BitmapType is a new named type that covers
        //! all image representations
        public var icon as BitmapType;

        //! Constructor
        //! @param p 0 - 100 value for progress bar
        //! @param i Icon to display
        public function initialize(p as Number, i as BitmapType) {
            // Initializing the members in the constructor
            // allows you to declare them as not being null
            percent = p;
            icon = i;
        }
    }

    //! Model for complications that have the following appearance
    //! 1. An identifier icon
    //! 2. A label under the icon
    class LabelModel {
        //! Label
        var label as String;
        //! Icon
        var icon as BitmapType;

        //! Constructor
        //! @param label Text label to display under icon
        //! @param icon Icon to display
        public function initialize(l as String, i as BitmapType) {
            label = l;
            icon = i;
        }
    }

    typedef Model as PercentModel or LabelModel;

    //! Interface that covers our various
    //! complication update callbacks
    typedef ModelUpdater as interface {
        //! Function that provides an updated status 
        //! for the complication
        function updateModel() as Complicated.Model;
    };


    //! Enum of all available complications
    enum Complications {
        COMPLICATED_BATTERY,
        COMPLICATED_STEPS,
        COMPLICATED_DATE,
        COMPLICATED_HR,
        COMPLICATED_ACTIVE_MINUTES_WEEK
    }

    //! Return an updater based on the requested complication
    //! @param complication Complication requested
    //! @return Model updater object
    function getComplication(complication as Complications or Number) as ModelUpdater? {
        // Note that we haven't declared that any of these
        // meet the interface. Because they match the declarations
        // they automatically work. 
        switch (complication) {
            case COMPLICATED_BATTERY:
                return new Complicated.Battery();
            case COMPLICATED_STEPS:
                return new Complicated.Steps();
            case COMPLICATED_DATE:
                return new Complicated.Date();
            case COMPLICATED_HR:
                return new Complicated.HeartRate();
            case COMPLICATED_ACTIVE_MINUTES_WEEK:
                return new Complicated.ActiveMinutes();
            default:
                return null;
        }
    }

}