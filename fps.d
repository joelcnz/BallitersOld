module fps;

import std.string;
import jeca.all;
import jext.all;
import base;

class Fps {
private:
	double m_currentFps;
	LetterManager m_jext;
public:
	this(string font) {
		auto lettersSource=Bmp.loadBitmap(font);
		al_convert_mask_to_alpha(lettersSource, Colour.magenta);
		m_jext = new LetterManager(lettersSource,
								   Square( 0, 0, DISPLAY_W, DISPLAY_H - 16 ), 16, 25);
		update();
	}
	
	void update(int fps=0) {
		m_currentFps = fps;
	}
	
	void draw() {
		if (g_toDisplay & Show.fpsBar) {
			al_draw_filled_rectangle(0, DISPLAY_H - 24, m_currentFps, DISPLAY_H, Colour.yellow);
			m_jext.setText(format("%d", cast(int)m_currentFps));
			m_jext.square = Square(cast(int)m_currentFps, DISPLAY_H-24, DISPLAY_W, DISPLAY_H);
			m_jext.draw(g_Draw.text);
		}
	}
}
