using Toybox.Application;
using Toybox.Media;

class MonkeyMusicApp extends Application.AudioContentProviderApp {

    function initialize() {
        // Check the current version to see if things need to be reset
        var version = getProperty(Properties.APP_VERSION);
        if (version != Versions.current) {
            clearProperties();
            Media.resetContentCache();
            setProperty(Properties.APP_VERSION, Versions.current);
        }

        // To bypass OAuth (useful for hardware testing) uncomment the line below
        setProperty(Properties.AUTHENTICATION_TOKEN, "ABCDEF12345");
        AudioContentProviderApp.initialize();
    }

    // Get a MediaContentDelegate for use by the system to get and iterate through media on the device
    function getContentDelegate(args) {
        return new ContentDelegate();
    }

    // Get a delegate that communicates sync status to the system for syncing media content to the device
    function getSyncDelegate() {
        return new SyncDelegate();
    }

    // Get the initial view for configuring playback
    function getPlaybackConfigurationView() {
        return [new ConfigurePlaybackView()];
    }

    // Get the initial view for configuring sync
    function getSyncConfigurationView() {
        return [new ConfigureSyncView()];
    }

    // Get the provider icon
    function getProviderIconInfo() {
        return new Media.ProviderIconInfo(Rez.Drawables.logo_with_palette, 0x4CBB17);
    }
}
