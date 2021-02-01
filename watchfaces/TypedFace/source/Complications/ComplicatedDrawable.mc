//
// Copyright 2015-2021 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//
import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

module Complicated {

    //! Draw a complication
    class ComplicationDrawable extends WatchUi.Drawable {
        private var _background as BitmapType = Application.loadResource(Rez.Drawables.complication);
        private var _updater as ModelUpdater?;
        private var _radius as Number;
        private var _centerX as Number;
        private var _centerY as Number;


        //! Constructor
        //! @param params Drawable arguments
        public function initialize(params as { :identifier as Object, :locX as Numeric, :locY as Numeric, :width as Numeric, :height as Numeric }) {   

            // Use the given point as the center point
            var backgroundWidth = _background.getWidth();
            var backgroundHeight = _background.getHeight();

            _centerX = params[:locX];
            _centerY = params[:locY];
            _radius = backgroundHeight / 2;

            var options = {
                :locX => params[:locX] - (backgroundWidth / 2),
                :locY => params[:locY] - (backgroundHeight / 2),
                :identifier => params[:identifier]
            };

            // Initialize superclass
            Drawable.initialize(options);
        }

        //! Set the model updater for the complication
        //! @param updater Model updater for the complication or null to disable
        public function setModelUpdater(updater as ModelUpdater?) as Void {
            _updater = updater;
        }

        //! Draw the complication
        //! @param dc Draw context
        public function draw(dc as Dc) as Void {            
            if (_updater != null) {
                var foregroundColor = Application.getApp().getProperty("ForegroundColor");
                var model = _updater.updateModel();
                var icon = model.icon;
                var iconWidth = icon.getWidth();
                var iconHeight = icon.getHeight();                

                // Draw the background
                dc.drawBitmap(locX, locY, _background);   
                // Draw the icon
                dc.drawBitmap(_centerX - (iconWidth / 2), _centerY - (iconHeight / 2), icon);            

                if (model instanceof PercentModel) {
                    // Handle drawing the percent
                    var percent = (model as PercentModel).percent;
                    
                    dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
                    dc.setPenWidth(2);

                    // Start drawing from the top
                    if(percent <= 25) {
                        dc.drawArc(_centerX, _centerY, _radius, Graphics.ARC_CLOCKWISE, 90, 90 - (360 * (percent / 100.0)));
                    } else {
                        dc.drawArc(_centerX, _centerY, _radius, Graphics.ARC_CLOCKWISE, 90, 0);
                        dc.drawArc(_centerX, _centerY, _radius, Graphics.ARC_CLOCKWISE, 0, 360 - (360 * ((percent - 25.0) / 100.0)));
                    }
                    
                } else if (model instanceof LabelModel) {
                    // Handle drawing the label
                    var label = (model as LabelModel).label;

                    // Draw a drop shadow behind the text
                    dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(_centerX+1, _centerY + (_radius * .75) +1, Graphics.FONT_SYSTEM_TINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                    // Draw the label
                    dc.setColor(foregroundColor, Graphics.COLOR_TRANSPARENT);
                    dc.drawText(_centerX, _centerY + (_radius * .75), Graphics.FONT_SYSTEM_TINY, label, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
                }
            }
        }
    }
}