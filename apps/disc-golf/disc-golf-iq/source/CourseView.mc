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

//! Takes a course DTO from the partner app and dispalys the course
//! information to the user.
class CourseView extends Ui.View {

    hidden var mCourse, mIndex, mHolesLabel, mParLabel, mIndicator;

    enum {
        COURSE_INFO_VIEW = 0,
        PLAYERS_INFO_VIEW = 1
    }

    //! Constructor. Will parse a course DTO into a Course object or
    //! copy over a Course object into thise CourseView.
    //! @param courseDto This can either be a course DTO object (dictionary)
    //!                  to be parsed or a Course object.
    function initialize(courseDto) {
        // We were passed a course DTO
        if (courseDto != null and courseDto instanceof Toybox.Lang.Dictionary) {
            mCourse = new Course(courseDto);

        // We were passed a Course object
        } else if (courseDto != null and courseDto instanceof Course) {
            mCourse = courseDto;

        // We don't have course information so set the course to null
        } else {
            mCourse = null;
        }

        mIndex = COURSE_INFO_VIEW;

        mIndicator = new PageIndicator();
        var size = 2;
        var selected = Gfx.COLOR_RED;
        var notSelected = Gfx.COLOR_LT_GRAY;
        var alignment = PageIndicator.ALIGN_BOTTOM_RIGHT;
        mIndicator.setup(size, selected, notSelected, alignment, 1);
    }

    //! Start a round at the current course. To do this we'll reset the
    //! course's scoring values and then switch to a RoundView.
    function startRound() {
        if (mCourse != null) {
            mCourse.reset();
            var roundView = new RoundView(mCourse);
            Ui.switchToView(roundView, new RoundViewDelegate(roundView), Ui.SLIDE_IMMEDIATE);
        }
    }

    //! Update the page index for the next page and request a UI update.
    function nextPage() {
        mIndex = (mIndex + 1) % 2;
        Ui.requestUpdate();
        return true;
    }

    //! Update the page index for the previous page and request a UI update.
    function previousPage() {
        mIndex--;
        if (mIndex < 0) {
            mIndex = 1;
        }
        Ui.requestUpdate();
        return true;
    }

    function onLayout(dc) {
        setLayout(Rez.Layouts.StandardLayout(dc));
        if (mCourse != null) {
            View.findDrawableById("action_prompt").setText(Rez.Strings.prompt_start_round);
        }
    }

    //! Load the strings necesary for this page.
    function onShow() {
        View.onShow();
        mHolesLabel = Ui.loadResource(Rez.Strings.text_holes);
        mParLabel = Ui.loadResource(Rez.Strings.text_par);
    }

    function onUpdate(dc) {
        if (mCourse != null) {

            // List each of the players listed on the scorecard.
            if (mIndex == PLAYERS_INFO_VIEW) {
                View.findDrawableById("title").setText(Rez.Strings.title_players);
                for (var i=0; i<4; i++) {
                    if (i < mCourse.getNumberOfPlayers()) {
                        View.findDrawableById("line" + (i+1).toString()).setText(mCourse.getPlayer(i).getName());
                    } else {
                        View.findDrawableById("line" + (i+1).toString()).setText("");
                    }
                }

            // List the course information.
            } else {
                View.findDrawableById("title").setText(Rez.Strings.title_course_info);
                View.findDrawableById("line1").setText(mCourse.getName());
                View.findDrawableById("line2").setText(mHolesLabel + mCourse.getNumberOfHoles());
                View.findDrawableById("line3").setText(mParLabel + mCourse.getPar());
                View.findDrawableById("line4").setText("");
            }

        // We don't have a Course set for the view so we'll just show a simple
        // error message. This shouldn't be possible to hit but we'll leave this
        // catch in to prevent any unexpected type errors.
        } else {
            View.findDrawableById("title").setText(Rez.Strings.title_course_info);
            View.findDrawableById("line1").setText("<no course available>");
        }

        View.onUpdate(dc);

        // Only draw the page indicator if we have a Course to display.
        if (mCourse != null) {
            mIndicator.draw(dc, mIndex);
        }
    }

    // Unload the strings we use in this view to save some memory.
    function onHide() {
        View.onHide();
        mHolesLabel = null;
        mParLabel = null;
    }

}

//! Handles input for the CourseView. The following actions need to be
//! be available on this view:
//!     - Enter should start recording a round of golf.
//!     - The user should be able to page between the course information
//!       and the golfers listed on the scorecard.
class CourseViewDelegate extends DiscGolfBehaviorDelegate {

    function initialize(view) {
        DiscGolfBehaviorDelegate.initialize(view);
    }

    function onBack() {
        var view = new DiscGolfIQView();
        Ui.switchToView(view, new DiscGolfIQDelegate(view), Ui.SLIDE_IMMEDIATE);
        return true;
    }

    function onEnter() {
        relatedView.startRound();
        return true;
    }

    function onNextPage() {
        return relatedView.nextPage();
    }

    function onPreviousPage() {
        return relatedView.previousPage();
    }

}