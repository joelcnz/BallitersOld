module larverbombblow;

import std.stdio;
import std.datetime;
import std.range: iota;
import jeca.all;
import base, unitlist, board, unit, ship, weakbrickblow;

class LarverBombBlow: Unit {
private:
	int m_frame;
	StopWatch m_frameTimer;
public:
	@property ref auto frame() { return m_frame; }
	@property ref auto frameTimer() { return m_frameTimer; }

	this(int player0, double x, double y) {
		player = player0;
		xpos = pos(x) * 24f - 24f * 2;
		ypos = pos(y) * 24f - 24f * 2;
		frame = 0;
		frameTimer.start;
	}

	override void process(Board board, UnitList unitList) {
		if (frameTimer.peek().msecs > 140) {
			foreach( y; iota( ypos, ypos + 5 * 24, 24 ) )
				foreach( x; iota( xpos, xpos + 5 * 24, 24 ) )
					if (board.inBounds(x, y)) {
						if (board.piece(x, y).type == PieceType.larverBomb) {
							unitList.append(new LarverBombBlow(player, x, y));
							board.piece(x, y).type = PieceType.darkBrick;
							board.piece(x, y).draw;
						}
						if (board.piece(x, y).type == PieceType.weakBrick) {
							unitList.append(new WeakBrickBlow(player, x, y));
							board.piece(x, y).type = PieceType.darkBrick;
							board.piece(x, y).draw;
						}
						foreach1: foreach(i, unit; unitList) {
							if ( i == 2 )
								break foreach1;
							if (   x >= unit.xpos
								&& x <  unit.xpos + 24
								&& y >= unit.ypos
								&& y <  unit.ypos + 24) {
								(cast(Ship)unit).doDamage( 25 );
							}
						}
					} // in bounds
			++frame;
			if (frame == g_larverBlowFramesGfx.length)
				unitList.remove(this);
			else
				frameTimer.reset;
		}
	}

	override void draw() {
		foreach( y; iota( ypos, ypos + 5 * 24, 24 ) )
			foreach( x; iota( xpos, xpos + 5 * 24, 24 ) )
				al_draw_bitmap(g_larverBlowFramesGfx[frame].bitmap, x, y, 0);
	}
}
