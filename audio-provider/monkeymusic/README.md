# MonkeyMusic

MonkeyMusic is a basic audio content provider app implementation and includes a simple python-based media server.

## The Server

In order to test the MonkeyMusic client, you must run a media server to host the content. We provide a sample server written in python and some sample media for testing.

Before you attempt to run the server, you will need to install a Python 2.7 interpreter. You can download Python from the Python website: https://www.python.org/downloads/

### Running the Server

1. Open a Command Prompt/Terminal.
2. Ensure that python is in your path. The easy way to do this is to run `python -V` from the command line. If python is properly installed, the python version should be displayed.

    ```
    C:\Users\vitek>python -V
    Python 2.7.10
    ```

    If you do not see a python version number in the output, you will need to troubleshoot your installation. Typically this involves modifying the `PATH` environment variable.

3. Change directories to the MonkeyMusic project root folder. This folder
    contains the project `manifest.xml` file.

    ```
    C:\Users\vitek>cd C:\Projects\connectiq-apps\audio-provider\monkeymusic

    C:\Projects\connectiq-apps\audio-provider\monkeymusic>
    ```

4. Start the MonkeyMusic media server on port 8000

    ```
    C:\Projects\connectiq-apps\audio-provider\monkeymusic>python -m CGIHTTPServer
    Serving HTTP on 0.0.0.0 port 8000 ...
    ```

5. If you'd like to verify that the media server is working, you can point a web browser at the server: http://localhost:8000/cgi-bin/media.py). Clicking that link you should see a page that displays the following message:

    ```
    There was an error in your request
    ```

## The Client

Now that the server is running, we should be able to build and run the client application.

### Running the Client

1. Open Eclipse and import the MonkeyMusic project.
2. Set a Run Configuration for the MonkeyMusic sample on the `Forerunner 645M` device.
3. Run the sample under the simulator. You will be presented with a menu.
4. Choose Configure Sync. A list downloadable of tracks will appear.
5. Select one or more tracks, then select Done from the menu. The app will exit.
6. Run the sample under the simulator. You will be presented with a menu.
7. Choose Sync. A progress bar will appear while the download is in progress. When completed, press or swipe Back. The app will exit.
8. Run the sample under the simulator. You will be presented with a menu.
9. Choose Configure Playback. A list of downloaded tracks will appear.
10. Select one or more tracks, then select Done from the menu. The app will exit.
11. Run the sample under the simulator. You will be presented with a menu. Select Playback. Standard playback controls and current track information should appear. Use device inputs to control the selected track. No actual playback occurs.
