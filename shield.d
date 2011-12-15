module shield;

import jeca.all;

class Shield {
private:
	static int m_boxx, m_boxy;
	int m_amount;
	int m_player;
public:
	@property ref auto amount() { return m_amount; }

	this( int player ) {
		m_player = player;
		m_amount = 200;
		m_boxx = 100;
		m_boxy = DISPLAY_H - 18 * 3;
	}

	void draw() {
		al_draw_rectangle( m_boxx - 3, m_boxy - 3, m_boxx + 200 * 3 + 3, m_boxy + 24 * 2 + 3, Colour.white, 3 );
		al_draw_filled_rectangle( m_boxx, m_boxy + m_player * 12,
								 m_boxx + (amount < 200 ? amount : 200) * 3, m_boxy + m_player * 12 + 12,
			m_player == 0 ? Colour.blue : Colour.yellow );
	}
}
