using Toybox.Media;
using Toybox.WatchUi;

// Delegate for playback menu
class ConfigurePlaybackMenuDelegate extends WatchUi.Menu2InputDelegate {

    // Constructor
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    // When an item is selected, add or remove it from the system playlist
    function onSelect(item) {
        var app = Application.getApp();
        var playlist = app.getProperty(Properties.PLAYLIST);

        if (playlist == null) {
            playlist = [];
        }

        if (item.isChecked()) {
            playlist.add(item.getId());
        } else {
            playlist.remove(item.getId());
        }

        app.setProperty(Properties.PLAYLIST, playlist);
    }

    // Pop the view when done
    function onDone() {
        Media.startPlayback(null);
    }

    // Pop the view when back is pushed
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}
