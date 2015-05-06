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

//! A custom BehaviorDelegate that lets us use the next and previous
//! page events as well as adding an onEnter() event.
class DiscGolfBehaviorDelegate extends Ui.BehaviorDelegate {

    hidden var mDevice;
    var relatedView;

    //! Initialize a DiscGolfBehaviorDelegate
    //! @param view The view that this delegate is tied to.
    function initialize(view) {
        mDevice = Ui.loadResource(Rez.Strings.device);
        relatedView = view;
    }

    //! Use the basic InputeDelegate to detect the enter key for the fenix 3
    //! and Forerunner 920.
    function onKey(evt) {
        if (evt.getKey() == Ui.KEY_ENTER) {
            return onEnter();
        } else if (evt.getKey() == Ui.KEY_DOWN) {
            return onNextPage();
        } else if (evt.getKey() == Ui.KEY_UP) {
            return onPreviousPage();
        }

        return false;
    }

    // Used to detect the start of the round on a vivoactive
    function onTap(evt) {
        return onEnter();
    }

    //! An enter event has occurred. This is triggered the following ways:
    //!     - vivoactive: a tap occurs
    //!     - fenix 3: the enter key is pressed
    //!     - Forerunner 920: the enter key is pressed
    //! @returns True if the event is handled
    function onEnter() {
        return false;
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_IMMEDIATE);
        return true;
    }

}