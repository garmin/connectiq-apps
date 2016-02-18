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

import java.util.HashMap;

import android.os.Parcel;
import android.os.Parcelable;

import com.garmin.android.apps.samples.disgolf.AppConstants;
import com.garmin.monkeybrains.serialization.MonkeyHash;
import com.garmin.monkeybrains.serialization.MonkeyType;

public class Hole implements IQMonkeyConversion<Hole>, Parcelable {

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
		public Hole createFromParcel(Parcel in) {
            return new Hole(in);
        }

        @Override
		public Hole[] newArray(int size) {
            return new Hole[size];
        }
    };

    // ------------------------------------------------------------------------
    // FIELDS
    // ------------------------------------------------------------------------

	private final int mNumber;
	private final int mPar;
	private final int mDistance;

    // ------------------------------------------------------------------------
    // INITIALIZERS
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // CONSTRUCTORS
    // ------------------------------------------------------------------------

	public Hole(int number, int par, int distance) {
		mNumber = number;
		mPar = par;
		mDistance = distance;
	}

	public Hole(Parcel in) {
		mNumber = in.readInt();
		mPar = in.readInt();
		mDistance = in.readInt();
	}

    // ------------------------------------------------------------------------
    // METHODS
    // ------------------------------------------------------------------------

	@Override
	public MonkeyType toMonkeyObject() {
		HashMap<Object, Object> returnVal = new HashMap<Object, Object>();
		returnVal.put(AppConstants.KEY_HOLE_NUMBER, mNumber);
		returnVal.put(AppConstants.KEY_HOLE_PAR, mPar);
		returnVal.put(AppConstants.KEY_HOLE_DISTANCE, mDistance);
		return new MonkeyHash(returnVal);
	}

	@Override
	public Hole fromMonkeyObject(MonkeyType object) {
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
		dest.writeInt(mNumber);
		dest.writeInt(mPar);
		dest.writeInt(mDistance);
	}

}
