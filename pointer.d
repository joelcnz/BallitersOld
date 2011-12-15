module pointer;

import jeca.all;
import base, board;

class Pointer {
private:
	Board m_board;
public:
	@property ref auto board() { return m_board; }

	this(Board board0) {
		board = board0;
	}

	void process() {
		int wx, wy;
		al_get_window_position(DISPLAY, &wx, &wy);
		int x, y;
		al_get_mouse_cursor_position(&x, &y);
		x -= wx;
		y -= wy;
		void setPiece(PieceType pieceType) {
			board.piece(x, y).type = pieceType;
			board.piece(x, y).draw;
		}
		poll_input;
		if (key[ALLEGRO_KEY_F1])
			setPiece(PieceType.weakBrick);
		if (key[ALLEGRO_KEY_F2])
			setPiece(PieceType.shieldBoost);
		if (key[ALLEGRO_KEY_F3])
			setPiece(PieceType.weaponBoostThree);
		if (key[ALLEGRO_KEY_F4])
			setPiece(PieceType.weaponBoostTen);
		if (key[ALLEGRO_KEY_F5])
			setPiece(PieceType.larverBomb);
		if (key[ALLEGRO_KEY_F6])
			setPiece(PieceType.brick);
		if (key[ALLEGRO_KEY_F7])
			setPiece(PieceType.darkBrick);
	}
}
