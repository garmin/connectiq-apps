//
// Copyright 2015-2019 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Lang;
using Toybox.Attention;

// Controller object for the theramin
class LidarThereminController {
    const MAX_DISTANCE = 50;
    const MAX_FREQ = 4000;
    const MIN_FREQ = 50;

    // smaller values = distance changes faster
    const DISTANCE_FILTER_STRENGTH = 0.5;

    private var _chan;
    private var _filteredDistance = 0.0;
    private var _view;


    public function initialize(view) {
        _view = view;
    }

    public function onStart() {
        _chan = new LidarThereminAntChannel();
        _chan.setMeasurementCallback(method(:onMeasurement));
        _chan.open();
    }

    public function onStop() {
        _chan.closeSensor();
    }

    public function updateFilteredDistance(distance) {
        _filteredDistance = _filteredDistance * DISTANCE_FILTER_STRENGTH + distance * (1 - DISTANCE_FILTER_STRENGTH);
    }

    public function playTone() {
        var distancePercent = _filteredDistance / MAX_DISTANCE;
        distancePercent = distancePercent > 1 ? 1.0 : distancePercent;
        var freq = distancePercent * (MAX_FREQ - MIN_FREQ) + MIN_FREQ;
        freq = freq.toNumber();

        var tone = new Attention.ToneProfile(freq, 250);

        Attention.playTone({:toneProfile => [tone]});
    }

    public function onMeasurement(model) {
        updateFilteredDistance(model.getDistance());
        _chan.requestMeasurement();
        playTone();

        _view.onMeasurement(model);
    }

}