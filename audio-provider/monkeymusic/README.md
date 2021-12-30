# MonkeyMusic
MonkeyMusic is a basic audio content provider app implementation that includes a simple Python-based media server.

## The Server
In order to test the MonkeyMusic app, you must have a media server to host the audio content. We've included a sample server written in Python and some sample media for testing. Before attempting to run the server, install a Python 2.7 interpreter, which can be downloaded from the Python website at https://www.python.org/downloads/.

### Running the Server
1. Open a Command Prompt/Terminal.
2. Check to make sure Python is in your path. An easy way to do this is to run `python -V` from the command line. If Python is properly installed, the Python version should be displayed:

    ```
    C:\Users\vitek>python -V
    Python 2.7.10
    ```

    If you do not see a Python version number in the output, you will need to troubleshoot your installation. This typically involves modifying the `PATH` environment variable.

3. Change directories to the MonkeyMusic project root folder, which contains the project `manifest.xml` file:
    
    ```
    C:\Users\vitek>cd C:\Projects\connectiq-apps\audio-provider\monkeymusic
    C:\Projects\connectiq-apps\audio-provider\monkeymusic>
    ```

4. Start the MonkeyMusic media server on port 8000:

    ```
    C:\Projects\connectiq-apps\audio-provider\monkeymusic>python -m CGIHTTPServer
    Serving HTTP on 0.0.0.0 port 8000 ...
    ```

5. If you'd like to verify that the media server is working, you can visit http://localhost:8000/cgi-bin/media.py in a web browser, which should display a page with the following message:

    ```
    There was an error in your request
    ```

## The Client
Once the server is running, the client application can be used to obtain and play back content. An audio content provider app can run in one of four modes:

1. Configure Sync
2. Sync
3. Configure Playback
4. Playback

The steps below demonstrate each of the modes.

Note: This assumes that you have the Eclipse IDE installed and configured for Connect IQ development. See the [Getting Started](https://developer.garmin.com/connect-iq/programmers-guide/getting-started/) chapter of the Connect IQ Programmer's Guide for more information

### Running the Client
1. Open Eclipse and import the MonkeyMusic project.
2. Create a Run Configuration for the MonkeyMusic project using the _Forerunner 645M_ device.
3. Run the sample in the Connect IQ simulator.
4. Disable _Settings > Use Device HTTPS Requirements_, so that the simulated device can connect to the server over HTTPS.
> NOTE: This will not cause a security issue while you are connecting locally in the simulator. When you deploy your app however, any endpoints you connect to should be secured with HTTPS.
5. Choose _Settings > Media Mode > Sync Configuration_ from the simulator top menu.
6. Select one or more tracks from the displayed list of downloadable tracks.
7. Select _Done_ from the menu, and the app will exit.
8. Run the sample in the simulator again.
9. Choose _Settings > Media Mode > Sync_ from the simulator top menu. A progress bar will appear while the download is in progress.
10. When completed, press or swipe _Back_, and the app will exit.
11. Run the sample in the simulator again.
12. Choose _Settings > Media Mode > Playback Configuration_ from the simulator top menu, and a list of downloaded tracks will appear.
13. Select one or more tracks from the displayed list of downloaded tracks.
14. Select _Done_ from the menu, and the app will exit.
15. Run the sample in the simulator again.
16. Select _Playback_ from the simulator top menu to display standard playback controls and current track information. Device inputs (buttons, touch screen, etc., depending on the devcie) can be used to control the selected track. **No actual playback occurs.**
