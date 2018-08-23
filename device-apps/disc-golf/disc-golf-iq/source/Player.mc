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

//! Holds a players information
class Player {

    var mHoleScores, mId;
    hidden var mName, mRunningScore;

    //! Constructor for a player.
    //! @param name The name of the player
    //! @param numHoles The number of holes the player will be playing
    function initialize(name, id, numHoles) {
        mName = name;
        mHoleScores = new [numHoles];
        mId = id;
        resetScores();
    }

    //! Resets the player's individual hole scores as well as the
    //! overall, running score.
    function resetScores() {
        for (var i=0; i<mHoleScores.size(); i++) {
            mHoleScores[i] = null;
        }
        mRunningScore = 0;
    }

    //! Mark the given score for the given hole number.
    //! @param holeNum The number of the hole starting at index 1
    //! @param score The player's score in strokes
    //! @param score The par for the hole
    //! @returns True if the player's scorecard is complete
    function score(holeNum, score, holePar) {
        // First check if we're rerecording a score for this
        // hole. If we are we need to adjust the running score
        // accordingly.
        if (mHoleScores[holeNum-1] != null) {
            mRunningScore -= (mHoleScores[holeNum-1] - holePar);
        }

        // Record the score for the hole and update the running
        // score total.
        mHoleScores[holeNum-1] = score;
        mRunningScore += (score - holePar);

        // Check if a score has been recorded for this player
        // for all of the holes.
        var complete = true;
        for (var i=0; i<mHoleScores.size(); i++) {
            complete &= mHoleScores[i] != null;
            if (!complete) {
                return false;
            }
        }
        return true;
    }

    //! Return a formatted string of the player's running
    //! score. This means a score of 0 returns "E".
    //! @returns The player's string formatted score
    function getRunningScore() {
        if (mRunningScore == 0) {
            return "E";
        } else if (mRunningScore > 0) {
            return "+" + mRunningScore.toString();
        } else {
            return mRunningScore.toString();
        }
    }

    //! Get the player's score on the given hole.
    //! @param holeNum The number of the hole to get starting from index 1
    //! @returns The formatted score for the given hole
    function getHoleScore(holeNum) {
        return mHoleScores[holeNum-1];
    }

    //! Return a formatted string of the player's score on the
    //! given hole number. If the value isn't set yet (null)
    //! a "-" will be returned. If the hole number given is out
    //! of the range of the player's scorecard an empty string
    //! is returned.
    //! @param holeNum The number of the hole to get starting from index 1
    //! @returns The formatted score for the given hole
    function getHoleScoreFormatted(holeNum) {
        if ((holeNum-1) < mHoleScores.size()) {
            if (mHoleScores[holeNum-1] == null) {
                return "-";
            } else {
                return mHoleScores[holeNum-1].toString();
            }
        }
        return "";
    }

    //! Gets the name of the player.
    //! @returns The name of this player
    function getName() {
        return mName;
    }

    //! Gets the ID of the player.
    //! @returns The
    function getId() {
        return mId;
    }

    //! Get the player's scores for all the holes.
    //! @returns The player's hole scores in an array
    function getHoleScores() {
        return mHoleScores;
    }

}