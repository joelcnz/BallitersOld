//#lazer Start
module lazer;

import std.stdio;
import std.random;
import jeca.all;

import base, unit, unitlist, ship, board, weakbrickblow, larverbombblow;

class Lazer: Unit {
private:
	double m_dirx, m_diry, m_boltEndx, m_boltEndy;
	bool m_weaponBoost;
	int m_wallTime;
public:
	this( int player0, bool weaponBoost0, double x, double y, double gunEndx, double gunEndy ) {
		player = player0;
		m_weaponBoost = weaponBoost0;
		mainType = UnitType.lazer;
		xpos = x;
		ypos = y;
		m_boltEndx = gunEndx;
		m_boltEndy = gunEndy;
		double dis = distance( xpos, ypos, xpos + gunEndx * 2, ypos + gunEndy * 2 );
		xyaim( m_dirx, m_diry, dis, getAngle( xpos, ypos, xpos + gunEndx, ypos + gunEndy ) );
		m_wallTime = 20;
	}
	
	override void process( Board board, UnitList unitList ) {
		int otherShipId = player == 0 ? 1 : 0; /+ other ship +/
		auto otherShip = unitList[ otherShipId ];

		bool hit = false;
		auto x = xpos,
			 y = ypos;
		x += m_boltEndx * 10;
		y += m_boltEndy * 10;
		int hitWeakBrickx = pos(xpos + m_boltEndx * 5),
			hitWeakBricky = pos(ypos + m_boltEndy * 5);
		if ( board.map[hitWeakBricky][hitWeakBrickx].type == PieceType.larverBomb ) {
			unitList.append(new LarverBombBlow(player, x,y));
			board.map[hitWeakBricky][hitWeakBrickx].type = PieceType.darkBrick;
			board.map[hitWeakBricky][hitWeakBrickx].draw;
			if (! m_weaponBoost)
				hit=true;
			else
				m_weaponBoost=false;
		}
		if ( board.map[hitWeakBricky][hitWeakBrickx].type == PieceType.weakBrick ) {
			board.map[hitWeakBricky][hitWeakBrickx].type = PieceType.darkBrick;
			board.map[hitWeakBricky][hitWeakBrickx].draw;
			unitList.append( new WeakBrickBlow( player, hitWeakBrickx * 24, hitWeakBricky * 24 ) );
			g_snds[ Sound.blowUp ].speed = 0.6 + uniform( 0, 8 );
			g_snds[ Sound.blowUp ].play;
			if ( ! m_weaponBoost )
				hit = true;
			else
				m_weaponBoost = false;
		}
		if ( distance( x, y, otherShip.xpos + 12, otherShip.ypos + 12 ) < 16 + (m_weaponBoost ? 12 : 0) ) {
			g_snds[ Sound.blowUp ].speed = 0.6 + uniform( 0, 8 );
			g_snds[ Sound.blowUp ].play;
			hit = true;
			(cast(Ship)otherShip).doDamage( m_weaponBoost ? 4 : 2 );
			++(cast(Ship)unitList[ player ]).score;
		}
		if ( m_wallTime == 0 && board.hitBrick( xpos + m_boltEndx * 5, ypos + m_boltEndy * 5 ) ) // 5 - half way down the bolt
			hit = true;
		if ( hit || xpos < 0 || xpos > DISPLAY_W || ypos < 0 || ypos > DISPLAY_H )
			unitList.remove( this );
		xpos += m_dirx;
		ypos += m_diry;
		if ( m_wallTime > 0 )
			--m_wallTime;
	}
	
	override void draw() {
		al_draw_line( xpos, ypos, xpos + m_boltEndx * 20, ypos + m_boltEndy * 20,
			m_weaponBoost ? Colour.red : Colour.white, 3 );
	}
}
//#lazer end

