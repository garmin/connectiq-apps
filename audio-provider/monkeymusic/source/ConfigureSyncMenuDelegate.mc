using Toybox.WatchUi;

// Menu delegate for Sync Menu
class ConfigureSyncMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var mSyncList;
    private var mDeleteList;

    // Constructor
    function initialize() {
        Menu2InputDelegate.initialize();
        mSyncList = [];
        mDeleteList = [];
    }

    // Either add it or remove the item from the
    // list of songs to sync or delete
    function onSelect(item) {
        if (item.isChecked()) {
            mSyncList.add(item.getId());
            mDeleteList.remove(item.getId());
        } else {
            mSyncList.remove(item.getId());
            mDeleteList.add(item.getId());
        }
    }

    // Pop the view when back is pushed
    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Stores the songs to delete and download in the object store
    function onDone() {
        var app = Application.getApp();

        // Get the songs currently on the system
        var mSongs = app.getProperty(Properties.SONGS);
        if (mSongs == null) {
            mSongs = {};
        }

        // Get the songs already in the sync list
        var syncInfo = app.getProperty(Properties.SYNC_LIST);
        if (syncInfo == null) {
            syncInfo = {};
        }

        // Add each song from the local sync list into the object store sync list
        // if it is not already in the object store sync list
        for (var i = 0; i < mSyncList.size(); ++i) {
            if (getRefIdFromSongs(syncInfo[mSyncList[i]["id"]], mSongs) == null) {
                var info = {SongInfo.URL => mSyncList[i]["url"],
                            SongInfo.CAN_SKIP => mSyncList[i]["canSkip"],
                            SongInfo.TYPE => mSyncList[i]["type"]};
                syncInfo[mSyncList[i]["id"]] = info;
            }
        }

        // Same as above, but for the delete list
        app.setProperty(Properties.SYNC_LIST, syncInfo);

        var deleteInfo = app.getProperty(Properties.DELETE_LIST);
        if (deleteInfo == null) {
            deleteInfo = [];
        }

        for (var i = 0; i < mDeleteList.size(); ++i) {
            var refId = getRefIdFromSongs(mDeleteList[i]["id"], mSongs);
            if (refId != null) {
                deleteInfo.add(refId);
            }
        }

        app.setProperty(Properties.DELETE_LIST, deleteInfo);

        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    // Utility function to get the ContentRefId from the already downloaded songs.
    // Converts songId, the ID from the server, to the stored ref id
    function getRefIdFromSongs(songId, mSongs) {
        var keys = mSongs.keys();

        for (var idx = 0; idx < keys.size(); ++idx) {
            if (mSongs[keys[idx]].equals(songId)) {
                return keys[idx];
            }
        }

        return null;
    }
}