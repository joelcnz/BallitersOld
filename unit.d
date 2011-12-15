module unit;

import jeca.all;
import board, unitlist;

abstract class Unit {
private:
	Unit m_previous, m_next;
	int m_mainType; // e.g ship, lazer
	int m_player;
	Bmp m_sprite;
	double m_xpos, m_ypos, m_dirx, m_diry;
public:
	@property ref auto xpos() { return m_xpos; }
	@property ref auto ypos() { return m_ypos; }
	@property ref auto dirx() { return m_dirx; }
	@property ref auto diry() { return m_diry; }
	@property ref auto sprite() { return m_sprite; }
	@property ref auto previous() { return m_previous; }
	@property ref auto next() { return m_next; }
	@property ref auto mainType() { return m_mainType; }
	@property ref auto player() { return m_player; }
	
	void process( Board, UnitList ) {}
	void draw() {}
	void selfDestruct( UnitList unitList ) {
		unitList.remove( this );
	}
}
