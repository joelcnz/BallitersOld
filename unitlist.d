//#not work
// Removing through a loop in a class in the loop doesn't work properly except for remove( this )
module unitlist;

import std.stdio;
import jeca.misc;
import unit;

class UnitList {
private:
	Unit m_head, m_tail;
public:
	@property ref Unit head() { return m_head; }
	@property ref Unit tail() { return m_tail; }

	void append( Unit newUnit ) {
		if ( tail is null ) {
			head = tail = newUnit;
		}
		else {
			tail.next = newUnit;
			newUnit.previous = tail;
			tail = newUnit;
		}
	}

	int opApply(int delegate(ref Unit) dg) { // foreach (t; thg)
        int result = 0;

		Unit current = head;
		while (current !is null) {
			result = dg(current);
			if ( result )
				break;
			current = current.next;
		}
		return result;
	}

	int opApply(int delegate(ref int i, ref Unit) dg) { // foreach (i, t; thg)
        int result = 0;

		int i = 0;
		Unit current = head;
		while (current !is null) {
			result = dg(i, current);
			if ( result )
				break;
			++i;
			current = current.next;
		}
		return result;
	}

	Unit[] opSlice(int start, int end) {
		size_t len = length();
		if (end < 0)
			end=len+end+1; // eg len=5 end=-1 -> end=len
		Unit[] slice;
		int pos = 0;
		Unit current = head;
		while(current !is null && pos != start) {
			pos++;
			current = current.next;
		}
		while (current !is null && pos != end) {
			slice~=current;
			pos++;
			current = current.next;
		}
		return slice;
	}

	//#not work
	size_t opDollar() {
		return length;
	}

	Unit opIndex(uint index)
	{
		uint position = 0;
		Unit current = head;
		while (current.next !is null && position != index) {
			position++;
			current=current.next;
		}
		if (position != index)
			return null;
		return current;
	}

	Unit remove(Unit node) {
		if (node.previous !is null) {
			node.previous.next = node.next; // previous points to next
		}
		else {
			head = node.next;
		}
		
		if (node.next !is null)	{
			node.next.previous = node.previous; // next points to previous
		}
		else {
			tail = node.previous;
		}
		
		return node.previous !is null ? node.previous : node.next !is null ? node.next : null;
	}
	
	int length() {
		Unit current = head;
		int total = 0;
		while (current !is null) {
			++total;
			current = current.next;
		}
		return total;
	}
	
	void draw() {
		foreach( unit; this ) {
			unit.draw;
		}
	}
}
