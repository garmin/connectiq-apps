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

import android.os.Parcel;
import android.os.Parcelable;
import com.garmin.android.apps.samples.disgolf.AppConstants;
import com.garmin.monkeybrains.serialization.MonkeyHash;
import com.garmin.monkeybrains.serialization.MonkeyType;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class Course implements IQMonkeyConversion<Course>, Parcelable {

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

	public static final Parcelable.Creator CREATOR = new Parcelable.Creator() {
        @Override
		public Course createFromParcel(Parcel in) {
            return new Course(in);
        }

        @Override
		public Course[] newArray(int size) {
            return new Course[size];
        }
    };

    // ------------------------------------------------------------------------
    // FIELDS
    // ------------------------------------------------------------------------

	private final int mCourseId;
	private final String mCourseName;
	private final int mPar;
	private final int mTeesPlayed;
	private List<Hole> mHoles;
	private List<Player> mPlayers;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

	public Course(int courseId, String courseName, int par, int teesPlayed) {
		mCourseId = courseId;
		mCourseName = courseName;
		mPar = par;
		mTeesPlayed = teesPlayed;
		mHoles = new ArrayList<Hole>();
		mPlayers = new ArrayList<Player>();
	}

	public Course(Parcel in) {
		mCourseId = in.readInt();
		mCourseName = in.readString();
		mPar = in.readInt();
		mTeesPlayed = in.readInt();
		mHoles = new ArrayList<Hole>();
		in.readList(mHoles, Hole.class.getClassLoader());
		mPlayers = new ArrayList<Player>();
		in.readList(mPlayers, Player.class.getClassLoader());
	}

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

	public void addHole(Hole hole) {
		mHoles.add(hole);
	}

	public void setHoles(List<Hole> holes) {
		mHoles = holes;
	}

	public void addPlayer(Player player) {
		mPlayers.add(player);
	}

	public void setPlayers(List<Player> players) {
		mPlayers = players;
	}

	public String getCourseName() {
		return mCourseName;
	}

	@Override
	public MonkeyType toMonkeyObject() {
		HashMap<Object, Object> returnVal = new HashMap<Object, Object>();
		returnVal.put(AppConstants.KEY_COURSE_ID, mCourseId);
		returnVal.put(AppConstants.KEY_COURSE_NAME, mCourseName);
		returnVal.put(AppConstants.KEY_COURSE_PAR, mPar);
		returnVal.put(AppConstants.KEY_COURSE_TEES_PLAYED, mTeesPlayed);
		List<MonkeyType> holeMonkeys = new ArrayList<MonkeyType>();
		for (Hole hole : mHoles) {
			holeMonkeys.add(hole.toMonkeyObject());
		}
		returnVal.put(AppConstants.KEY_HOLES, holeMonkeys);
		List<MonkeyType> playerMonkeys = new ArrayList<MonkeyType>();
		for (Player player : mPlayers) {
			playerMonkeys.add(player.toMonkeyObject());
		}
		returnVal.put(AppConstants.KEY_PLAYERS, playerMonkeys);
		return new MonkeyHash(returnVal);
	}

	@Override
	public Course fromMonkeyObject(MonkeyType object) {
		// TODO Auto-generated method stub
		return null;
	}

	// ------------------------------------------------------------------------
    // Parcelable METHODS
    // ------------------------------------------------------------------------

	@Override
	public int describeContents() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeInt(mCourseId);
		dest.writeString(mCourseName);
		dest.writeInt(mPar);
		dest.writeInt(mTeesPlayed);
		dest.writeList(mHoles);
		dest.writeList(mPlayers);
	}

}