draw:
				al_draw_line( xpos + sprite.width / 2 - 2, ypos + sprite.height / 2 - 2,
					xpos + sprite.width / 2 - 2 + m_gunEndx * 20, ypos + sprite.height / 2 - 2 + m_gunEndy * 20, Colour.yellow, 3 );


	void hardControl(Board board, UnitList unitList) {
		if ( m_state == ShipState.destroyed )
			return;
		if ( m_state == ShipState.blowingUp ) {
			if ( m_blowUpTimer.peek().msecs > 100 ) {
				++m_blowFrame;
				if ( m_blowFrame > 6 )
					m_state = ShipState.destroyed;
				m_blowUpTimer.start;
			}
			xpos += m_gunEndx / 3;
			ypos += m_gunEndy / 3;
		} else {
			if ( m_flash && m_flashTimer.peek().msecs > 100 )
				m_flash = false;

			auto otherPlayer = unitList[ player == 0 ? 1 : 0 ];

			poll_input;
			immutable inc = 0.02;
			if ( key[ kleft ] )
				m_gunEndx -= inc;
			if ( key[ kright ] )
				m_gunEndx += inc;
			if ( key[ kup ] )
				m_gunEndy -= inc;
			if ( key[ kdown ] )
				m_gunEndy += inc;

			if ( tKPrimary.keyPress && abs(m_gunEndx) + abs(m_gunEndy) > 0 ) {
				g_snds[ Sound.shoot ].play;
				unitList.append( new Lazer( player, weaponBoosts > 0, xpos + sprite.width / 2 - 2, ypos + sprite.height / 2 - 2, m_gunEndx, m_gunEndy ) );
				if ( --weaponBoosts < 0 )
					weaponBoosts = 0;
			}

			if ( tKSecondary.keyPress ) {
				unitList.append( new Mine( player, weaponBoosts > 0, xpos + sprite.width / 2 - 2 - 1, ypos + sprite.height / 2 - 2 - 1 ) );
				if ( --weaponBoosts < 0 )
					weaponBoosts = 0;
			}

			if ( tKSpecial.keyPress ) {
				foreach( c; 0 .. 1_00 ) {
					unitList.append( new Mine( player, false, uniform( 0, DISPLAY_W ) - 1, uniform( 0, DISPLAY_H ) - 1 ) );
				}
			}

			if ( m_gunEndx < -1 ) { 
				m_gunEndx = -1;
				if ( m_gunEndy < 0 ) m_gunEndy += inc;
				if ( m_gunEndy > 0 ) m_gunEndy -= inc;
			}
			if ( m_gunEndx >  1 ) {
				m_gunEndx =  1;
				if ( m_gunEndy < 0 ) m_gunEndy += inc;
				if ( m_gunEndy > 0 ) m_gunEndy -= inc;
			}
			if ( m_gunEndy < -1 ) {
				m_gunEndy = -1;
				if ( m_gunEndx < 0 ) m_gunEndx += inc;
				if ( m_gunEndx > 0 ) m_gunEndx -= inc;
			}
			if ( m_gunEndy >  1 ) {
				m_gunEndy =  1;
				if ( m_gunEndx < 0 ) m_gunEndx += inc;
				if ( m_gunEndx > 0 ) m_gunEndx -= inc;
			}

			if ( abs( m_gunEndx ) < inc )
				m_gunEndx = 0;
			if ( abs( m_gunEndy ) < inc )
				m_gunEndy = 0;

			bool hit( double stx, double  sty ) {
				foreach( y; sty .. sty + 24 ) {
					foreach( x; stx .. stx + 24 ) {
						void clearPiece() {
							board.piece(x,y).type = PieceType.darkBrick;
							board.piece(x,y).draw;
						}
						switch( board.getPiece( x, y ) ) {
							default:
								break;
							case PieceType.shieldBoost:
								shield.amount += 30;
								if ( m_shield.amount > 200 )
									m_shield.amount = 200;
								clearPiece;
								break;
							case PieceType.weaponBoostThree:
								weaponBoosts += 3;
								clearPiece;
								break;
							case PieceType.weaponBoostTen:
								weaponBoosts += 10;
								clearPiece;
								break;
							case PieceType.larverBomb:
								clearPiece; // just clear it, it's harmless
								break;
						} // switch
						bool brickHit = board.hitBrick( x, y );
						bool otherShipHit = (cast(Ship)otherPlayer).state == ShipState.good
							&& x > otherPlayer.xpos && x < otherPlayer.xpos + 24
							&& y > otherPlayer.ypos && y < otherPlayer.ypos + 24;
						if ( brickHit || otherShipHit ) {
							m_scrap = true;
							return true;
						}
						x += 23 - 1;
					}
					y += 23 - 1;
				}
				return false;
			}

			double stepx = m_scrap ? m_gunEndx / 3 : m_gunEndx;
			double stepy = m_scrap ? m_gunEndy / 3 : m_gunEndy;
			m_scrap = false;
			xpos += stepx;
			if ( hit( xpos, ypos ) )
				xpos -= stepx, xpos = cast(int)xpos;
			ypos +=  stepy;
			if ( hit( xpos, ypos ) )
				ypos -= stepy, ypos = cast(int)ypos;

			if ( xpos > DISPLAY_W ) xpos = DISPLAY_W - 24;
			if ( xpos < 0 ) xpos = 0;
			if ( ypos > DISPLAY_H ) ypos = DISPLAY_H - 24;
			if ( ypos < 0 ) ypos = 0;
		} // (else) State.good
	} // hardControl
