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

import java.util.Arrays;
import java.util.Random;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Spinner;
import android.widget.TextView;

import com.garmin.android.apps.samples.disgolf.course.Course;
import com.garmin.android.apps.samples.disgolf.course.Player;

public class PlayerSetupActivity extends Activity implements OnItemSelectedListener {

	// ------------------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------------------

	// ------------------------------------------------------------------------
    // STATIC FIELDS
    // ------------------------------------------------------------------------

	private static final String TAG = PlayerSetupActivity.class.getSimpleName();

	private static final int[] PLAYER_NAME_IDS = new int[] {
		R.id.player1_name, R.id.player2_name, R.id.player3_name, R.id.player4_name
	};

	// ------------------------------------------------------------------------
    // STATIC INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC METHODS
    // ------------------------------------------------------------------------

	/**
	 * Taken from: http://stackoverflow.com/questions/363681/generating-random-integers-in-a-range-with-java
	 *
	 * Returns a pseudo-random number between min and max, inclusive.
	 * The difference between min and max can be at most
	 * <code>Integer.MAX_VALUE - 1</code>.
	 *
	 * @param min Minimum value
	 * @param max Maximum value.  Must be greater than min.
	 * @return Integer between min and max, inclusive.
	 * @see java.util.Random#nextInt(int)
	 */
	public static int randInt(int min, int max) {

	    // NOTE: Usually this should be a field rather than a method
	    // variable so that it is not re-seeded every call.
	    Random rand = new Random();

	    // nextInt is normally exclusive of the top value,
	    // so add 1 to make it inclusive
	    int randomNum = rand.nextInt((max - min) + 1) + min;

	    return randomNum;
	}

    // ------------------------------------------------------------------------
    // FIELDS
    // ------------------------------------------------------------------------

	private Spinner mNumPlayersSpinner;
	private TextView mPlayer1Label;
	private TextView mPlayer2Label;
	private TextView mPlayer3Label;
	private TextView mPlayer4Label;
	private EditText mPlayer1Name;
	private EditText mPlayer2Name;
	private EditText mPlayer3Name;
	private EditText mPlayer4Name;
	private int mNumPlayers;
	private Button mNextPageButton;
	private Course mCourse;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // LIFECYCLE METHODS
    // ------------------------------------------------------------------------

    @Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_player_setup);

		mNumPlayersSpinner = (Spinner) findViewById(R.id.num_players_spinner);
    	ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, Arrays.asList(new String[]{"1", "2", "3", "4"}));
    	adapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
    	mNumPlayersSpinner.setAdapter(adapter);
    	mNumPlayersSpinner.setOnItemSelectedListener(this);

		mPlayer1Label = (TextView) findViewById(R.id.player1_label);
		mPlayer2Label = (TextView) findViewById(R.id.player2_label);
		mPlayer3Label = (TextView) findViewById(R.id.player3_label);
		mPlayer4Label = (TextView) findViewById(R.id.player4_label);
		mPlayer1Name = (EditText) findViewById(R.id.player1_name);
		mPlayer2Name = (EditText) findViewById(R.id.player2_name);
		mPlayer3Name = (EditText) findViewById(R.id.player3_name);
		mPlayer4Name = (EditText) findViewById(R.id.player4_name);

		mNextPageButton = (Button) findViewById(R.id.next_page_button);
		mNextPageButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				goToDeviceSelectionPage();
			}
		});

		try {
			Bundle bundle = getIntent().getExtras();
			if (bundle != null) {
				mCourse = bundle.getParcelable("course");
			}
		} catch (Exception ex) {
			Log.e(TAG, "Error deparceling course", ex);
		}
	}

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

    private void updateVisiblePlayers(int number) {
		mPlayer1Label.setVisibility((number >= 1) ? View.VISIBLE : View.GONE);
		mPlayer1Name.setVisibility((number >= 1) ? View.VISIBLE : View.GONE);
		mPlayer2Label.setVisibility((number >= 2) ? View.VISIBLE : View.GONE);
		mPlayer2Name.setVisibility((number >= 2) ? View.VISIBLE : View.GONE);
		mPlayer3Label.setVisibility((number >= 3) ? View.VISIBLE : View.GONE);
		mPlayer3Name.setVisibility((number >= 3) ? View.VISIBLE : View.GONE);
		mPlayer4Label.setVisibility((number >= 4) ? View.VISIBLE : View.GONE);
		mPlayer4Name.setVisibility((number >= 4) ? View.VISIBLE : View.GONE);
    }

    private void goToDeviceSelectionPage() {
    	for (int i=0; i<mNumPlayers; i++) {
    		String name = ((EditText) findViewById(PLAYER_NAME_IDS[i])).getText().toString();
    		int id = randInt(1, Integer.MAX_VALUE);
    		mCourse.addPlayer(new Player(name, id));
    	}

    	Intent intent = new Intent(this, SendRoundToDeviceActivity.class);
    	Bundle bundle = new Bundle();
    	bundle.putParcelable("course", mCourse);
    	intent.putExtras(bundle);
    	startActivity(intent);
    }

	// ------------------------------------------------------------------------
	// OnItemSelectedListener METHODS
	// ------------------------------------------------------------------------

	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		updateVisiblePlayers(position+1);
		mNumPlayers = position+1;
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {
		// don't care
	}

}
