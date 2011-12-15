module mine;

import std.stdio;
import std.random;
import jeca.all;

import base, unit, unitlist, ship, board;

class Mine: Unit {
private:
	int m_lifeTime;
	bool m_weaponBoost;
public:
	@property ref auto lifeTime() { return m_lifeTime; }

	this( int player0, bool weaponBoost0, double x, double y ) {
		mainType = UnitType.mine;
		player = player0;
		m_weaponBoost = weaponBoost0;
		xpos = x;
		ypos = y;
		lifeTime = 700;
	}
	
	override void process( Board board, UnitList unitList ) {
		--lifeTime;
		if ( lifeTime == 0 )
			unitList.remove( this );
		int otherShipId = player == 0 ? 1 : 0;
		auto otherShip = unitList[ otherShipId ];
		auto x = xpos,
			 y = ypos;
		if ( distance( x, y, otherShip.xpos + 12, otherShip.ypos + 12 ) < 12 + (m_weaponBoost ? 22 : 0) ) {
			g_snds[ Sound.blowUp ].speed = 0.6 + uniform( 0, 8 );
			g_snds[ Sound.blowUp ].play;
			(cast(Ship)otherShip).doDamage(m_weaponBoost ? 12 : 4);
			unitList.remove( this );
		}
	}
	
	override void draw() {
		if ( m_weaponBoost )
			al_draw_filled_rectangle( xpos, ypos - 3, xpos + 3, ypos + 6, Colour.red ), // vertical
			al_draw_filled_rectangle( xpos - 3, ypos, xpos + 6, ypos + 3, Colour.red ); // horrisontal(sp)
		al_draw_filled_rectangle( xpos, ypos, xpos + 3, ypos + 3, Colour.white );
	}
}
