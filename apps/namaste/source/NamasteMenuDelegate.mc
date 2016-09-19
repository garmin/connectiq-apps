using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.Application;
using Toybox.Timer;



class NamasteMenuDelegate extends Ui.MenuInputDelegate {

    hidden var mController;
    hidden var mDeathTimer;

    function initialize() {
        MenuInputDelegate.initialize();
        mController = Application.getApp().controller;

    }

    function onMenuItem(item) {
        if (item == :resume) {
            mController.start();
            return true;
        } else if (item == :save) {
            mController.save();
            return true;
        } else {
            mController.discard();
            return true;
        }
        return false;
    }


}