module tkey;

import jeca.all;

class TKey {
	int tKey;
	bool keyDown;
	this( int tkey0 ) {
		tKey = tkey0;
		keyDown = false;
	}
	
	bool keyTrigger() {
		if ( key[ tKey ] ) {
			if ( keyDown == true )
				return false;
			else {
				keyDown = true;
				return true;
			}
		} else // not pressing key
			keyDown = false;
		return false;
	}

	bool keyPress() {
		return key[tKey] > 0;
	}
}
