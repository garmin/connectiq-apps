using Toybox.Application;
using Toybox.Communications;
using Toybox.Graphics;
using Toybox.System;
using Toybox.WatchUi;

// View for choosing what songs to download
class ConfigureSyncView extends WatchUi.View {

    // Current state the view is in
    enum {
        STATE_FETCHING,
        STATE_FETCHED
    }

    // The songs fetched from the server
    private var mSongs;
    // Wheter the view has been shown or not
    private var mMenuShown;

    // Constructor
    function initialize() {
        View.initialize();

        mMenuShown = false;
    }

    // When shown, decide if the songs should be fetched or the view popped (when returning from the menu)
    function onShow() {
        // If not authenticated, get authentication first
        var token = Application.getApp().getProperty(Properties.AUTHENTICATION_TOKEN);
        if (token == null) {
             WatchUi.pushView(new OauthView(), null, WatchUi.SLIDE_IMMEDIATE);
        } else if (mMenuShown) {
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else {
            token = Application.getApp().getProperty(Properties.AUTHENTICATION_TOKEN);
            Communications.makeWebRequest(Constants.PROVIDER_URL, {"mode" => "listing", "token" => token}, {}, method(:onFileListing));
            mSongs = {};
        }
    }

    // Handle updating the view
    function onUpdate(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);

        // Indicate that the songs are being fetched
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM, WatchUi.loadResource(Rez.Strings.fetchingSongs), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Store the fetched songs
    function onFileListing(responseCode, data) {
        if (responseCode == 200) {
            mSongs = data;
            pushSyncMenu();
        } else {
            if (data != null) {
                WatchUi.pushView(new ErrorView(data["errorMessage"]), null, WatchUi.SLIDE_IMMEDIATE);
            } else {
                WatchUi.pushView(new ErrorView("Unknown Error"), null, WatchUi.SLIDE_IMMEDIATE);
            }
        }
        WatchUi.requestUpdate();
    }

    // Populates the sync menu with the songs from the server
    function pushSyncMenu() {
        var menu = new WatchUi.CheckboxMenu({:title => Rez.Strings.syncMenuTitle});
        var songNames = mSongs.keys();
        var precheckedItems = {};
        var app = Application.getApp();

        // Add in songs on the system to the prechecked list
        var downloadedSongs = app.getProperty(Properties.SONGS);
        if (downloadedSongs == null) {
            downloadedSongs = {};
        }

        var refIds = downloadedSongs.keys();
        for (var idx = 0; idx < refIds.size(); ++idx) {
            var id = downloadedSongs[refIds[idx]];
            precheckedItems[id] = true;
        }

        // Add in songs that need to be synced to the prechecked list
        var songsToSync = app.getProperty(Properties.SYNC_LIST);
        if (songsToSync == null) {
            songsToSync = {};
        }

        refIds = songsToSync.keys();
        for (var idx = 0; idx < refIds.size(); ++idx) {
            var id = refIds[idx];
            precheckedItems[id] = true;
        }

        // Create the menu, prechecking anything that is to be or has been synced
        for (var idx = 0; idx < songNames.size(); ++idx) {
            var item = new WatchUi.CheckboxMenuItem(mSongs[songNames[idx]]["name"],
                                                    null,
                                                    mSongs[songNames[idx]],
                                                    precheckedItems.hasKey(mSongs[songNames[idx]]["id"]),
                                                    {});
            menu.addItem(item);
        }
        WatchUi.pushView(menu, new ConfigureSyncMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
        mMenuShown = true;
    }
}
