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

//! Creates a dialog which prompts the user to save or discard a
//! round. See the SaveRoundViewBehaviorDelegate for instructions
//! on how to use this View.
class SaveRoundView extends Ui.View {

    hidden var mIndicator, mMessages, mIndex;

    //! Constructor
    function initialize() {
        mIndicator = new PageIndicator();
        var size = 3;
        var selected = Gfx.COLOR_RED;
        var notSelected = Gfx.COLOR_LT_GRAY;
        var alignment = PageIndicator.ALIGN_BOTTOM_RIGHT;
        mIndicator.setup(size, selected, notSelected, alignment, 1);

        mIndex = DiscGolfConstants.ROUND_VIEW_RESULT_SAVE;

        mMessages = [
            Rez.Strings.text_save_round,
            Rez.Strings.text_quit_without_saving,
            Rez.Strings.text_cancel
        ];
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.SaveRoundViewLayout(dc));
        View.findDrawableById("message").setText(Rez.Strings.text_save_round_message);
    }

    function onUpdate(dc) {
        View.findDrawableById("command").setText(mMessages[mIndex]);
        View.onUpdate(dc);
        mIndicator.draw(dc, mIndex);
    }

    //! Update the page index to the next page and request
    //! a UI update.
    //! @returns True to indicate we handled the next page event
    function nextPage() {
        mIndex = (mIndex + 1) % 3;
        Ui.requestUpdate();
        return true;
    }

    //! Update the page index to the previous page and request
    //! a UI update.
    //! @returns True to indicate we handled the previous page event
    function previousPage() {
        mIndex = mIndex - 1;
        if (mIndex < 0) {
            mIndex = 2;
        }
        Ui.requestUpdate();
        return true;
    }

    //! Gets the current page index.
    //! @returns The current page index
    function getIndex() {
        return mIndex;
    }

}

//! InputDelegate for the SaveRoundView. To use this you must implement
//! the following in your calling View:
//!     - The calling view must have a flag variable which holds the
//!       result of this dialog. This value must be initialized to a
//!       "waiting" value before this dialog is called.
//!     - The callback method that updates said value must be passed
//!       to the constructor for this delegate (the 2nd parameter).
//!     - When the user selects a value in this dialog the dialog view
//!       will be popped which will trigger the onShow() method of the
//!       calling view. You must check the value of the flag in onShow()
//!       of your calling view to see if a result has been returned.
class SaveRoundViewDelegate extends DiscGolfBehaviorDelegate {

    var mCallback;

    //! Constructor
    //! @param relatedView The view this delegate is tied to
    //! @param callback The method of the calling view to return a result to
    function initialize(relatedView, callback) {
        DiscGolfBehaviorDelegate.initialize(relatedView);
        mCallback = callback;
    }

    //! Invoke the callback method and pop the dialog view.
    function onEnter() {
        mCallback.invoke(relatedView.getIndex());
        Ui.popView(Ui.SLIDE_DOWN);
        return true;
    }

    function onNextPage() {
        return relatedView.nextPage();
    }

    function onPreviousPage() {
        return relatedView.previousPage();
    }

}