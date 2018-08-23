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

import com.garmin.android.apps.samples.disgolf.AppConstants;
import com.garmin.monkeybrains.serialization.MonkeyHash;
import com.garmin.monkeybrains.serialization.MonkeyType;

public class Player implements IQMonkeyConversion<Player>, Parcelable {

	// ------------------------------------------------------------------------
    // TYPES
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // STATIC FIELDS
    // ------------------------------------------------------------------------

	public static final Parcelable.Creator<Player> CREATOR = new Parcelable.Creator<Player>() {
		@Override
		public Player createFromParcel(Parcel in) {
			return new Player(in);
		}

		@Override
		public Player[] newArray(int size) {
			return new Player[size];
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

	private final String mName;
	private final int mId;
	private final List<Integer> mScores;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

	public Player(String name, int id) {
		mName = name;
		mId = id;
		mScores = null;
	}

	public Player(@SuppressWarnings("rawtypes") HashMap playerDto) throws ClassCastException {
		mName = (String) playerDto.get(AppConstants.KEY_PLAYER_NAME);
		Object playerId = playerDto.get(AppConstants.KEY_PLAYER_ID);
		if (playerId != null && playerId instanceof Integer) {
			mId = (Integer) playerId;
		} else {
			mId = -1;
		}

		mScores = new ArrayList<Integer>();
		@SuppressWarnings("unchecked")
		ArrayList<Integer> scoresDto = (ArrayList<Integer>) playerDto.get(AppConstants.KEY_PLAYER_SCORES);
		for (Integer scoreDto : scoresDto) {
			if (scoreDto == null) {
				mScores.add(0);
			} else {
				mScores.add(scoreDto);
			}
		}
	}

	public Player(Parcel parcel) {
		mName = parcel.readString();
		mId = parcel.readInt();
		mScores = new ArrayList<Integer>();
		parcel.readList(mScores, Integer.class.getClassLoader());
	}

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

	@SuppressWarnings("rawtypes")
	@Override
	public MonkeyType toMonkeyObject() {
		HashMap<Object, Object> returnVal = new HashMap<Object, Object>();
		returnVal.put(AppConstants.KEY_PLAYER_NAME, mName);
		returnVal.put(AppConstants.KEY_PLAYER_ID, mId);
		return new MonkeyHash(returnVal);
	}

	@SuppressWarnings("rawtypes")
	@Override
	public Player fromMonkeyObject(MonkeyType object) {
		// TODO Auto-generated method stub
		return null;
	}

	public String getName() {
		return mName;
	}

	public String getFormattedScore() {
		if (mScores == null) {
			return "-";
		}

		int totalScore = 0;
		for (Integer score : mScores) {
			totalScore += score;
		}

		return Integer.toString(totalScore);
	}

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(mName);
		dest.writeInt(mId);
		dest.writeList(mScores);
	}

}
