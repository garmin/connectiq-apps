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
using Toybox.Lang as Lan;
using Toybox.Timer as Timer;

class DiscGolfIQView extends Ui.View {

    hidden var mCounter, mMessages, mTimer;

    //! Constructor
    function initialize() {
        Comm.setMailboxListener( method(:onMail) );
        mCounter = 0;
        mMessages = [Rez.Strings.text_waiting_for_message1, Rez.Strings.text_waiting_for_message2, Rez.Strings.text_waiting_for_message3];
        mTimer = new Timer.Timer();
    }

    //! Mail handler for the DiscGolfIQView.
    function onMail(mailIter) {
        var mail;
        mail = mailIter.next();
        Comm.emptyMailbox();

        // Go through the new mMessages. If we received a dictionary
        // we'll check to see if it's a message we can handle.
        if (mail != null) {
            if (mail instanceof Lan.Dictionary) {
                parseMessage(mail);

            // If we didn't receive a dictionary object then we'll just
            // attempt to print the message to the system. This case
            // really shouldn't ever be hit but having it here will help
            // with debugging.
            } else {
                Toybox.System.println(mail.toString());
            }
            mail = mailIter.next();
        }

        Ui.requestUpdate();
    }

    //! Parse the given message. A message should be in the following
    //! format:
    //!     {
    //!         "type" => DiscGolfConstants.MESSAGE_TYPE_XXX,
    //!         "payload" => <message_data>
    //!     }
    function parseMessage(message) {
        var type = message.get(DiscGolfConstants.KEY_MESSAGE_TYPE);
        var payload = message.get(DiscGolfConstants.KEY_MESSAGE_PAYLOAD);

        // If we received a dictionary that doesn't contain a type and
        // payload value then it's invalid to our application so we'll
        // just return here.
        if (type == null or payload == null) {
            var errorMessage = "Invalid message recieved:";
            var keys = message.keys();
            for (var i=0; i<keys.size(); i++) {
                errorMessage += "\n" + keys[i];
            }
            Toybox.System.println(errorMessage);
            return;
        }

        // The message we received was a new course. Pass the course along
        // to a course view and let's get the party started.
        if (type == DiscGolfConstants.MESSAGE_TYPE_COURSE) {
            if (payload instanceof Lan.Dictionary) {
                var courseView = new CourseView(payload);
                var courseDelegate = new CourseViewDelegate(courseView);
                Ui.switchToView(courseView, courseDelegate, Ui.SLIDE_IMMEDIATE);
            } else {
                Toybox.System.println("Invalid payload for message type: DiscGolfConstants.MESSAGE_TYPE_COURSE (" + DiscGolfConstants.MESSAGE_TYPE_COURSE + ")");
            }
        } else {
            Toybox.System.println("Unkown message type (" + type + ") received.");
        }
    }

    //! Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
        View.findDrawableById("title").setText(Rez.Strings.AppName);
        View.findDrawableById("message").setText(Rez.Strings.text_welcome_message);
    }

    //! This method is here so we can have the cool looking
    //! animated ellipse at the end of "Waiting for course..."
    function timerCallback() {
        Ui.requestUpdate();
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        mTimer.start(method(:timerCallback), 500, true);
    }

    //! Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        View.findDrawableById("output").setText(mMessages[mCounter]);
        mCounter++;
        if (mCounter == mMessages.size()) {
            mCounter = 0;
        }
    }

    //! Called when this View is removed from the screen. Save the
    //! state of your app here.
    function onHide() {
        mTimer.stop();
    }

}

//! We actually don't need an input delegate for this view but
//! we'll include this for debugging purposes. By allowing the
//! user to "send" a course to the watch using the Enter action
//! we can test the app without actually pairing the watch to a
//! phone.
class DiscGolfIQDelegate extends DiscGolfBehaviorDelegate {

    function initialize(view) {
        DiscGolfBehaviorDelegate.initialize(view);
    }

    function onEnter() {
        var message = {
            DiscGolfConstants.KEY_MESSAGE_TYPE => 1,
            DiscGolfConstants.KEY_MESSAGE_PAYLOAD => {
                DiscGolfConstants.KEY_COURSE_ID => 1337,
                DiscGolfConstants.KEY_COURSE_NAME => "Rosedale Park",
                DiscGolfConstants.KEY_COURSE_PAR => 54,
                DiscGolfConstants.KEY_COURSE_TEES_PLAYED => 1,
                DiscGolfConstants.KEY_HOLES => [
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 1,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 299
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 2,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 304
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 3,
                        DiscGolfConstants.KEY_HOLE_PAR => 2,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 233
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 4,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 253
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 5,
                        DiscGolfConstants.KEY_HOLE_PAR => 2,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 245
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 6,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 244
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 7,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 260
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 8,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 268
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 9,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 290
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 10,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 268
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 11,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 238
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 12,
                        DiscGolfConstants.KEY_HOLE_PAR => 4,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 305
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 13,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 315
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 14,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 301
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 15,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 272
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 16,
                        DiscGolfConstants.KEY_HOLE_PAR => 4,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 301
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 17,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 274
                    },
                    {
                        DiscGolfConstants.KEY_HOLE_NUMBER => 18,
                        DiscGolfConstants.KEY_HOLE_PAR => 3,
                        DiscGolfConstants.KEY_HOLE_DISTANCE => 285
                    }
                ],
                DiscGolfConstants.KEY_PLAYERS => [
                    { DiscGolfConstants.KEY_PLAYER_NAME => "James Oregon" },
                    { DiscGolfConstants.KEY_PLAYER_NAME => "Montana Smith" },
                    { DiscGolfConstants.KEY_PLAYER_NAME => "Dakota Williams" },
                    { DiscGolfConstants.KEY_PLAYER_NAME => "Michael Fenix" }
                ]
            }
        };

        relatedView.parseMessage(message);
    }

}