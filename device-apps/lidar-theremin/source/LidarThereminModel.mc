//
// Copyright 2015-2019 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Time;

// MOJO for handling distance updates
class LidarThereminModel {
    private var _distance;
    private var _updateTime;

    public function initialize() {
        _distance = 0;
        _updateTime = Time.now();
    }

    public function setDistance(distance) {
        _distance = distance;
        _updateTime = Time.now();
    }

    public function getDistance() {
        return _distance;
    }

    public function getUpdateTime() {
        return _updateTime;
    }
}