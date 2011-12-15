//#obsolete
//#use reset after these
//#probably remove
//#less readable code
//#note this
//Removing through a loop in a class in the loop doesn't work properly except for remove( this )
module ship;

import std.stdio;
import std.string;
import std.random;
import std.math;
import std.conv: to;
import std.range;
import std.datetime;
import jeca.all;
import jext.all;
import base, unit, unitlist, lazer, mine, tkey, board, shield, larverbombblow;

class Ship: Unit {
private:
	immutable m_inc = 0.01;
	int m_timer;
	double m_faceAngle;
	static int m_idcurrent;
	int m_id;
	int kup, kright, kdown, kleft, kprimary, ksecondary, kspecial;
	TKey tKPrimary, tKSecondary, tKSpecial;
	Shield m_shield;
	int m_weaponBoosts;
	int m_flash;
	StopWatch m_flashTimer,
		m_blowUpTimer;
	LetterManager m_weaponBoostsText;
	bool m_scrap;
	Bmp[] m_blowUpGfx;
	ShipState m_state;
	int m_blowFrame;
	double aimDirx, aimDiry; //#note this
	alias dirx moveDirx;
	alias diry moveDiry;
	bool m_debugFlag;
public:
	@property ref auto faceAngle() { return m_faceAngle; }
	@property ref auto weaponBoosts() { return m_weaponBoosts; }
	@property ref auto shield() { return m_shield; }
	@property ref auto state() { return m_state; }
	@property ref auto timer() { return m_timer; }
	int shipId() { return m_id; }
	
