using Toybox.Application;
using Toybox.Graphics;
using Toybox.WatchUi;

// View to get the OAuth credentials from the user
class OauthView extends WatchUi.View {

    function initialize() {
        View.initialize();

        // Make the request to display the OAuth page in GCM
        Communications.registerForOAuthMessages(method(:onOAuthComplete));
        Communications.makeOAuthRequest(Constants.PROVIDER_URL, {"redirectUrl" => Constants.REDIRECT_URL}, Constants.REDIRECT_URL, Communications.OAUTH_RESULT_TYPE_URL, {"token" => "token", "errorMessage" => "errorMessage"});
    }

    // Update the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        dc.drawText(dc.getWidth() / 2,
                    dc.getHeight() / 2,
                    Graphics.FONT_SMALL,
                    "Sign into MonkeyMusic\nusing GCM",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Callback for OAuth completion
    function onOAuthComplete(data) {
        // If OK, store the token. Otherwise show the error.
        if ((data.responseCode == 200) && (data.data != null)) {
            var token = data.data["token"];
            if (token != null) {
                Application.getApp().setProperty(Properties.AUTHENTICATION_TOKEN, token);
                WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
            }
        } else if (data.data != null) {
            var message = "Unable to get token:\n" + data.data["errorMessage"];
            WatchUi.switchToView(new ErrorView(message), null, WatchUi.SLIDE_IMMEDIATE);
        } else {
            var message = "Unable to get token:\nUnknown error";
            WatchUi.switchToView(new ErrorView(message), null, WatchUi.SLIDE_IMMEDIATE);
        }

        Communications.registerForOAuthMessages(null);
    }
}