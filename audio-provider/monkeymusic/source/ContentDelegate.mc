using Toybox.Application;
using Toybox.Media;

// The content delegate to handle actions from the media player
class ContentDelegate extends Media.ContentDelegate {

        // Iterator for playing songs
        private var mIterator;
        // Enum value to strings for song events
        private var mSongEvents = ["Start", "Skip Next", "Skip Previous", "Playback Notify", "Complete", "Stop", "Pause", "Resume"];

        // Constructor
        function initialize() {
            ContentDelegate.initialize();
            resetContentIterator();
        }

        // Returns the iterator to play songs
        function getContentIterator() {
            return mIterator;
        }

        // Returns the iterator to play songs
        function resetContentIterator() {
            mIterator = new ContentIterator();

            return mIterator;
        }

        // Since there is no good way to provide feedback that this function was
        // called just print data to the text file
        function onAdAction(refId) {
            Toybox.System.println("Ad Action: " + getSongName(refId));
        }

        // Since there is no good way to provide feedback that this function was
        // called just print data to the text file
        function onThumbsUp(refId) {
            Toybox.System.println("Thumbs Up: " + getSongName(refId));
        }

        // Since there is no good way to provide feedback that this function was
        // called just print data to the text file
        function onThumbsDown(refId) {
            Toybox.System.println("Thumbs Down: " + getSongName(refId));
        }

        // Since there is no good way to provide feedback that this function was
        // called just print data to the text file
        function onSong(refId, songEvent, playbackPosition) {
            Toybox.System.println("Song Event (" + mSongEvents[songEvent] + "): " + getSongName(refId) + " at position " + playbackPosition);
        }

        // Tells the iterator to shuffle the current songs
        function onShuffle() {
            mIterator.toggleShuffle();
        }

        // Helper function to get the name of a song for reporting that certain functions were called
        function getSongName(refId) {
            var song = Media.getCachedContentObj(new Media.ContentRef(refId, Media.CONTENT_TYPE_AUDIO));
            return song.getMetadata().title;
        }
}