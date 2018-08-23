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
using Toybox.Communications as Comm;
using Toybox.Timer as Timer;

//! View which controls a round of disc golf. The base view shows some basic
//! round stats and allows you to enter scores for each hole.
class RoundView extends Ui.View {

    hidden var mSaveRoundResponse, mProgressBar, mProgressTransferMessage,
               mTransferSuccessMessage, mTransferFailedMessage, mProgressBarTimer,
               mStatusText, mStatusTextComplete, mRoundComplete, mCourse;

    //! Constructor
    //! @param course The course this round is being played at
    function initialize(course) {
        mCourse = course;
        mSaveRoundResponse = -1;
        mRoundComplete = false;

        mTransferSuccessMessage = Ui.loadResource(Rez.Strings.text_transfer_success);
        mTransferFailedMessage = Ui.loadResource(Rez.Strings.text_transfer_failure);
        mProgressBarTimer = new Timer.Timer();
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.RoundViewLayout(dc));

        View.findDrawableById("title").setText(Rez.Strings.title_round_status);
        View.findDrawableById("end_round_prompt").setText(Rez.Strings.prompt_end_round);
    }

    //! Here we'll check just check to see if a response has been
    //! received from a dialog while we were hidden. We'll also load
    //! up any strings we need to use.
    function onShow() {
        mStatusText = Ui.loadResource(Rez.Strings.text_round_status);
        mStatusTextComplete = Ui.loadResource(Rez.Strings.text_round_status_complete);
        mProgressTransferMessage = Ui.loadResource(Rez.Strings.text_sending_round);

        View.onShow();

        // Check to see if the flag set is save or discard the round.
        // If we need to save the round throw up a progress bar then
        // send the round back to the phone. If we aren't saving the
        // round we can either pop the view to go back (discarding the
        // round) or do nothing (cancel).
        if (mSaveRoundResponse != DiscGolfConstants.ROUND_VIEW_RESULT_WAITING) {
            if (mSaveRoundResponse == DiscGolfConstants.ROUND_VIEW_RESULT_SAVE) {
                mSaveRoundResponse = DiscGolfConstants.ROUND_VIEW_RESULT_WAITING;
                saveRound();

            // Here we are either done saving the round or discarding it. Either way we
            // want to switch back to the CourseView.
            } else if ( mSaveRoundResponse == DiscGolfConstants.ROUND_VIEW_RESULT_DISCARD ||
                        mSaveRoundResponse == DiscGolfConstants.ROUND_VIEW_RESULT_POP_PAGE ) {
                var courseView = new CourseView(mCourse);
                var courseDelegate = new CourseViewDelegate(courseView);
                Ui.switchToView(courseView, courseDelegate, Ui.SLIDE_IMMEDIATE);
            }
            mSaveRoundResponse = DiscGolfConstants.ROUND_VIEW_RESULT_WAITING;
        }
    }

    function onUpdate(dc) {
        if (mRoundComplete) {
            View.findDrawableById("status").setText(mStatusTextComplete);
        } else {
            View.findDrawableById("status").setText(mStatusText + (mCourse.getCurrentHole().getNumber()).toString());
        }

        for (var i=0; i<mCourse.getNumberOfPlayers(); i++) {
            View.findDrawableById("player" + (i+1) + "_score").setText(mCourse.getPlayer(i).getRunningScore());
            View.findDrawableById("player" + (i+1) + "_name").setText(mCourse.getPlayer(i).getName());
        }

        View.onUpdate(dc);
    }

    //! Unload the strings from memory
    function onHide() {
        mStatusText = null;
        mStatusTextComplete = null;
        mProgressTransferMessage = null;
    }

    //! Prompts the user if they want to save, quit or cancel
    //! when an end round request is made.
    //! @returns True if the round should be ended
    function promptToSaveRound() {
        mSaveRoundResponse = DiscGolfConstants.ROUND_VIEW_RESULT_WAITING;
        var saveView = new SaveRoundView();
        var delegate = new SaveRoundViewDelegate(saveView, method(:saveRoundCallback));
        Ui.pushView(saveView, delegate, Ui.SLIDE_UP);
    }

    //! Set the response from the save round dialog. We only set
    //! the response here because we need to return to the input
    //! handler and finish there. We'll check this flag in onShow()
    //! to see if it's a value other than waiting for response.
    //! @param response The response from the dialog.
    function saveRoundCallback(response) {
        mSaveRoundResponse = response;
    }

    //! Push a progress bar, send the round over the wire then pop
    //! the progress bar.
    function saveRound() {
        mProgressBar = new Ui.ProgressBar(mProgressTransferMessage, null);
        Ui.pushView(mProgressBar, null, Ui.SLIDE_DOWN);
        var message = {
            DiscGolfConstants.KEY_MESSAGE_TYPE => DiscGolfConstants.MESSAGE_TYPE_SCORECARD,
            DiscGolfConstants.KEY_MESSAGE_PAYLOAD => mCourse.buildScorecard()
        };
        Comm.transmit(message, null, new RoundViewCommListener(method(:onTransmitComplete)));
    }

    function printScorecard(message) {
    }

    //! Called when a Comm.transmit() has completed.
    //! @param status The status of the message, either RoundViewCommListener.SUCCESS
    //!               or RoundViewCommListener.FAILURE
    function onTransmitComplete(status) {
        if (status == RoundViewCommListener.SUCCESS) {
            mProgressBar.setDisplayString(mTransferSuccessMessage);
        } else {
            mProgressBar.setDisplayString(mTransferFailedMessage);
        }
        mProgressBarTimer.start(method(:hideProgressBar), 2000, false);
    }

    //! Hides the progress bar. Used with a timer to allow a success or failure
    //! message to be shown for a few seconds before popping the progress bar.
    function hideProgressBar() {
        mProgressBarTimer.stop();
        mSaveRoundResponse = DiscGolfConstants.ROUND_VIEW_RESULT_POP_PAGE;
        Ui.popView(Ui.SLIDE_DOWN);
    }

    //! Push a view to show the current hole. The view will be pushed using
    //! the given method and transition.
    //! @param transition The Ui.SLIDE_XXX transition to use
    function showCurrentHole(transition) {
        var view = new HoleView(mCourse, mCourse.getCurrentHole());
        var delegate = new HoleViewDelegate(view);
        Ui.switchToView(view, delegate, transition);
    }

    //! Decrement the hole number and go to that hole's view.
    //! @param transition The Ui.SLIDE_XXX transition to use
    function showPreviousHole(transition) {
        var view = new HoleView(mCourse, mCourse.getPreviousHole());
        var delegate = new HoleViewDelegate(view);
        Ui.switchToView(view, delegate, transition);
    }

}

