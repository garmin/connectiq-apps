using Toybox.WatchUi;

enum {
    STATE_OFF,
    STATE_ON,
    STATE_UNKNOWN
}
var deviceState = STATE_UNKNOWN;
var deviceText = "";

class ControlView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.ControlLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        var text = "Unknown";
        var icon = Rez.Drawables.LightBulbUnknown;
        switch (deviceState) {
            case STATE_UNKNOWN:
                text = "Unknown";
                icon = Rez.Drawables.LightBulbUnknown;
                break;
            case STATE_ON:
                text = "On";
                icon = Rez.Drawables.LightBulbOn;
                break;
            case STATE_OFF:
                text = "Off";
                icon = Rez.Drawables.LightBulbOff;
                break;
        }
        View.findDrawableById("device_text").setText(deviceText);
        View.findDrawableById("state_text").setText(text);
        View.findDrawableById("icon").setBitmap(icon);
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}