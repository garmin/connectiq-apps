// Keys for the object store
module Properties {
    enum {
        AUTHENTICATION_TOKEN,
        SYNC_LIST,
        DELETE_LIST,
        PLAYLIST,
        SONGS,
        APP_VERSION
    }
}

// Versions of the app. If a value is added to the enum then
// current should also be updated to the latest version. This
// will trigger an object store wipe.
module Versions {
    enum {
        V1 = 0,
    }

    const current = V1;
}

// Keys for the object store entry of Properties.SONGS
module SongInfo {
    enum {
        URL,
        CAN_SKIP,
        ID,
        TYPE
    }
}

// General constants used in the app
module Constants {
    const PROVIDER_URL = "http://localhost:8000/cgi-bin/media.py";
    const REDIRECT_URL = "http://localhost:8000/cgi-bin/callback.py";
}