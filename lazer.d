module lazer;

import std.stdio;
import std.random;
import jeca.all;

import base, unit, unitlist, ship, board, weakbrickblow, larverbombblow;

class Lazer: Unit {
private:
	bool m_weaponBoost;
	int m_wallTime;
public:

	this( int player0, bool weaponBoost0, double x, double y, double dirx0, double diry0 ) {
		player = player0;
		m_weaponBoost = weaponBoost0;
		mainType = UnitType.lazer;
		xpos = x;
		ypos = y;
		dirx = dirx0 * 2;
		diry = diry0 * 2;
		m_wallTime = 20;
	}
	
	override void process( Board board, UnitList unitList ) {
		int otherShipId=player == 0 ? 1 : 0; /+ other ship +/
		auto otherShip=unitList[otherShipId];

		bool hit = false;
		auto x = xpos,
			 y = ypos;
		x += dirx * 10;
		y += diry * 10;
		int hitWeakBrickx = pos(xpos + dirx * 5),
			hitWeakBricky = pos(ypos + diry * 5);
		if (board.getPieceType(hitWeakBrickx*24, hitWeakBricky*24) == PieceType.larverBomb) {
			unitList.append(new LarverBombBlow(player, x,y));
			board.map[hitWeakBricky][hitWeakBrickx].type = PieceType.darkBrick;
			board.map[hitWeakBricky][hitWeakBrickx].draw;
			if (! m_weaponBoost)
				hit=true;
			else
				m_weaponBoost=false;
		}
		if (board.getPieceType(hitWeakBrickx*24, hitWeakBricky*24) == PieceType.weakBrick ) {
			board.map[hitWeakBricky][hitWeakBrickx].type = PieceType.darkBrick;
			board.map[hitWeakBricky][hitWeakBrickx].draw;
			unitList.append( new WeakBrickBlow( player, hitWeakBrickx * 24, hitWeakBricky * 24 ) );
			int blowId=uniform(0, g_smallBlows.length);
			g_smallBlows[blowId].speed=0.4+uniform(0, 1.2);
			g_smallBlows[blowId].play;
			//g_snds[blowId].speed=0.6 + uniform( 0, 0.8 );
			//g_snds[blowId].play;
			//g_morris.speed = 0.6 + uniform( 0, 0.8 );
			//g_morris.play;
			if ( ! m_weaponBoost )
				hit = true;
			else
				m_weaponBoost = false;
		}
		if ((cast(Ship)otherShip).state == ShipState.good
			&& distance(x, y, otherShip.xpos + 12, otherShip.ypos + 12) < 16 + (m_weaponBoost ? 12 : 0)) {
			g_snds[Sound.blowUp].speed=0.6 + uniform(0, 0.8);
			g_snds[Sound.blowUp].play;
			hit = true;
			(cast(Ship)otherShip).doDamage(m_weaponBoost ? 6 : 2);
		}
		if ( m_wallTime == 0 && board.hitBrick( xpos + dirx * 5, ypos + diry * 5 ) ) // 5 - half way down the bolt
			hit = true;
		if ( hit || xpos < 0 || xpos > DISPLAY_W || ypos < 0 || ypos > DISPLAY_H )
			unitList.remove(this);
		xpos += dirx;
		ypos += diry;
		if ( m_wallTime > 0 )
			--m_wallTime;
	}
	
	override void draw() {
		al_draw_line( xpos, ypos, xpos + dirx * 10, ypos + diry * 10,
			m_weaponBoost ? Colour.red : Colour.white, 3 );
	}
}
