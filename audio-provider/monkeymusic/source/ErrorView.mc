using Toybox.Graphics;
using Toybox.WatchUi;

// View to display an error message
class ErrorView extends WatchUi.View {

    // The error message
    private var mErrorMessage;

    // Constructor
    function initialize(errorMessage) {
        View.initialize();
        mErrorMessage = errorMessage;
    }

    // Update the View
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(dc.getWidth() / 2,
                    dc.getHeight() / 2,
                    Graphics.FONT_SMALL,
                    mErrorMessage,
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}