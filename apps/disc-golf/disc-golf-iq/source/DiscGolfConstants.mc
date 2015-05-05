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

module DiscGolfConstants {

    //! Message type values received or sent to the partner app
    enum {
        MESSAGE_TYPE_COURSE = 1,
        MESSAGE_TYPE_SCORECARD = 2
    }

    //! Key values used when sending and receiving messages
    //! from the partner app.
    enum {
        KEY_MESSAGE_TYPE = -1,
        KEY_MESSAGE_PAYLOAD = -2,
        KEY_COURSE_ID = 0,
        KEY_COURSE_NAME = 1,
        KEY_COURSE_PAR = 2,
        KEY_COURSE_TEES_PLAYED = 3,
        KEY_PLAYERS = 4,
        KEY_PLAYER_NAME = 5,
        KEY_PLAYER_ID = 6,
        KEY_PLAYER_SCORES = 11,
        KEY_HOLES = 7,
        KEY_HOLE_NUMBER = 8,
        KEY_HOLE_PAR = 9,
        KEY_HOLE_DISTANCE = 10
    }

    //! RoundView status flags. These are used when triggering the
    //! SaveRoundView from the RoundView.
    enum {
        ROUND_VIEW_RESULT_WAITING = -1,
        ROUND_VIEW_RESULT_SAVE = 0,
        ROUND_VIEW_RESULT_DISCARD = 1,
        ROUND_VIEW_RESULT_CANCEL = 2,
        ROUND_VIEW_RESULT_POP_PAGE = 99
    }
}