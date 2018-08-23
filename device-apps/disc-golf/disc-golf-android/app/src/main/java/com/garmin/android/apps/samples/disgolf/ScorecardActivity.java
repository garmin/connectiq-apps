/**
 * Copyright 2015 by Garmin Ltd. or its subsidiaries.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.garmin.android.apps.samples.disgolf;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

import com.garmin.android.apps.samples.disgolf.course.Scorecard;

public class ScorecardActivity extends Activity {

	// ------------------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC FIELDS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC METHODS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // FIELDS
    // ------------------------------------------------------------------------

	private Scorecard mScorecard;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

    @Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_scorecard);

		mScorecard = (Scorecard) getIntent().getParcelableExtra("scorecard");

		((TextView) findViewById(R.id.courseNameLabel)).setText(mScorecard.getCourseName());

		TextView view = ((TextView) findViewById(R.id.courseId));
		view.setText(Integer.toString(mScorecard.getCourseId()));

		if (mScorecard.getPlayers().size() > 0) {
			view = ((TextView) findViewById(R.id.player1name));
			view.setText(mScorecard.getPlayers().get(0).getName());
			view = ((TextView) findViewById(R.id.player1score));
			view.setText(mScorecard.getPlayers().get(0).getFormattedScore());
		}

		if (mScorecard.getPlayers().size() > 1) {
			view = ((TextView) findViewById(R.id.player2name));
			view.setText(mScorecard.getPlayers().get(1).getName());
			view = ((TextView) findViewById(R.id.player2score));
			view.setText(mScorecard.getPlayers().get(1).getFormattedScore());
		}

		if (mScorecard.getPlayers().size() > 2) {
			view = ((TextView) findViewById(R.id.player3name));
			view.setText(mScorecard.getPlayers().get(2).getName());
			view = ((TextView) findViewById(R.id.player3score));
			view.setText(mScorecard.getPlayers().get(2).getFormattedScore());
		}

		if (mScorecard.getPlayers().size() > 3) {
			view = ((TextView) findViewById(R.id.player4name));
			view.setText(mScorecard.getPlayers().get(3).getName());
			view = ((TextView) findViewById(R.id.player4score));
			view.setText(mScorecard.getPlayers().get(3).getFormattedScore());
		}
    }

}
