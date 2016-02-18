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

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.Spinner;

import com.garmin.android.apps.samples.disgolf.course.Course;
import com.garmin.android.apps.samples.disgolf.course.Hole;

public class CourseSetupActivity extends Activity implements OnItemSelectedListener {

	// ------------------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------------------

	// ------------------------------------------------------------------------
    // STATIC FIELDS
    // ------------------------------------------------------------------------

	private static final String TAG = CourseSetupActivity.class.getSimpleName();

	private static final int[] HOLE_DISTANCE_IDS = new int[] {
		R.id.hole1_distance, R.id.hole2_distance, R.id.hole3_distance, R.id.hole4_distance,
		R.id.hole5_distance, R.id.hole6_distance, R.id.hole7_distance, R.id.hole8_distance,
		R.id.hole9_distance, R.id.hole10_distance, R.id.hole11_distance, R.id.hole12_distance,
		R.id.hole13_distance, R.id.hole14_distance, R.id.hole15_distance, R.id.hole16_distance,
		R.id.hole17_distance, R.id.hole18_distance
	};

	private static final int[] HOLE_PAR_IDS = new int[] {
		R.id.hole1_par, R.id.hole2_par, R.id.hole3_par, R.id.hole4_par,
		R.id.hole5_par, R.id.hole6_par, R.id.hole7_par, R.id.hole8_par,
		R.id.hole9_par, R.id.hole10_par, R.id.hole11_par, R.id.hole12_par,
		R.id.hole13_par, R.id.hole14_par, R.id.hole15_par, R.id.hole16_par,
		R.id.hole17_par, R.id.hole18_par
	};

	// ------------------------------------------------------------------------
    // STATIC INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC METHODS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // FIELDS
    // ------------------------------------------------------------------------

	private Spinner mNumHolesSpinner;
	private int mNumHoles;

	private LinearLayout mHole1Layout;
	private LinearLayout mHole2Layout;
	private LinearLayout mHole3Layout;
	private LinearLayout mHole4Layout;
	private LinearLayout mHole5Layout;
	private LinearLayout mHole6Layout;
	private LinearLayout mHole7Layout;
	private LinearLayout mHole8Layout;
	private LinearLayout mHole9Layout;
	private LinearLayout mHole10Layout;
	private LinearLayout mHole11Layout;
	private LinearLayout mHole12Layout;
	private LinearLayout mHole13Layout;
	private LinearLayout mHole14Layout;
	private LinearLayout mHole15Layout;
	private LinearLayout mHole16Layout;
	private LinearLayout mHole17Layout;
	private LinearLayout mHole18Layout;

	private Button mNextPageButton;

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
		setContentView(R.layout.activity_course_setup);

