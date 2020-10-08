//
// Copyright 2017 by Garmin Ltd. or its subsidiaries.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

using Toybox.Position;
using Toybox.Lang;
using Toybox.Math;
using Toybox.System;

//! This module contains classes and functions for implementing a semicircles
//! based coordinates
module Semicircles {

    //! Execption for unhandled coordinate formats
    class BadCoordinateFormatException extends Lang.Exception {
        private var _msg;
        public function initialize(msg) {
            Exception.initialize();
            _msg = msg;
        }

        public function getErrorMessage() {
            return _msg;
        }
    }


    //! Class to represent a coordinate that does not use Position module
    //! This class uses 32 bit semicircles, where PI radians are equal
    //! to 0x80000000 32 bit semicircles. Semicircles handle wrap-around via
    //! integer overflow, and all angle math can be done using integer math
    //! speeding up computation. This class also includes a fast distance
    //! between two point computation.
    class Coordinate {
        //! Constant for semicircles per meter at the equator
        const SC_PER_M = 107.173;

        private var _lat;
        private var _lon;

        //! Initialize the coordinate class
        //! @param [Toybox::Lang::Object] Type based off the following options
        //!    [Toybox::Lang::Dictionary] Allows input options
        //!      [:latitude] Specify the latitude
        //!      [:longitude] Specify the longitude
        //!      [:format] Either :semicircles or :radians. I spit on your degrees.
        //!    [Toybox::Position::Location] Convert the location to semicircles
        //!    [Toybox::Lang::Array] Assumes latitude is in radians as value 0, and longitude is in radians in value 1
        public function initialize(value) {
            var coord = convertToSemicircle(value);
            _lat = coord[0];
            _lon = coord[1];
        }

        //! Private conversion function to convert locations to semicircles
        //! @param [Toybox::Lang::Object] Type based off the following options
        //!    [Toybox::Position::Location] Convert the location to semicircles
        //!    [Toybox::Lang::Array] Assumes latitude is in radians as value 0, and longitude is in radians in value 1
        //!    [Toybox::Lang::Dictionary] Allows input options
        //!      [:latitude] Specify the latitude
        //!      [:longitude] Specify the longitude
        //!      [:format] Either :semicircles or :radians. I spit on your degrees.
        private function convertToSemicircle(value) {
            var result = new [2];
            // Switch based on the object type

            switch(value) {
                case instanceof Lang.Dictionary:
                    if(value.hasKey(:format)) {
                        switch(value[:format]) {
                            case :semicircles:
                                result = [value[:latitude], value[:longitude]];
                                break;
                            case :radians:
                                result[0] = ((value[:latitude] * 0x80000000l)/Math.PI).toNumber();
                                result[1] = ((value[:longitude] * 0x80000000l)/Math.PI).toNumber();
                                break;
                            default:
                                throw new BadCoordinateFormatException("Only support formats of semicircles and radians");
                        }
                    } else {
                        throw new BadCoordinateFormatException("No format specified");
                    }
                    break;
                case instanceof Semicircles.Coordinate:
                    result = value.toSemicircles();
                    break;
                case instanceof Lang.Array:
                    result[0] = value[0];
                    result[1] = value[1];
                    break;
                default:
                    // Referencing Position.Location (even with instanceof) would require the position permission.
                    // That doesn't mean we can't check if we have a toRadians function... #sneaky
                    if (value has :toRadians) {
                        var coords = value.toRadians();
                        result[0] = ((coords[0] * 0x80000000l)/Math.PI).toNumber();
                        result[1] = ((coords[1] * 0x80000000l)/Math.PI).toNumber();
                    } else {
                        throw new BadCoordinateFormatException("Cannot handle input type for value " + value);
                    }
                    break;
            }
            return result;
        }

        //! Computes the cosine correction for two latitudes in semicircles
        //! @param [Toybox::Lang::Number] lat1 Latitude 1 in semicircles
        //! @param [Toybox::Lang::Number] lat2 Latitude 2 in semicircles
        //! @return [Toybox::Lang::Double] Cosine correction
        private function computeCosineCorrection(lat1, lat2) {
            var result = (lat1.toLong() + lat2.toLong()) / 2;
            result = (result * Math.PI) / 0x80000000;

            return Math.cos(result);
        }

        //! Compute a fast distance between two points
        //! @param [Toybox::Lang::Object] pt1 Type based off the following options
        //!    [Toybox::Position::Location] Convert the location to semicircles
        //!    [Toybox::Lang::Array] Assumes latitude is in radians as value 0, and longitude is in radians in value 1
        public function computeDistanceInMeters(pt) {
            var pt1 = [_lat, _lon];
            var pt2 = convertToSemicircle(pt);

            // Correct for the curvature of the earth by finding the cosine of the
            // midpoint of the two latitudes
            var cosineCorrection = computeCosineCorrection(pt1[0], pt2[0]);

            // Compute dLat and dLon
            var distLat = (pt1[0] - pt2[0]).toLong();
            var distLon = ((pt1[1] - pt2[1]) * cosineCorrection).toLong();

            // Compute the distance
            return Math.sqrt((distLat * distLat) + (distLon * distLon)) / SC_PER_M;
        }

        //! Output the coordinate in radians
        //! @return [Toybox::Lang::Array] Array of [latitude, longitude] in radians
        public function toRadians() {
            var result = [(_lat.toDouble() * Math.PI) / 0x80000000,
            (_lon.toDouble() * Math.PI) / 0x80000000];
            return result;
        }

        //! Output the coordinate in semicircles
        //! @return [Toybox::Lang::Array] Array of [latitude, longitude] in semicircles
        public function toSemicircles() {
            return [_lat, _lon];
        }
    }

}
