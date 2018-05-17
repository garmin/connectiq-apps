using Toybox.Application;
using Toybox.Communications;
using Toybox.Media;

// Performs the sync with the music provider
class SyncDelegate extends Media.SyncDelegate {

    // The list of songs to sync
    private var mSyncList;
    // The list of songs to delete
    private var mDeleteList;
    // The count of songs to delete and download
    private var mTotalSongsToSync;
    // The cont of songs that have been deleted or downloaded
    private var mSongsSynced;

    // Constructor
    function initialize() {
        SyncDelegate.initialize();

        // Get the sync list
        var app = Application.getApp();
        mSyncList = app.getProperty(Properties.SYNC_LIST);
        if (mSyncList == null) {
            mSyncList = {};
        }

        // Get the delete list
        mDeleteList = app.getProperty(Properties.DELETE_LIST);
        if (mDeleteList == null) {
            mDeleteList = [];
        }

        mSongsSynced = 0;
    }

    // Starts the sync with the system
    function onStartSync() {
        // Calculate the number of songs to be synced so the
        // progress can be updated properly
        mTotalSongsToSync = mSyncList.size() + mDeleteList.size();

        // Delete all the songs from the system
        deleteSongs();

        // Grab the first song from the server
        syncNextSong();
    }

    // Determines if a sync is needed or not
    function isSyncNeeded() {
        return ((mSyncList.size() != 0) || (mDeleteList.size() != 0));
    }

    // Delete songs off the system
    function deleteSongs() {
        var app = Application.getApp();

        // Remove the song from the system
        var songs = app.getProperty(Properties.SONGS);

        if (songs == null) {
            return;
        }

        // Delete each song from the system
        for (var idx = 0; idx < mDeleteList.size(); ++idx) {
            Media.deleteCachedItem(new Media.ContentRef(mDeleteList[idx], Media.CONTENT_TYPE_AUDIO));

            songs.remove(mDeleteList[idx]);
            app.setProperty(Properties.SONGS, songs);

            // Update the sync progress
            onSongSynced();
        }

        // Remove the delete list from the system
        app.deleteProperty(Properties.DELETE_LIST);
    }

    // Downloads the next song to be synced
    function syncNextSong() {
        var ids = mSyncList.keys();

        // Check for completion
        if (ids.size() == 0) {
            Media.notifySyncComplete(null);
            return;
        }

        // Download the first song in the sync list
        if (mSyncList[ids[0]]) {
            var songInfo = mSyncList[ids[0]];
            var context = {SongInfo.CAN_SKIP => songInfo[SongInfo.CAN_SKIP],
                           SongInfo.ID => ids[0],
                           SongInfo.URL => songInfo[SongInfo.URL]};
            var options = {:method => Communications.HTTP_REQUEST_METHOD_GET,
                           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_AUDIO,
                           :mediaEncoding => typeStringToEncoding(songInfo[SongInfo.TYPE])};

            var delegate = new RequestDelegate(method(:onSongDownloaded), context);
            delegate.makeWebRequest(mSyncList[ids[0]][SongInfo.URL], null, options);
        }
    }

    function typeStringToEncoding(type) {
        var encoding = Media.ENCODING_INVALID;

        if (type.equals("mp3")) {
                encoding = Media.ENCODING_MP3;
        } else if (type.equals("m4a")) {
                encoding = Media.ENCODING_M4A;
        } else if (type.equals("wav")) {
                encoding = Media.ENCODING_WAV;
        } else if (type.equals("adts")) {
                encoding = Media.ENCODING_ADTS;
        }

        return encoding;
    }

    // Callback for when a song is downloaded
    function onSongDownloaded(responseCode, data, context) {
        if (responseCode == 200) {
            var app = Application.getApp();

            // Remove the song from the sync list
            mSyncList.remove(context[SongInfo.ID]);
            app.setProperty(Properties.SYNC_LIST, mSyncList);

            // Add it to the stored songs
            var songs = app.getProperty(Properties.SONGS);
            if (songs == null) {
                songs = {};
            }
            context.remove(SongInfo.URL);
            songs[data.getId()] = context;
            app.setProperty(Properties.SONGS, songs);

            // Update the progress
            onSongSynced();

            // Get the next song
            syncNextSong();
        } else {
            var errorString = "Sync failed with error code: " + responseCode;
            Media.notifySyncComplete(errorString);
        }
    }

    // Update the system with the current sync progress
    function onSongSynced() {
        ++mSongsSynced;

        var progress =  mSongsSynced / mTotalSongsToSync.toFloat();
        progress = (progress * 100).toNumber();

        Media.notifySyncProgress(progress);
    }
}