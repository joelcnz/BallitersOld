//#What about not? Let the amount go over 200
module weakbrickblow;

import std.random;
import std.datetime;
import jeca.all;
import base, unitlist, unit, board, ship;

class WeakBrickBlow: Unit {
private:
	int m_frame,
		m_blowUpFrameSet;
	StopWatch m_timer;
public:
	this(int player0, double x, double y) {
		player=player0;
		xpos=x;
		ypos=y;
		m_blowUpFrameSet=uniform(0, 13);
		m_timer.start;
	}

	override void process(Board board, UnitList unitList) {
		if ( m_timer.peek().msecs > 60 ) {
			if ( ++m_frame == 6 ) {
				unitList.remove( this );
				if (g_gameType != GameType.suddenDeath)
					(cast(Ship)unitList[player]).shield.amount+=2;
			}
			m_timer.reset;
		}
	}

	override void draw() {
		al_draw_bitmap( g_frameGfx[m_blowUpFrameSet][m_frame].bitmap, xpos, ypos, 0 );
	}
}
