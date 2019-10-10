using Toybox.WatchUi;

var infoText = "Disconnected";
var errorText = "";

class BluetoothMeshView extends WatchUi.View {

    hidden var delegate;

    function initialize(delegate) {
        self.delegate = delegate;
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.findDrawableById("text_value").setText(infoText);
        View.findDrawableById("error_value").setText(errorText);
        View.onUpdate(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

}
