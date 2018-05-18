using Toybox.Application;
using Toybox.Graphics;
using Toybox.Media;
using Toybox.WatchUi;

// View to configure what songs to play
class ConfigurePlaybackView extends WatchUi.View {

    // Indicates if the menu has been pushed or not
    private var mMenuShown = false;
    // Message to show in the view
    private var mMessage = "";

    // Constructor
    function initialize() {
        View.initialize();

        // Push the authentication view if not authenticated
        var token = Application.getApp().getProperty(Properties.AUTHENTICATION_TOKEN);
        if (token == null) {
            WatchUi.pushView(new OauthView(), null, WatchUi.SLIDE_IMMEDIATE);
        }
    }

    // If the page hasn't been shown yet push the Configure playback menu. Otherwise pop the page.
    function onShow() {
        if (!mMenuShown) {
            // See how many songs are the the system
            var app = Application.getApp();
            var songs = app.getProperty(Properties.SONGS);

            // If there are any songs, push the configure playback menu. Otherwise show an error message.
            if ((songs != null) && (songs.size() != 0)) {
                WatchUi.pushView(new ConfigurePlaybackMenu(), new ConfigurePlaybackMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
            } else {
                mMessage = "No songs on\nthe system";
            }
            mMenuShown = true;
        } else {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }

    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER );
    }
}
