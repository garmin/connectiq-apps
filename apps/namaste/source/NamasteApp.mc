using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class NamasteApp extends App.AppBase {

    var model;
    var controller;

    function initialize() {
        AppBase.initialize();
        model = new $.NamasteModel();
        controller = new $.NamasteController();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new $.NamasteView(), new $.NamasteDelegate() ];
    }

}
