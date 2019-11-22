using Toybox.Application;

class DanceDanceGarminApp extends Application.AppBase {
    private var _view;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        _view = new DanceDanceGarminView();
        return [ _view ];
    }


}