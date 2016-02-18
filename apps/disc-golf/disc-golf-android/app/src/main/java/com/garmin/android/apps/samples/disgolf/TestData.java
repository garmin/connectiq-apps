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

import com.garmin.android.apps.samples.disgolf.course.Course;
import com.garmin.android.apps.samples.disgolf.course.Hole;
import com.garmin.android.apps.samples.disgolf.course.Player;

public class TestData {

	public static Course COURSE_ROSEDALE, COURSE_ROSEDALE_DOWNUNDER;

	static {
		COURSE_ROSEDALE = new Course(1337, "Rosedale Park", 54, 1);

		COURSE_ROSEDALE.addHole(new Hole( 1, 3, 299));
		COURSE_ROSEDALE.addHole(new Hole( 2, 3, 304));
		COURSE_ROSEDALE.addHole(new Hole( 3, 2, 233));
		COURSE_ROSEDALE.addHole(new Hole( 4, 3, 253));
		COURSE_ROSEDALE.addHole(new Hole( 5, 2, 245));
		COURSE_ROSEDALE.addHole(new Hole( 6, 3, 244));
		COURSE_ROSEDALE.addHole(new Hole( 7, 3, 260));
		COURSE_ROSEDALE.addHole(new Hole( 8, 3, 268));
		COURSE_ROSEDALE.addHole(new Hole( 9, 3, 290));
		COURSE_ROSEDALE.addHole(new Hole(10, 3, 268));
		COURSE_ROSEDALE.addHole(new Hole(11, 3, 238));
		COURSE_ROSEDALE.addHole(new Hole(12, 4, 305));
		COURSE_ROSEDALE.addHole(new Hole(13, 3, 315));
		COURSE_ROSEDALE.addHole(new Hole(14, 3, 301));
		COURSE_ROSEDALE.addHole(new Hole(15, 3, 272));
		COURSE_ROSEDALE.addHole(new Hole(16, 4, 301));
		COURSE_ROSEDALE.addHole(new Hole(17, 3, 274));
		COURSE_ROSEDALE.addHole(new Hole(18, 3, 285));

		COURSE_ROSEDALE.addPlayer(new Player("James Oregon", 1234));
		COURSE_ROSEDALE.addPlayer(new Player("Montana Smith", 5678));

		COURSE_ROSEDALE_DOWNUNDER = new Course(1338, "Shawnee Mission Park", 54, 1);

		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 1, 3, 198));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 2, 3, 241));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 3, 3, 241));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 4, 3, 282));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 5, 3, 218));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 6, 3, 226));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 7, 3, 208));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 8, 3, 228));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole( 9, 3, 245));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(10, 3, 227));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(11, 3, 275));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(12, 3, 249));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(13, 3, 246));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(14, 3, 260));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(15, 3, 160));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(16, 3, 259));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(17, 3, 270));
		COURSE_ROSEDALE_DOWNUNDER.addHole(new Hole(18, 3, 250));

		COURSE_ROSEDALE_DOWNUNDER.addPlayer(new Player("Jame Oregon", 1234));
		COURSE_ROSEDALE_DOWNUNDER.addPlayer(new Player("Montana Smith", 0));
		COURSE_ROSEDALE_DOWNUNDER.addPlayer(new Player("Dakota Williams", Integer.MIN_VALUE));
		COURSE_ROSEDALE_DOWNUNDER.addPlayer(new Player("Michael Fenix", Integer.MAX_VALUE));
	}

}
