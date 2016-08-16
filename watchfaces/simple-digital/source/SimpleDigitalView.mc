using Toybox.WatchUi as WatchUi;
using Toybox.Graphics as Gfx;
using Toybox.System as System;
using Toybox.Lang as Lang;
using Toybox.Application as App;
using Toybox.Time as Time;

class SimpleDigitalView extends WatchUi.WatchFace {

	function initialize() {
		WatchFace.initialize();
	}

	function onLayout(dc) {
		setLayout(Rez.Layouts.WatchFace(dc));
	}

	function onUpdate(dc) {
		var deviceSettings = System.getDeviceSettings();
		var is24Hour = deviceSettings.is24Hour;
		var fgColor = App.getApp().getProperty("ForegroundColor");
		var displayMonth = App.getApp().getProperty("DisplayMonth");

		// get local time
		var timeNow = Time.now();
		var timeInfo = Time.Gregorian.info(timeNow, Time.FORMAT_MEDIUM);
		var localHour = timeInfo.hour;

		// the hour is returned in 24-hr format; if user has watch configured
		//   to 12-hr format then we need to make some adjustments
		if (!is24Hour) {
			if (localHour > 12) {
				localHour = localHour - 12;
			}
			// when using the 12 hour clock, midnight is displayed as 12:00 AM (not 0:00 AM)
			if (localHour == 0) {
				localHour = 12;
			}
		} else {
			// otherwise, for 24-hr clock, display with a leading zero
			localHour = localHour.format("%02d");
		}

		var dateLabel = View.findDrawableById("DayOfWeekLabel");
		dateLabel.setColor(fgColor);

		if (displayMonth) {
			// grab the long info... (which may or may not be long format depending on CIQ version)
			var longTimeInfo =  Time.Gregorian.info(timeNow, Time.FORMAT_LONG);
			dateLabel.setText(longTimeInfo.day_of_week.toUpper());
			var monthLabel = View.findDrawableById("MonthLabel");
			monthLabel.setColor(fgColor);
			monthLabel.setText(longTimeInfo.day.format("%02d") +" " + longTimeInfo.month.toUpper());
		} else {
			dateLabel.setText(timeInfo.day_of_week.toUpper() + " " + timeInfo.day.format("%02d"));
	    }

		var timeLabel = View.findDrawableById("TimeLabel");
		timeLabel.setColor(fgColor);
		timeLabel.setText(Lang.format("$1$:$2$", [localHour, timeInfo.min.format("%02d")]));

		// This code will execute but the results will be overdrawn by the layout functionality with the
		//   call to the View.onUpdate() method below. However, if you move this line to after the call
		//   to View.onUpdate() you will see that the text is rendered.
		dc.drawText(deviceSettings.screenWidth/2, 10, Gfx.FONT_MEDIUM, "Garmin", Gfx.TEXT_JUSTIFY_CENTER);

		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);

		// Now that we've called the parent method, we can add any custom drawing code (and it won't be overdrawn by the layout)
		dateLabel.setColor(fgColor);
		dc.drawText(deviceSettings.screenWidth/2, deviceSettings.screenHeight-30, Gfx.FONT_MEDIUM, "Garmin", Gfx.TEXT_JUSTIFY_CENTER);
	}

}
