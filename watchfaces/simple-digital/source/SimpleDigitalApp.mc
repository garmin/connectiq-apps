using Toybox.WatchUi as Ui;

class SimpleDigitalApp extends Toybox.Application.AppBase {

	function initialize() {
		AppBase.initialize();
	}

	function onStart(state) {
	}

	function onStop(state) {
	}

	function getInitialView() {
		return [ new SimpleDigitalView() ];
	}

	function onSettingsChanged() {
		Ui.requestUpdate();
	}

}
