using Toybox.Graphics;
using Toybox.WatchUi;

class CharacterFactory extends WatchUi.PickerFactory {
    hidden var mCharacterSet;
    hidden var mAddDone;
    hidden var mAddDelete;
    const DONE = -1;
    const DELETE = -2;

    function initialize(characterSet, options) {
        PickerFactory.initialize();
        mCharacterSet = characterSet;
        mAddDone = (null != options) and (options.get(:addDone) == true);
        mAddDelete = (null != options) and (options.get(:addDelete) == true);
    }

    function getIndex(value) {
        var index = mCharacterSet.find(value);
        return index;
    }

    function getSize() {
        return mCharacterSet.length() + ( mAddDone ? 1 : 0 ) + ( mAddDelete ? 1 : 0 );
    }

    function getValue(index) {
        if(index == mCharacterSet.length() and mAddDone) {
            return DONE;
        }
        else if(index >= mCharacterSet.length()) {
        	return DELETE;
        }

        return mCharacterSet.substring(index, index+1);
    }

    function getDrawable(index, selected) {
        if(index == mCharacterSet.length() and mAddDone) {
            return new WatchUi.Text( {:text=>Rez.Strings.characterPickerDone, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_LARGE, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
        }
        else if(index >= mCharacterSet.length()) {
            return new WatchUi.Text( {:text=>Rez.Strings.characterPickerBackspace, :color=>Graphics.COLOR_WHITE, :font=>Graphics.FONT_LARGE, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
        }

        return new WatchUi.Text( { :text=>getValue(index), :color=>Graphics.COLOR_WHITE, :font=> Graphics.FONT_LARGE, :locX =>WatchUi.LAYOUT_HALIGN_CENTER, :locY=>WatchUi.LAYOUT_VALIGN_CENTER } );
    }

    function isDone(value) {
        return mAddDone and (value == DONE);
    }
    
    function isDelete(value) {
        return mAddDelete and (value == DELETE);
    }
}
