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

using Toybox.Graphics as Gfx;

class PageIndicator {

    static var ALIGN_BOTTOM_RIGHT = 0;
    static var ALIGN_BOTTOM_LEFT = 1;
    static var ALIGN_TOP_RIGHT = 2;
    static var ALIGN_TOP_LEFT = 3;

    var mSize, mSelectedColor, mNotSelectedColor, mAlignment, mMargin, mDevice;

    function setup(size, selectedColor, notSelectedColor, alignment, margin) {
        mSize = size;
        mSelectedColor = selectedColor;
        mNotSelectedColor = notSelectedColor;
        mAlignment = alignment;
        mMargin = margin;
        mDevice = Toybox.WatchUi.loadResource(Rez.Strings.device);
    }

    function draw(dc, selectedIndex) {
        // For the fenix 3 we'll draw up and down arrows at the top and
        // bottom of the screen no matter what.
        if (mDevice.equals("fenix3")) {
            dc.setColor(mNotSelectedColor, Gfx.COLOR_TRANSPARENT);
            dc.fillPolygon([ [100,10], [109,3], [118,10] ]);
            dc.fillPolygon([ [100,208], [109,215], [118,208] ]);

        // For the vivoactive and 920 we'll abide by the alignment passed
        // into the constructor.
        } else {
            var height = 10;
            var width = mSize * height;
            var x = 0;
            var y = 0;

            if (mAlignment == ALIGN_BOTTOM_RIGHT) {
                x = dc.getWidth() - width - mMargin;
                y = dc.getHeight() - height - mMargin;

            } else if (mAlignment == ALIGN_BOTTOM_LEFT) {
                x = 0 + mMargin;
                y = dc.getHeight() - height - mMargin;

            } else if (mAlignment == ALIGN_TOP_RIGHT) {
                x = dc.getWidth() - width - mMargin;
                y = 0 + mMargin;

            } else if (mAlignment == ALIGN_TOP_LEFT) {
                x = 0 + mMargin;
                y = 0 + mMargin;
            } else {
                x = 0;
                y = 0;
            }

            for (var i=0; i<mSize; i+=1) {
                if (i == selectedIndex) {
                    dc.setColor(mSelectedColor, Gfx.COLOR_TRANSPARENT);
                } else {
                    dc.setColor(mNotSelectedColor, Gfx.COLOR_TRANSPARENT);
                }

                var tempX = (x + (i * height)) + height / 2;
                dc.fillCircle(tempX, y, height / 2);
            }
        }
    }

}
