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
using Toybox.Test;

// This module contains classes and functions for implementing a semicircles
// based coordinates. This file defines the unit tests for the class.
module Semicircles {

    // Wrapping all test cases within a module will allow the compiler
    // to eliminate the entire module when not building unit tests.
    (:test)
    module Test {

        function computeDistanceBetweenTwoPointsInMeters(logger, pt1, pt2) {
            pt1 = new Coordinate(pt1);

            pt2 = new Coordinate(pt2);
            return pt1.computeDistanceInMeters(pt2);
        }

        (:test)
        function testLongerDistance(logger) {
            var result = computeDistanceBetweenTwoPointsInMeters(
                logger,
                [464239996, -1130764382],
                [464215044, -1130815196]
                );
            logger.debug("Result = " + result);
            Test.assert( ((result > 436) && (result < 437)));
            return true;
        }

        (:test)
        function testDistance(logger) {
            var result = computeDistanceBetweenTwoPointsInMeters(
                logger,
                [609043028, -1360851358],
                [609050505, -1360850722]
                );
            logger.debug("Result = " + result);
            Test.assert(((result > 69) && (result < 71)));
            return true;
        }

        (:test)
        function testDistanceWithCoordinate(logger) {
            var result = computeDistanceBetweenTwoPointsInMeters(
                logger,
                new Coordinate({:latitude=>609043028, :longitude=>-1360851358, :format=>:semicircles}),
                new Coordinate({:latitude=>609050505, :longitude=>-1360850722, :format=>:semicircles})
                );
            logger.debug("Result = " + result);
            Test.assert(((result > 69) && (result < 71)));
            return true;
        }

        (:test)
        function testDistanceWithRadians(logger) {
            var result = computeDistanceBetweenTwoPointsInMeters(
                logger,
                new Coordinate({:latitude=>0.890979304d, :longitude=>-1.990812373d, :format=>:radians}),
                new Coordinate({:latitude=>0.890990242d, :longitude=>-1.990811443d, :format=>:radians})
                );
            logger.debug("Result = " + result);
            Test.assert(((result > 69) && (result < 71)));
            return true;
        }

        (:test)
        function testBadTypes(logger) {
            var failed = false;
            try {
                logger.debug("Testing string second argument");
                var result = computeDistanceBetweenTwoPointsInMeters(logger, [609043028, -1360851358], "WHAZZZUP?!");
            } catch (e instanceof BadCoordinateFormatException) {
                failed = true;
            }

            if(!failed) {
                return false;
            }

            failed = false;
            try {
                logger.debug("Testing string first argument");
                var result = computeDistanceBetweenTwoPointsInMeters(logger, "WHAZZZUP?!", [609043028, -1360851358] );
            } catch (e instanceof BadCoordinateFormatException) {
                failed = true;
            }

            if(!failed) {
                return false;
            }
            return true;
        }
    }
}