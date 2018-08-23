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

//! A widget which allows a User to enter a score for a player.
class ScorePicker extends Ui.View {

    hidden var mMin, mMax, mIndicator, mTitleLabel, mTitle, mLabel, mValue;

    //! Constructor
    //! @param min The minimum value to allow, inclusive
    //! @param max The maximum value to allow, inclusive
    //! @param initial The initial value of the ScorePicker. Must be between min and max.
    //! @param title The name of the person who's being scored.
    function initialize(min, max, initial, title) {
        mMin = min;
        mMax = max;
        mValue = initial;
        mTitle = title;
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.ScorePickerLayout(dc));
    }

    //! Load strings into memory
    function onShow() {
        mTitleLabel = Ui.loadResource(Rez.Strings.title_score_picker);
        mLabel = Ui.loadResource(Rez.Strings.text_strokes_label);
    }

    function onUpdate(dc) {
        var title = View.findDrawableById("title");
        var upperTitle = View.findDrawableById("title_upper");
        if (upperTitle != null) {
            upperTitle.setText(mTitleLabel);
            title.setText(mTitle);
        } else {
            title.setText(mTitleLabel + " " + mTitle);
        }

        View.findDrawableById("label").setText(mLabel);
        View.findDrawableById("score").setText(mValue.toString());

        var scoreUp = View.findDrawableById("score_up");
        var scoreDown = View.findDrawableById("score_down");
        if (scoreUp != null && scoreDown != null) {
            if (mValue < mMax) {
                scoreUp.setText((mValue + 1).toString());
            } else {
                scoreUp.setText("");
            }

            if (mValue > mMin) {
                scoreDown.setText((mValue - 1).toString());
            } else {
                scoreDown.setText("");
            }
        }

        View.onUpdate(dc);
    }

    //! Unload strings to save memory
    function onHide() {
        mTitleLabel = null;
        mLabel = null;
    }

    //! Increase the current value of the ScorePicker
    function increaseValue() {
        mValue++;
        if (mValue > mMax) {
            mValue = mMin;
        }
        Ui.requestUpdate();
    }

    //! Decrease the current value of the ScorePicker
    function decreaseValue() {
        mValue--;
        if (mValue < mMin) {
            mValue = mMax;
        }
        Ui.requestUpdate();
    }

    //! Gets the current value of the ScorePicker
    //! @returns The current value of the ScorePicker
    function getValue() {
        return mValue;
    }

}

//! The input delegate for the ScorePicker view. The following
//! actions should be available to the user:
//!     - Increase/decrease the value
//!     - Select the current value
class ScorePickerDelegate extends DiscGolfBehaviorDelegate {

    hidden var mCallback, mTransition, mPlayerIndex;

    function initialize(view, callback, transition, playerIndex) {
        DiscGolfBehaviorDelegate.initialize(view);
        mCallback = callback;
        mTransition = transition;
        mPlayerIndex = playerIndex;
    }

    function onTap(evt) {
        var x = evt.getCoordinates()[0];
        var y = evt.getCoordinates()[1];

        // Touch occurred in the middle horizontally
        if (x > 68 and x < 137) {

            // The up arrow was clicked so increase the mValue
            if (y < 49) {
                relatedView.increaseValue();
                return true;

            // The down arrow was clicked so decrease the mValue
            } else if (y > 98) {
                relatedView.decreaseValue();
                return true;

            // The center was clicked. We'll ignore this because
            // it's too close to both the up and down arrow.
            } else {
                return false;
            }
        }
        return onEnter();
    }

    function onEnter() {
        mCallback.invoke(mPlayerIndex, relatedView.getValue());
        return true;
    }

    function onNextPage() {
        relatedView.decreaseValue();
        return true;
    }

    function onPreviousPage() {
        relatedView.increaseValue();
        return true;
    }

}