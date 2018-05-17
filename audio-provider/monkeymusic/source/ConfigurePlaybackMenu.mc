using Toybox.WatchUi;

// Menu to choose what songs to playback
class ConfigurePlaybackMenu extends WatchUi.CheckboxMenu {

    // Constructor
    function initialize() {
        CheckboxMenu.initialize({:title => Rez.Strings.playbackMenuTitle});
        var app = Application.getApp();

        // Get the current stored playlist.
        var currentPlaylist = {};
        var playlist = app.getProperty(Properties.PLAYLIST);
        if (playlist != null) {
            for (var idx = 0; idx < playlist.size(); ++idx) {
                currentPlaylist[playlist[idx]] = true;
            }
        }

        // Get the songs on the system
        var songs = app.getProperty(Properties.SONGS);

        // For each song in the playlist, precheck the item when adding it to the menu
        var refIds = songs.keys();
        for (var idx = 0; idx < refIds.size(); ++idx) {
            var refId = refIds[idx];
            var ref = new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO);
            var songName = Media.getCachedContentObj(ref).getMetadata().title;
            var item = new WatchUi.CheckboxMenuItem(songName, null, refId, currentPlaylist.hasKey(refId), {});
            addItem(item);
        }
    }
}
