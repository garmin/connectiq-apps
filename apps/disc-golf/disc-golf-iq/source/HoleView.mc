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
using Toybox.Graphics as Gfx;

//! Display a hole's information to the user and provide an
//! inteface for scoring the hole.
class HoleView extends Ui.View {

    hidden var mCourse, mHole, mIndicator, mHoleTitle, mDistanceLabel, mParLabel;

    //! Constructor.
    //! @param course The course we're currently playing.
    //! @param hole The hole to display.
    function initialize(course, hole) {
        mCourse = course;
        mHole = hole;

        mIndicator = new PageIndicator();
        var size = mCourse.getNumberOfHoles();
        var selected = Gfx.COLOR_RED;
        var notSelected = Gfx.COLOR_LT_GRAY;
        var alignment = PageIndicator.ALIGN_BOTTOM_RIGHT;
        mIndicator.setup(size, selected, notSelected, alignment, 1);
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.RoundViewLayout(dc));
    }

    //! Load the necesary strings into memory.
    function onShow() {
        mHoleTitle = Ui.loadResource(Rez.Strings.title_hole);
        mDistanceLabel = Ui.loadResource(Rez.Strings.text_distance);
        mParLabel = Ui.loadResource(Rez.Strings.text_par);

        // Update the title and status of the hole.
        View.findDrawableById("title").setText(mHoleTitle + mHole.getNumber().toString());
        View.findDrawableById("status").setText(mDistanceLabel + mHole.getDistance().toString() + ", " + mParLabel + mHole.getPar().toString());

        // For each of the players on the scorecard, draw their name
        // and hole score.
        for (var i=0; i<mCourse.getNumberOfPlayers(); i++) {
            View.findDrawableById("player" + (i+1) + "_score").setText(mCourse.getPlayer(i).getHoleScoreFormatted(mHole.getNumber()));
            View.findDrawableById("player" + (i+1) + "_name").setText(mCourse.getPlayer(i).getName());
        }
    }

    function onUpdate(dc) {
        View.onUpdate(dc);
        mIndicator.draw(dc, mHole.getNumber()-1);
    }

    //! Remove the strings from memory
    function onHide() {
        mHoleTitle = null;
        mDistanceLabel = null;
        mParLabel = null;
    }

    //! Prompt the user to enters scores for each player on the mHole.
    function scoreHole() {
        scorePlayer(0);
    }

    //! A generic method to score the player at the given index. This
    //! view will push a new view if the index given is 0 otherwards
    //! it will use Ui.switchToView().
    //! @param index The index of the player to score.
    function scorePlayer(index) {
        // If the player has a score recorded for this mHole already then
        // we'll show that score as the default selected value in the
        // picker. If they don't we'll use the mCourse par.
        var defaultScore = mCourse.getPlayer(index).getHoleScore(mHole.getNumber());
        if (defaultScore == null or defaultScore == 0) {
            defaultScore = mHole.getPar();
        }

        // Push the ScorePicker. If it's the first player we'll use
        // Ui.pushView() but for anyone else we'll use Ui.switchToView().
        var view = new ScorePicker(1, 10, defaultScore, mCourse.getPlayer(index).getName());
        var delegate = new ScorePickerDelegate(view, method(:playerScoreCallback), Ui.SLIDE_DOWN, index);
        if (index == 0) {
            Ui.pushView(view, delegate, Ui.SLIDE_UP);
        } else {
            Ui.switchToView(view, delegate, Ui.SLIDE_UP);
        }
    }

    //! A generic player callback method. The given score will be
    //! recorded for the given player index. If the index is not at
    //! the end of the player list then scorePlayer() will be called
    //! for the next index.
    //! @param playerIndex The index of the player who has been scored.
    //! @param strokes The player's score for the mHole.
    function playerScoreCallback(playerIndex, strokes) {
        // Record the players score
        mCourse.getPlayer(playerIndex).score(mHole.getNumber(), strokes, mHole.getPar());

        // See if we need to score another player
        var index = playerIndex + 1;
        if (mCourse.getNumberOfPlayers() > index) {
            scorePlayer(index);

        // We have no one else to score so pop the view
        } else {
            Ui.popView(Ui.SLIDE_DOWN);
        }
    }

    //! Return the Course that this Hole belongs too.
    //! @returns The course this hole belongs too.
    function getCourse() {
        return mCourse;
    }

}

//! Handles input for the HoleView. The following actions need to be
//! be available on this view:
//!     - Enter should provide a way for a user to enter players' scores.
//!     - The user should be able to page between the holes.
class HoleViewDelegate extends DiscGolfBehaviorDelegate {

    function initialize(view) {
        DiscGolfBehaviorDelegate.initialize(view);
    }

    function onBack() {
        var view = new RoundView(relatedView.getCourse());
        Ui.switchToView(view, new RoundViewDelegate(view), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onEnter() {
        relatedView.scoreHole();
        return true;
    }

    function onNextPage() {
        var view = new HoleView(relatedView.getCourse(), relatedView.getCourse().getNextHole());
        Ui.switchToView(view, new HoleViewDelegate(view), Ui.SLIDE_DOWN);
        return true;
    }

    function onPreviousPage() {
        var view = new HoleView(relatedView.getCourse(), relatedView.getCourse().getPreviousHole());
        Ui.switchToView(view, new HoleViewDelegate(view), Ui.SLIDE_UP);
        return true;
    }

}
