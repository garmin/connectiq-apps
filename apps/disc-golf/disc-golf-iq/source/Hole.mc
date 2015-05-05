//
// Copyright 2015 by Garmin Ltd. or its subsidiaries.
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

using Toybox.WatchUi as Ui;

class Hole {

    hidden var mNumber, mPar, mDistance;

    //! Constructor
    //! @param number The hole number (starting at 1, NOT 0)
    //! @param par The par for the hole
    //! @param distance The distance of the hole
    function initialize(number, par, distance) {
        mNumber = number;
        mPar = par;
        mDistance = distance;
    }

    //! Get this Hole's number.
    //! @returns This hole's number
    function getNumber() {
        return mNumber;
    }

    //! Get this Hole's par.
    //! @returns The par of this hole
    function getPar() {
        return mPar;
    }

    //! Get this Hole's distance
    //! @returns This hole's distance
    function getDistance() {
        return mDistance;
    }

}