		mNumHolesSpinner = (Spinner) findViewById(R.id.num_holes_spinner);
    	ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item, Arrays.asList(
    			new String[]{"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18"}));
    	adapter.setDropDownViewResource(android.R.layout.simple_dropdown_item_1line);
    	mNumHolesSpinner.setAdapter(adapter);
    	mNumHolesSpinner.setOnItemSelectedListener(this);
    	mNumHolesSpinner.setSelection(8);

    	mHole1Layout = (LinearLayout) findViewById(R.id.hole1_layout);
    	mHole2Layout = (LinearLayout) findViewById(R.id.hole2_layout);
    	mHole3Layout = (LinearLayout) findViewById(R.id.hole3_layout);
    	mHole4Layout = (LinearLayout) findViewById(R.id.hole4_layout);
    	mHole5Layout = (LinearLayout) findViewById(R.id.hole5_layout);
    	mHole6Layout = (LinearLayout) findViewById(R.id.hole6_layout);
    	mHole7Layout = (LinearLayout) findViewById(R.id.hole7_layout);
    	mHole8Layout = (LinearLayout) findViewById(R.id.hole8_layout);
    	mHole9Layout = (LinearLayout) findViewById(R.id.hole9_layout);
    	mHole10Layout = (LinearLayout) findViewById(R.id.hole10_layout);
    	mHole11Layout = (LinearLayout) findViewById(R.id.hole11_layout);
    	mHole12Layout = (LinearLayout) findViewById(R.id.hole12_layout);
    	mHole13Layout = (LinearLayout) findViewById(R.id.hole13_layout);
    	mHole14Layout = (LinearLayout) findViewById(R.id.hole14_layout);
    	mHole15Layout = (LinearLayout) findViewById(R.id.hole15_layout);
    	mHole16Layout = (LinearLayout) findViewById(R.id.hole16_layout);
    	mHole17Layout = (LinearLayout) findViewById(R.id.hole17_layout);
    	mHole18Layout = (LinearLayout) findViewById(R.id.hole18_layout);

    	mNextPageButton = (Button) findViewById(R.id.next_page_button);
    	mNextPageButton.setOnClickListener(new OnClickListener() {
			@Override
			public void onClick(View v) {
				goToPlayerSetupPage();
			}
		});
	}

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

    private void updateVisibleHoles(int number) {
    	mHole1Layout.setVisibility((number >= 1) ? View.VISIBLE : View.GONE);
    	mHole2Layout.setVisibility((number >= 2) ? View.VISIBLE : View.GONE);
    	mHole3Layout.setVisibility((number >= 3) ? View.VISIBLE : View.GONE);
    	mHole4Layout.setVisibility((number >= 4) ? View.VISIBLE : View.GONE);
    	mHole5Layout.setVisibility((number >= 5) ? View.VISIBLE : View.GONE);
    	mHole6Layout.setVisibility((number >= 6) ? View.VISIBLE : View.GONE);
    	mHole7Layout.setVisibility((number >= 7) ? View.VISIBLE : View.GONE);
    	mHole8Layout.setVisibility((number >= 8) ? View.VISIBLE : View.GONE);
    	mHole9Layout.setVisibility((number >= 9) ? View.VISIBLE : View.GONE);
    	mHole10Layout.setVisibility((number >= 10) ? View.VISIBLE : View.GONE);
    	mHole11Layout.setVisibility((number >= 11) ? View.VISIBLE : View.GONE);
    	mHole12Layout.setVisibility((number >= 12) ? View.VISIBLE : View.GONE);
    	mHole13Layout.setVisibility((number >= 13) ? View.VISIBLE : View.GONE);
    	mHole14Layout.setVisibility((number >= 14) ? View.VISIBLE : View.GONE);
    	mHole15Layout.setVisibility((number >= 15) ? View.VISIBLE : View.GONE);
    	mHole16Layout.setVisibility((number >= 16) ? View.VISIBLE : View.GONE);
    	mHole17Layout.setVisibility((number >= 17) ? View.VISIBLE : View.GONE);
    	mHole18Layout.setVisibility((number >= 18) ? View.VISIBLE : View.GONE);
    }

    private void goToPlayerSetupPage() {
    	int coursePar = 0;
    	List<Hole> holes = new ArrayList<Hole>();
    	for (int i=0; i<mNumHoles; i++) {
    		int par = Integer.parseInt(((EditText)findViewById(HOLE_PAR_IDS[i])).getText().toString());
    		coursePar += par;
    		int distance = Integer.parseInt(((EditText)findViewById(HOLE_DISTANCE_IDS[i])).getText().toString());
    		holes.add(new Hole(i+1, par, distance));
    	}
    	String courseName = ((EditText) findViewById(R.id.course_name)).getText().toString();
    	Course course = new Course(-1, courseName, coursePar, 1);
    	course.setHoles(holes);

    	Intent intent = new Intent(this, PlayerSetupActivity.class);
    	Bundle bundle = new Bundle();
    	bundle.putParcelable("course", course);
    	intent.putExtras(bundle);
    	startActivity(intent);
    }

	// ------------------------------------------------------------------------
	// OnItemSelectedListener METHODS
	// ------------------------------------------------------------------------

	@Override
	public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
		updateVisibleHoles(position+1);
		mNumHoles = position+1;
	}

	@Override
	public void onNothingSelected(AdapterView<?> parent) {
		// don't care
	}
}