	this( Bmp sprite0, Bmp[] blowUpGfx0, int x, int y, int[] keyCon ) {
		assert( keyCon.length == 7, "Wrong number of key bindings" );
		foreach( i, k; [& kup,
			            & kright,
			            & kdown,
			            & kleft,
			            & kprimary,
			            & ksecondary,
			            & kspecial] )
			*k = keyCon[i];
		
		tKPrimary   = new TKey( kprimary   );
		tKSecondary = new TKey( ksecondary );
		tKSpecial   = new TKey( kspecial   );

		m_id = m_idcurrent;
		player = m_id; // 0 or 1
		m_state = ShipState.good;
		++m_idcurrent;
		reset;

		mainType = UnitType.ship;
		sprite = sprite0;
		m_blowUpGfx = blowUpGfx0;

		m_shield = new Shield( player );

		m_weaponBoostsText = new LetterManager(Bmp.loadBitmap( `fonts\`~"lemgreen.bmp"),
											   Square( 0, 0, DISPLAY_W, DISPLAY_H ), 8, 17 );

		faceAngle = 0;

		//#use reset after these
		m_flashTimer.start;
		m_blowUpTimer.start;

		timer = g_shipTimer; // includes other things
	}
	
	override void process( Board board, UnitList unitList ) {
		altControl(board, unitList);
	}

	void doDamage( int damage ) {
		m_shield.amount -= damage;
		if ( m_shield.amount <= 0 )
			m_shield.amount = 0,
			m_state = ShipState.blowingUp,
			m_blowFrame = 0,
			m_blowUpTimer.reset;
		m_flash = true;
		m_flashTimer.reset;
	}

	int opCmp(Object other) { // operator compare
		return shield.amount-(cast(Ship)other).shield.amount;
	}

	bool opEquals(Object other) {
		return shield.amount == (cast(Ship)other).shield.amount;
	}

	int opCall() {
		return shield.amount;
	}
	
	override void draw() {
		if ( m_state == ShipState.good ) {
			if (m_flash)
				al_draw_bitmap( g_flashGfx.bitmap, xpos, ypos, 0 );
			else
				al_draw_bitmap( sprite.bitmap, xpos, ypos, 0 );
			alias aimDirx distx;
			alias aimDiry disty;
			al_draw_line( xpos + sprite.width / 2 - 2, ypos + sprite.height / 2 - 2,
							xpos + sprite.width / 2 - 2 + distx, ypos + sprite.height / 2 - 2 + disty, Colour.yellow, 3 );

			al_draw_line( xpos + sprite.width / 2 - 2, ypos + sprite.height / 2 - 2,
						 xpos + sprite.width / 2 - 2 + moveDirx * 20, ypos + sprite.height / 2 - 2 + moveDiry * 20,
						Colour.red, 3 );
			if (m_debugFlag)
				al_draw_filled_circle(xpos + sprite.width / 2 - 2, ypos + sprite.height / 2 - 2,
									  10, Colour.blue);

			m_shield.draw;
			if ( m_weaponBoosts > 0 )
				with( m_weaponBoostsText ) {
					square = Square( player == 0 ? 20 : DISPLAY_W - 50, DISPLAY_H - 70, DISPLAY_W, DISPLAY_H );
					setText( to!string( m_weaponBoosts ) );
					draw( g_Draw.text );
				}
			if ( g_toDisplay & Show.players ) {
				with( m_weaponBoostsText ) {
					square = Square( 0, player == 0 ? 100 : 100 + 64, DISPLAY_W, DISPLAY_H );
					setText( format( "x: %-3.2f y: %-3.2f\n", xpos, ypos ) );
					addTextln( format( "moveDirx=%-3.2f, moveDiry=%-3.2f", moveDirx, moveDiry ) );
					draw( g_Draw.text );
				}
			}
		} else {// state good
			if ( m_state == ShipState.blowingUp )
				al_draw_bitmap(m_blowUpGfx[m_blowFrame].bitmap, xpos, ypos, 0);
		}
	}

	void reset() {
		moveDirx = moveDiry = 0f;
		xpos = g_ballStartPostions[player * 2];
		ypos = g_ballStartPostions[player * 2 + 1];
	}

	void altControl(Board board, UnitList unitList) {
		if ( m_state == ShipState.destroyed )
			return;
		if ( m_state == ShipState.blowingUp ) {
			if ( m_blowUpTimer.peek().msecs > 100 ) {
				++m_blowFrame;
				if ( m_blowFrame > 6 ) {
					g_morris.play;
					m_state = ShipState.destroyed;
				}
				m_blowUpTimer.reset;
			}
			xpos += dirx / 2;
			ypos += diry / 2;
		} else {
			if ( m_flash && m_flashTimer.peek().msecs > 100 )
				m_flash = false;

			//#probably remove
			if (m_flash)
				return;

			auto otherPlayer = unitList[player == 0 ? 1 : 0];

			poll_input;
			
			if ( key[ kleft ] )
				faceAngle -= 0.02;
			if ( key[ kright ] )
				faceAngle += 0.02;
			xyaim( aimDirx, aimDiry, 20, faceAngle );

			double dx,dy, lastMoveDirx = moveDirx, lastMoveDiry = moveDiry;
			xyaim( dx, dy, m_inc, faceAngle );
			bool isKeyUp = false, isKeyDown = false;
			if ( key[ kup ] )
				isKeyUp=true,
				moveDirx += dx,
				moveDiry += dy;
			if ( key[ kdown ] )
				isKeyDown=true,
				moveDirx -= dx,
				moveDiry -= dy;
			// test for speed out side limit, if so, then set back at previous speed
			m_debugFlag=false;
			foreach(mDir; [moveDirx, moveDiry])
				if (mDir < -1 || mDir > 1) {
					m_debugFlag=true;
					moveDirx = lastMoveDirx,
					moveDiry = lastMoveDiry;
					double moveAngle = getAngle(0,0, moveDirx, moveDiry);
					if (faceAngle < moveAngle) {
						moveAngle += 0.02;
						if (faceAngle > moveAngle)
							moveAngle=faceAngle;
					}
					else {
						moveAngle -= 0.02;
						if (faceAngle < moveAngle)
							moveAngle=faceAngle;
					}
					xyaim(moveDirx, moveDiry, 1f, moveAngle);
					//break;
				}

			if (isKeyUp + isKeyDown == false) { //#less readable code
				double sdx,sdy; // sd - Slow Down
				xyaim(sdx, sdy, 0.003, getAngle(xpos, ypos, xpos+moveDirx, ypos+moveDiry));
				moveDirx -= sdx;
				moveDiry -= sdy;
				if (abs(moveDirx) < 0.02 && abs(moveDiry) < 0.02)
					moveDirx = moveDiry = 0;
			}
			
			if ( tKPrimary.keyTrigger || tKSpecial.keyPress) {
				g_snds[ Sound.shoot ].play;
				double aimDirx, aimDiry;
				xyaim( aimDirx, aimDiry, 1, faceAngle );
				unitList.append( new Lazer( player, weaponBoosts > 0, xpos + sprite.width / 2 - 2, ypos + sprite.height / 2 - 2,
										aimDirx, aimDiry ) );
				bumpLimit(weaponBoosts, -1, 0);
			}

			if ( tKSecondary.keyTrigger ) {
				unitList.append( new Mine( player, weaponBoosts > 0, xpos + sprite.width / 2 - 2 - 1, ypos + sprite.height / 2 - 2 - 1 ) );
				bumpLimit(weaponBoosts, -1, 0);
			}
/+
//			if ( tKSpecial.keyPress ) {
			if ( tKSpecial.keyTrigger ) {
				foreach( c; 0 .. 100 ) {
					unitList.append( new Mine( player, false, uniform( 0, DISPLAY_W ) - 1, uniform( 0, DISPLAY_H ) - 1 ) );
				}
			}
+/
			bool hit( double stx, double  sty ) {
				foreach( y; iota(sty , sty + 24, 24 - 1 * 3) ) {
					foreach( x; iota(stx, stx + 24, 24 - 1 * 3) ) {
						void clearPiece() {
							auto piece = board.piece(x,y);
							with( piece )
								type = PieceType.darkBrick,
								draw;
						}
						switch( board.getPieceType( x, y ) ) {
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
								unitList.append(new LarverBombBlow(player, x, y));
								clearPiece;
								break;
						} // switch
						bool brickHit = board.hitBrick( x, y );
						bool otherShipHit = (cast(Ship)otherPlayer).state == ShipState.good
							&& x > otherPlayer.xpos && x < otherPlayer.xpos + 24
							&& y > otherPlayer.ypos && y < otherPlayer.ypos + 24;
						if ( brickHit || otherShipHit )
							return true;
					}
				}
				return false;
			}

			double stepx = moveDirx,
				stepy = moveDiry;
			xpos += stepx;
			if ( hit( xpos, ypos ) )
				xpos -= stepx, xpos = cast(int)xpos, moveDirx *= -1f, moveDirx /= 3f;
			ypos +=  stepy;
			if ( hit( xpos, ypos ) )
				ypos -= stepy, ypos = cast(int)ypos, moveDiry *= -1f, moveDiry /= 3f;

			if ( xpos > DISPLAY_W ) xpos = DISPLAY_W - 24;
			if ( xpos < 0 ) xpos = 0;
			if ( ypos > DISPLAY_H ) ypos = DISPLAY_H - 24;
			if ( ypos < 0 ) ypos = 0;
		} // (else) ShipState.good
	} // altControl
}
