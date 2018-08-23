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

package com.garmin.android.apps.samples.disgolf.course;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import android.os.Parcel;
import android.os.Parcelable;
import android.util.Log;

import com.garmin.android.apps.samples.disgolf.AppConstants;

public class Scorecard implements Parcelable {

	// ------------------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC FIELDS
    // ------------------------------------------------------------------------

	private static final String TAG = Scorecard.class.getSimpleName();

	public static final Parcelable.Creator<Scorecard> CREATOR = new Parcelable.Creator<Scorecard>() {
		@Override
		public Scorecard createFromParcel(Parcel in) {
			return new Scorecard(in);
		}

		@Override
		public Scorecard[] newArray(int size) {
			return new Scorecard[size];
		}
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

	private final Integer mCourseId;
	private final String mCourseName;
	private final List<Player> mPlayers;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

	public Scorecard(@SuppressWarnings("rawtypes") HashMap dto) {
		Integer value = null;
		try {
			value = (Integer) dto.get(AppConstants.KEY_COURSE_ID);
		} catch (ClassCastException ex) {
			Log.e(TAG, "Invalid course ID.");
		}
		mCourseId = value;
		mCourseName = (String) dto.get(AppConstants.KEY_COURSE_NAME);
		@SuppressWarnings({ "rawtypes", "unchecked" })
		ArrayList<HashMap> playersDto = (ArrayList<HashMap>) dto.get(AppConstants.KEY_PLAYERS);
		mPlayers = parsePlayers(playersDto);
	}

	public Scorecard(Parcel parcel) {
		mCourseId = parcel.readInt();
		mCourseName = parcel.readString();
		ArrayList<Player> players = new ArrayList<Player>();
		parcel.readTypedList(players, Player.CREATOR);
		mPlayers = players;
	}

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

	public List<Player> parsePlayers(@SuppressWarnings("rawtypes") ArrayList<HashMap> playersDto) {
		List<Player> players = new ArrayList<Player>();

		for (@SuppressWarnings("rawtypes") HashMap playerDto : playersDto) {
			try {
				players.add(new Player(playerDto));
			} catch (ClassCastException ex) {
				Log.e(TAG, "Player DTO contained invalid value.");
				continue;
			}
		}

		return players;
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeInt(mCourseId);
		dest.writeString(mCourseName);
		dest.writeTypedList(mPlayers);
	}

	public List<Player> getPlayers() {
		return mPlayers;
	}

	public int getCourseId() {
		return mCourseId;
	}

	public String getCourseName() {
		return mCourseName;
	}

}
