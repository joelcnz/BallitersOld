//#resume this pop up
//#was 90
module popup;

import std.stdio;
import std.random;
import std.datetime;
import jeca.all;
import base, board, piece, unitlist;

class PopUp {
private:
	enum TimeOut { // in seconds
		weakBrick        = 60,
		shieldBoost      = 80,
		weaponBoostThree = 22,
		weaponBoostTen   = 62,
		larverBomb       = 30 }; //#was 90
	int m_weakBrickTimer,
		m_shieldBoostTimer,
		m_weaponBoostThreeTimer,
		m_weaponBoostTenTimer,
		m_larverBombTimer;
	StopWatch m_second;
	Board m_board;
	UnitList m_unitList;
public:
	this( Board board, UnitList unitList0 ) {
		m_board = board;
		m_unitList = unitList0;
		m_second.start;
	}

	void updateTimersEtc(PieceType forcePopUpId = PieceType.blank ) {
		if ( m_second.peek().seconds == 1 || forcePopUpId != PieceType.blank ) {
			void checkedCount( ref int timer ) {
				if (forcePopUpId == PieceType.blank)
					++timer;
			}

			checkedCount( m_weakBrickTimer );
			if ( m_weakBrickTimer == TimeOut.weakBrick || forcePopUpId == PieceType.weakBrick ) {
				m_weakBrickTimer = 0;
				place( PieceType.weakBrick );
			}

			checkedCount( m_shieldBoostTimer );
			if ( m_shieldBoostTimer == TimeOut.shieldBoost || forcePopUpId == PieceType.shieldBoost ) {
				m_shieldBoostTimer = 0;
				place( PieceType.shieldBoost );
			}

			checkedCount( m_weaponBoostThreeTimer );
			if ( m_weaponBoostThreeTimer == TimeOut.weaponBoostThree || forcePopUpId == PieceType.weaponBoostThree ) {
				m_weaponBoostThreeTimer = 0;
				place( PieceType.weaponBoostThree );
			}

			checkedCount( m_weaponBoostTenTimer );
			if ( m_weaponBoostTenTimer == TimeOut.weaponBoostTen || forcePopUpId == PieceType.weaponBoostTen ) {
				m_weaponBoostTenTimer = 0;
				place( PieceType.weaponBoostTen );
			}

			checkedCount( m_larverBombTimer ); //#resume this pop up
			if ( m_larverBombTimer == TimeOut.larverBomb || forcePopUpId == PieceType.larverBomb ) {
				m_larverBombTimer = 0;
				place( PieceType.larverBomb );
			}

			if ( forcePopUpId == PieceType.blank )
				m_second.reset;
		}
	}

	void place( PieceType pieceType ) { // not called all the time
		double fx, fy;
		int x, y;
		bool shipNear() {
			foreach( shipId; 0 .. 2 ) {
				if ( pieceType == PieceType.weakBrick
					&& distance( fx * 24 + 24 + 3, fy * 24 + 24 + 3, m_unitList[shipId].xpos + 12, m_unitList[shipId].ypos + 12 ) < 200 )
					return true;
				if ( distance( fx * 24 + 12, fy * 24 + 12, m_unitList[shipId].xpos + 12, m_unitList[shipId].ypos + 12 ) < 200 )
					return true;
			}
			return false;
		}
		int counter = 0;
		do {
			if ( pieceType == PieceType.weakBrick ) {
				fx = uniform( 1, 40 - 3 );
				fy = uniform( 1, 25 - 3 );
			} else {
				fx = uniform( 0, 40 );
				fy = uniform( 0, 25 );
			}
			x = cast(int)fx;
			y = cast(int)fy;
			++counter;
		} while( m_board.map[y][x].type != PieceType.darkBrick || shipNear && counter < 1_000 );

		if ( counter < 1_000 ) {
			if ( pieceType == PieceType.weakBrick )
				foreach( gy; y .. y + 3 )
					foreach( gx; x .. x + 3 ) {
						auto map = m_board.map[gy][gx];
						if ( map.type == PieceType.darkBrick )
							map.type = pieceType,
							map.draw;
					}
			else {
				auto map = m_board.map[y][x];
				map.type = pieceType;
				map.draw;
			}
		} else // counter b < 1_000
			writeln( "Pop up placing timed out..." );
	}
}
