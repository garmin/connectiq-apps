using Toybox.WatchUi;

class AppSettingsDelegate extends WatchUi.Menu2InputDelegate {
	hidden var mMenu;
	function initialize() {
		Menu2InputDelegate.initialize();
    }
    
	function onSelect(item) {
		if( item.getId().equals("deviceNumber") ) {
			var deviceNumberPicker = new DeviceNumberPicker();
			WatchUi.pushView(deviceNumberPicker, new DeviceNumberPickerDelegate(deviceNumberPicker), WatchUi.SLIDE_IMMEDIATE );
		}
		else if( item.getId().equals("proximityPairing") ) {
			Application.getApp().setProperty("proximityPairing", item.isEnabled());
			HeartRateSensor.getInstance().pair();
		}
	}
	
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class AppSettingsView extends WatchUi.Menu2 {
	hidden var mDeviceNumber;
	
	function initialize() {
		Menu2.initialize({:title=>"Settings"});
		
		mDeviceNumber = Application.getApp().getProperty("deviceNumber");
		
		addItem(
			new WatchUi.MenuItem(
				Rez.Strings.ant_sensor_id,
				mDeviceNumber.toString(),
				"deviceNumber",
				{}
				)
			);
			
		addItem(
			new WatchUi.ToggleMenuItem(
				Rez.Strings.proximity_pairing,
				null,
				"proximityPairing",
				Application.getApp().getProperty("proximityPairing"),
				{}
			)
		);
	}
	
	function onShow() {
		var deviceNumber = Application.getApp().getProperty("deviceNumber");
		if(deviceNumber != mDeviceNumber) {
			mDeviceNumber = deviceNumber;
		
			var item = self.getItem(0);
			if(item != null) {
				item.setSubLabel(mDeviceNumber.toString());
				self.updateItem(item, 0);
			}
			
			HeartRateSensor.getInstance().pair();
		}
	}
}
	
	