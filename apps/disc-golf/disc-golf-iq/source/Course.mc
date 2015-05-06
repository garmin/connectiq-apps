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

using Toybox.Application as App;

class Course {

    hidden var mId, mTeesPlayed, mName, mPar, mHoles, mPlayers, mCurrentHole;

    //! Constructor
    //! @param courseDto The course DTO to parse
    function initialize(courseDto) {
        mId = courseDto.get(DiscGolfConstants.KEY_COURSE_ID);
        mTeesPlayed = courseDto.get(DiscGolfConstants.KEY_COURSE_TEES_PLAYED);
        mHoles = parseHoles(courseDto.get(DiscGolfConstants.KEY_HOLES));
        mCurrentHole = 0;
        mName = courseDto.get(DiscGolfConstants.KEY_COURSE_NAME);
        mPar = courseDto.get(DiscGolfConstants.KEY_COURSE_PAR);
        mPlayers = parsePlayers(courseDto.get(DiscGolfConstants.KEY_PLAYERS), mHoles.size());
    }

    //! Parse the mHoles DTO into a list of Hole objects.
    //! @param holesDto The mHoles DTO to parse
    //! @returns A list of Hole objects
    function parseHoles(holesDto) {
        var mHoles = new [holesDto.size()];
        for (var i=0; i<mHoles.size(); i++) {
            mHoles[i] = new Hole(holesDto[i].get(DiscGolfConstants.KEY_HOLE_NUMBER), holesDto[i].get(DiscGolfConstants.KEY_HOLE_PAR), holesDto[i].get(DiscGolfConstants.KEY_HOLE_DISTANCE));
        }
        return mHoles;
    }

    //! Parse the mPlayers DTO into a a list of Player objects.
    //! @param playersDto
    //! @returns A list of Player objects
    function parsePlayers(playersDto, numHoles) {
        var mPlayers = new [playersDto.size()];
        for (var i=0; i<mPlayers.size(); i++) {
            mPlayers[i] = new Player(playersDto[i].get(DiscGolfConstants.KEY_PLAYER_NAME), playersDto[i].get(DiscGolfConstants.KEY_PLAYER_SCORES), numHoles);
        }
        return mPlayers;
    }

    //! Reset's the course to it's original state. This includes
    //! reseting the player's scores as well as the current hole.
    function reset() {
        for (var i=0; i<mPlayers.size(); i++) {
            mPlayers[i].resetScores();
        }
        mCurrentHole = 0;
    }

    //! Build the scorecard to transport
    //! @returns A completed scorecard
    function buildScorecard() {
        var scoredPlayers = new [mPlayers.size()];
        for (var i=0; i<scoredPlayers.size(); i++) {
            scoredPlayers[i] = {
                DiscGolfConstants.KEY_PLAYER_NAME => mPlayers[i].getName(),
                DiscGolfConstants.KEY_PLAYER_ID => mPlayers[i].getId(),
                DiscGolfConstants.KEY_PLAYER_SCORES => mPlayers[i].getHoleScores()
            };
        }

        var scorecard = {
            DiscGolfConstants.KEY_COURSE_ID => mId,
            DiscGolfConstants.KEY_COURSE_NAME => mName,
            DiscGolfConstants.KEY_PLAYERS => scoredPlayers
        };

        return scorecard;
    }

    //! Returns the number of holes on this course.
    //! @returns The number of holes.
    function getNumberOfHoles() {
        return mHoles.size();
    }

    //! Returns the hole marked by the current hole index.
    //! @returns The current hole
    function getCurrentHole() {
        return mHoles[mCurrentHole];
    }

    //! Increments the current hole index and returns the hole
    //! associated with the new value.
    //! @returns The next hole on this course
    function getNextHole() {
        mCurrentHole = (mCurrentHole + 1) % mHoles.size();
        return getCurrentHole();
    }

    //! Decrements the current hole index and returns the hole
    //! associated with the new value.
    //! @returns The previous hole on this course
    function getPreviousHole() {
        mCurrentHole--;
        if (mCurrentHole < 0) {
            mCurrentHole += mHoles.size();
        }
        return getCurrentHole();
    }

    //! Returns the number of mPlayers playing this course.
    //! @returns The number of mPlayers
    function getNumberOfPlayers() {
        return mPlayers.size();
    }

    //! Gets the player at the given index on the scorecard.
    //! @returns The player at the given index
    function getPlayer(index) {
        return mPlayers[index];
    }

    //! Gets the mPar for the course.
    //! @returns The par for the course
    function getPar() {
        return mPar;
    }

    //! Gets the mName of the course.
    //! @returns The name of the course
    function getName() {
        return mName;
    }

}