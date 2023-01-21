using Toybox.Application;
using Toybox.Math;
using Toybox.Media;

// Iterator to control the order of song playback
class ContentIterator extends Media.ContentIterator {

    // The index of the current song in mPlaylist
    private var mSongIndex;
    // The refIds of the songs to play
    private var mPlaylist;
    // Whether or not shuffling is enabled
    private var mShuffling;

    // Constructor
    function initialize() {
        ContentIterator.initialize();
        mSongIndex = 0;

        initializePlaylist();
    }

    // Returns the playback profile
    function getPlaybackProfile() {
        var profile = new PlaybackProfile();

        profile.playbackControls = [
                                   Media.PLAYBACK_CONTROL_PLAYBACK,
                                   Media.PLAYBACK_CONTROL_SHUFFLE,
                                   Media.PLAYBACK_CONTROL_PREVIOUS,
                                   Media.PLAYBACK_CONTROL_NEXT,
                                   Media.PLAYBACK_CONTROL_SKIP_FORWARD,
                                   Media.PLAYBACK_CONTROL_SKIP_BACKWARD,
                                   Media.PLAYBACK_CONTROL_REPEAT,
                                   ];

        profile.attemptSkipAfterThumbsDown = true;
        profile.requirePlaybackNotification = false;
        profile.playbackNotificationThreshold = 30;
        profile.skipPreviousThreshold = 4;

        return profile;
    }

    // Returns the next song, or null if there is no next song. Also increments the current
    // song index.
    function next() {
        if (mSongIndex < (mPlaylist.size() - 1)) {
            ++mSongIndex;
            var obj = Media.getCachedContentObj(new Media.ContentRef(mPlaylist[mSongIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song. Also decrements the current
    // song index.
    function previous() {
        if (mSongIndex > 0) {
            --mSongIndex;
            var obj = Media.getCachedContentObj(new Media.ContentRef(mPlaylist[mSongIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Gets the current song to play
    function get() {
        var obj = null;
        if ((mSongIndex >= 0) && (mSongIndex < mPlaylist.size())) {
            obj = Media.getCachedContentObj(new Media.ContentRef(mPlaylist[mSongIndex], Media.CONTENT_TYPE_AUDIO));
        }

        return obj;
    }

    // Returns the next song, or null if there is no next song, without decrementing the current song index.
    function peekNext() {
        var nextIndex = mSongIndex + 1;
        if (nextIndex < mPlaylist.size()) {
            var obj = Media.getCachedContentObj(new Media.ContentRef(mPlaylist[nextIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Returns the previous song, or null if there is no previous song, without incrementing the current song index.
    function peekPrevious() {
        var previousIndex = mSongIndex - 1;
        if (previousIndex >= 0) {
            var obj = Media.getCachedContentObj(new Media.ContentRef(mPlaylist[previousIndex], Media.CONTENT_TYPE_AUDIO));
            return obj;
        }

        return null;
    }

    // Return if shuffling is enabled or not
    function shuffling() {
        return mShuffling;
    }

    // Returns if the current song can be skipped. This is controlled by the data returned by the server.
    function canSkip() {
        var songs = Application.getApp().getProperty(Properties.SONGS);
        var canSkip = true;
        if ((songs != null) && (mSongIndex >= 0) && (mSongIndex < mPlaylist.size())) {
            canSkip = songs[mPlaylist[mSongIndex]][SongInfo.CAN_SKIP];
        }
        return canSkip;
    }

    // Toggles shuffling
    function toggleShuffle() {
        if (mShuffling) {
            mShuffling = false;
            initializePlaylist();
        } else {
            shufflePlaylist();
            mShuffling = true;
        }
    }

    // Shuffle the current playlist, leaving the current song at index 0.
    function shufflePlaylist() {
        var temp = mPlaylist[0];
        mPlaylist[0] = mPlaylist[mSongIndex];
        mPlaylist[mSongIndex] = temp;

        for (var idx = 1; idx < mPlaylist.size(); ++idx) {
            temp = mPlaylist[idx];
            var number = (Math.rand() % (mPlaylist.size() - idx)) + idx;
            mPlaylist[idx] = mPlaylist[number];
            mPlaylist[number] = temp;
        }

        mSongIndex = 0;
    }

    // Gets the songs to play. If no playlist is available then all the songs in the
    // system are played.
    function initializePlaylist() {
        var tempPlaylist = Application.getApp().getProperty(Properties.PLAYLIST);

        if (tempPlaylist == null) {
            var availableSongs = Media.getContentRefIter({:contentType => Media.CONTENT_TYPE_AUDIO});

            mPlaylist = [];
            if (availableSongs != null) {
                var song = availableSongs.next();
                while (song != null) {
                    mPlaylist.add(song.getId());
                    song = availableSongs.next();
                }
            }
        } else {
            mPlaylist = new [tempPlaylist.size()];
            for (var idx = 0; idx < mPlaylist.size(); ++idx) {
                mPlaylist[idx] = tempPlaylist[idx];
            }
        }
    }
}
