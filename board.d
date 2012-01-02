//#not great
module board;

import std.stdio;
import std.string;
import jeca.all;
import base, piece;

/**
Board class for the bricks and stuff that just sits there
 */
class Board {
private:
	Bmp[] m_pieces;
	Piece[][] m_map;
	Bmp m_levelGfx;
public:
	@property ref auto pieces() { return m_pieces; }
	@property ref auto map() { return m_map; }
	@property ref auto levelGfx() { return m_levelGfx; }
	
	this( Bmp[] pieces0, string level ) {
		pieces = pieces0;
		//load from file on disk
		auto levelFile = File( level, "r" );
		int ver, width, height;
		levelFile.readf( "%d %d %d", &ver, &width, &height ); levelFile.readln;
		//writeln( "Version: ", ver, " Width: ", width, " Height: ", height );
		m_levelGfx = new Bmp( DISPLAY_W, DISPLAY_H );
		auto previousBitmap = al_get_target_bitmap;
		al_set_target_bitmap( m_levelGfx.bitmap );
		al_clear_to_color( Colour.black );
		map = new Piece[][]( height, width );
		foreach( y; 0 .. height ) {
			string row;
			levelFile.readln( row );
			foreach( x; 0 .. width ) {
				PieceType id = row[x] == 'B' ? PieceType.brick : row[x] == 'w' ? PieceType.blank : PieceType.darkBrick;
				map[y][x] = new Piece( id, x * 24, y* 24, pieces, m_levelGfx );
				map[y][x].draw;
			}
		}
		al_set_target_bitmap( previousBitmap );
	}
	
	bool hitBrick(double x, double y) {
		if (   x > 0 && x < 40 * 24
			&& y > 0 && y < 25 * 24 )
			return map[pos(y)][pos(x)].type != PieceType.darkBrick;
		return false; // or should it be true
	}

	bool inBounds(double x, double y) {
		if (   x >= 0 && x < 40 * 24
			&& y >= 0 && y < 25 * 24 )
			return true;
		return false;
	}

	/// Gets piece from a point in the screen, scales it down to pieces
	Piece piece( double x, double y ) {
//		if (   x >= 0 && x < 40 * 24
//			&& y >= 0 && y < 25 * 24 )
		if (inBounds(x, y))
			return map[pos(y)][pos(x)];
		return map[0][0]; //#not great
	}

	PieceType getPieceType(double x, double y) {
//		if (   x > 0 && x < 40 * 24
//			&& y > 0 && y < 25 * 24 )
		if (inBounds(x, y))
				return map[pos(y)][pos(x)].type;
		return PieceType.blank;
	}
	
	void draw() {
		al_draw_bitmap( m_levelGfx.bitmap, 0, 0, 0 );
	}
}
