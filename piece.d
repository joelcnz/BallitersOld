module piece;

import std.stdio;
import jeca.all;
import base;

//enum PieceType {brick, darkBrick};

class Piece {
private:
	double m_xpos, m_ypos;
	Bmp[] m_piecesGfx;
	Bmp m_boardGfx;
	PieceType m_type;
public:
	@property ref PieceType type() { return m_type; }
	@property ref auto xpos() { return m_xpos; }
	@property ref auto ypos() { return m_ypos; }
	@property ref Bmp boardGfx() { return m_boardGfx; }

	this( PieceType pieceType, int x, int y, Bmp[] piecesGfx0, Bmp boardGfx0 ) {
		m_type = pieceType;
		xpos = x;
		ypos = y;
		m_piecesGfx = piecesGfx0;
		boardGfx = boardGfx0;
	}

	ALLEGRO_BITMAP* bitmap(PieceType pieceType) {
		return m_piecesGfx[pieceType].bitmap;
	}
	
	/++
	 get drawen to change the board graphics
	+/
	void draw() {
		auto previousBitmap = al_get_target_bitmap;
		al_set_target_bitmap(boardGfx.bitmap);
		if ( type != PieceType.blank )
			al_draw_bitmap( bitmap(PieceType.darkBrick), xpos, ypos, 0 ); // clear the slot
		al_draw_bitmap( bitmap(type), xpos, ypos, 0 ); // place the piece
		al_set_target_bitmap(previousBitmap);
	}
}
