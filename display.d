module display;

import jeca.all;
import jext.all;
import base, board, unitlist, fps, gameover;

class Display {
private:
	Board m_board;
	UnitList m_unitList;
	Fps m_fps;
	GameOver m_gameOver;
	DebugInfo m_debugInfo;
public:
	this( Board board0, UnitList unitList0, Fps fps0, GameOver gameOver0, DebugInfo debugInfo0 ) {
		m_board = board0;
		m_unitList = unitList0;
		m_fps = fps0;
		m_gameOver = gameOver0;
		m_debugInfo = debugInfo0;
	}

	void draw( DisplayType displayType ) {
		switch( displayType ) {
			default:
			break;
			case DisplayType.board:
				m_board.draw;
			break;
			case DisplayType.units:
				m_unitList.draw;
			break;
			case DisplayType.text:
				m_debugInfo.draw;
			break;
			case DisplayType.fpsBar:
				m_fps.draw;
			break;
			case DisplayType.gameOver:
				m_gameOver.draw;
			break;
			case DisplayType.flip:
				al_flip_display;
			break;
		}
	}
}
