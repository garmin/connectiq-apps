using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;

class DeviceNumberPicker extends WatchUi.Picker {
    const mCharacterSet = "0123456789";
    hidden var mTitleText;
    hidden var mFactory;

    function initialize() {
        mFactory = new CharacterFactory(mCharacterSet, {:addDone=>true, :addDelete=>true});
        mTitleText = "";

        var string = Application.getApp().getProperty("deviceNumber").toString();
        var defaults = null;
        var titleText = Rez.Strings.ant_sensor_id;

        if(string != null) {
            mTitleText = string;
            titleText = string;
            defaults = [mFactory.getIndex(string.substring(string.length()-1, string.length()))];
        }

        mTitle = new WatchUi.Text({:text=>titleText, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_BOTTOM, :color=>Graphics.COLOR_WHITE});

        Picker.initialize({:title=>mTitle, :pattern=>[mFactory], :defaults=>defaults});
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        Picker.onUpdate(dc);
    }

    function addCharacter(character) {
        mTitleText += character;
        mTitle.setText(mTitleText);
    }

    function removeCharacter() {
        mTitleText = mTitleText.substring(0, mTitleText.length() - 1);

        if(0 == mTitleText.length()) {
            mTitle.setText(WatchUi.loadResource(Rez.Strings.ant_sensor_id));
        }
        else {
            mTitle.setText(mTitleText);
        }
    }

    function getTitle() {
        return mTitleText.toString();
    }

    function getTitleLength() {
        return mTitleText.length();
    }

    function isDone(value) {
        return mFactory.isDone(value);
    }
    
    function isDelete(value) {
        return mFactory.isDelete(value);
    }
}

class DeviceNumberPickerDelegate extends WatchUi.PickerDelegate {
    hidden var mPicker;

    function initialize(picker) {
        PickerDelegate.initialize();
        mPicker = picker;
    }

    function onCancel() {
        if(0 == mPicker.getTitleLength()) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        else {
            mPicker.removeCharacter();
        }
    }

    function onAccept(values) {
        if(mPicker.isDelete(values[0])) {
        	mPicker.removeCharacter();
        }
        else if(mPicker.isDone(values[0])) {
        	if(mPicker.getTitle().length() == 0) {
                
                Application.getApp().setProperty("deviceNumber", 0);
            }
            else {
                Application.getApp().setProperty("deviceNumber", mPicker.getTitle().toNumber());
            }
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
        else {
        	mPicker.addCharacter(values[0]);
        }
    }

}
