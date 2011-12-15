module gameover;

import std.conv;
import jeca.all;
import jext.all;
import base, ship;

class GameOver {
private:
	LetterManager m_text;
	Ship[] m_ships;
public:
	this(Ship[] ships0) {
		m_text = new LetterManager(Bmp.loadBitmap( `fonts\`~"lemgreen.bmp"),
								   Square(0,0, 0,0), 8, 17 );
		m_ships=ships0;
	}

	void draw() {
		with(m_text) {
			string winner;
			//if (m_ships[0].shield.amount > m_ships[1].shield.amount)
			Ship winnerShip = m_ships[0];
			//#or sort
			// sort!"a > b"(m_ships);
			// winnerShip = winnerShip[0];
			foreach(ship; m_ships)
				if (ship > winnerShip)
					winnerShip = ship;
			winner = text("Player ", winnerShip.shipId+1, " Wins");
			//else if (m_ships[0].shield.amount < m_ships[1].shield.amount)
			/+
			else if (m_ships[0] < m_ships[1])
				winner="Player 2 Wins";
			else // a draw
			+/
			//if (m_ships[0].shield.amount == m_ships[1].shield.amount)
			//if (m_ships[0]() == m_ships[1]())
			if (m_ships[0] == m_ships[1])
				winner="Game is Tied! "; // can't have a tie with more than two players
			square = Square(100,200, DISPLAY_W, 32);
			setText( winner );
			draw(g_Draw.text);
			/+
			square = Square(0,550, DISPLAY_W, 32);
			setText( "Lower" );
			draw(g_Draw.text);
			+/
		}
	}
}