//! Used to handle input on the RoundView. The following actions need to
//! be available on this view:
//!     - Save or quit a round. This will be handled by the back event. When
//!       a user hits back they will be presented with a dialog which allows
//!       them to save, quit or cancel the end round request.
//!     - Go to hole view. The enter event will trigger this. The last hole
//!       that was open will be brought back up.
class RoundViewDelegate extends DiscGolfBehaviorDelegate {

    //! Constructor
    //! @param relatedView The view that this delegate is tied to
    function initialize(relatedView) {
        DiscGolfBehaviorDelegate.initialize(relatedView);
    }

    //! Here we are just intercepting the onBack() event so we can prompt
    //! the user if they want to save the round before quitting.
    function onBack() {
        relatedView.promptToSaveRound();
        return true;
    }

    function onEnter() {
        relatedView.showCurrentHole(Ui.SLIDE_UP);
        return true;
    }

    function onNextPage() {
        relatedView.showCurrentHole(Ui.SLIDE_UP);
        return true;
    }

    function onPreviousPage() {
        relatedView.showPreviousHole(Ui.SLIDE_UP);
        return true;
    }

}

//! Handles communication feedback for the RoundView
class RoundViewCommListener extends Comm.ConnectionListener
{
    static var SUCCESS = 0;
    static var FAILURE = 1;

    hidden var mCallback;

    //! Constructor
    //! @param callback The method to call on a result
    function initialize(callback) {
        mCallback = callback;
    }

    //! Call the callback with a result of RoundViewCommListener.SUCCESS
    function onComplete() {
        mCallback.invoke(SUCCESS);
    }

    //! Call the callback with a result of RoundViewCommListener.FAILURE
    function onError() {
        mCallback.invoke(FAILURE);
    }
}