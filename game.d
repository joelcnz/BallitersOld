//#mine too, at this timing rate?
/++
Has the main class
+/
module game;

import std.stdio;
import std.string;
import std.conv;
import std.random;
import std.datetime;

import jeca.all;
import jext.all;

import base, unit, ship, unitlist, board, display, fps, setup, popup, gameover, larverbombblow, pointer,
	tkey;

/++
The main class, has the main loop
+/
class Game {
private:
	Bmp m_spriteSet;
	Board m_board;
	UnitList m_unitList;
	Display m_display;
	Fps m_fps;
	SetUp m_setUp;
	PopUp m_popUp;
	GameOver m_gameOver;
	LarverBombBlow m_larverBombBlow;
	Pointer m_pointer;
public:
	@property ref auto spriteSet() { return m_spriteSet; } /// access to all the sprites in one block
	@property ref auto unitList() { return m_unitList; } /// access to the unit list (ships, bullits etc)
	@property ref auto board() { return m_board; } /// access to the board (the bitmap of the board, each cell place)
	@property ref auto popUp() { return m_popUp; } /// handles the popups like weakbricks, boosters, etc.

	/++
	Constructor that uses the SetUp object
	+/
	this(string[] args) {
		args=["-m full -wxh 640 480"]; //1024 768"];
		(new SetUp(args)).setUp(spriteSet, unitList, board, m_fps, m_popUp, m_display, m_gameOver,
								m_larverBombBlow, m_pointer);
	}
	
	/++
	Contains the main loop
	+/
	bool run() {
		//g_startGame[uniform(0, $)].play;
		void holdKey(int hkey) {
			while( key[ hkey ] ) {
				poll_input;
			}
		}
		StopWatch shipsTimer, lazersTimer, secondTimer;
		
		shipsTimer.start;
		lazersTimer.start;
		secondTimer.start;
		int frameCount = 0, currentFPS = 0;
		TKey[6] tKeyPopUps;
		foreach(i, ref tk; tKeyPopUps) {
			tk=new TKey(ALLEGRO_KEY_1+i);
		}
		PieceType[6] pieceTypePopUps;
		with(PieceType)
			 pieceTypePopUps=[weakBrick, shieldBoost, weaponBoostThree, weaponBoostTen, larverBomb, lazerBeam];

		TKey tKeyEnter;
		tKeyEnter = new TKey( ALLEGRO_KEY_ENTER );
		do {
			if ( secondTimer.peek().msecs >= 1_000 / 4 ) {
				currentFPS = frameCount * 4;
				m_fps.update( currentFPS );
				frameCount = 0;
				secondTimer.reset;
			}
			with(m_display)
				draw( DisplayType.board );

			with( g_letterBase )
				setText( format( "FPS: %s", currentFPS ) ),
				addTextln( format( "\nNumber of units: %03s", m_unitList.length ) );

			with(m_display)
				draw( DisplayType.text ),
				draw( DisplayType.units );

			poll_input;

			//process ships and blowups
			if (shipsTimer.peek.hnsecs > (cast(Ship)unitList[0]).timer) {
				foreach(unit; unitList) {
					if (! doesMatch(unit.mainType, [UnitType.lazer, UnitType.mine]))
						unit.process( board, unitList );
				}
				shipsTimer.reset;
			}

			if (lazersTimer.peek.hnsecs > 25_000) {
				foreach(unit; unitList[2..-1]) // -1 - last, -2 would be second to last
					if (doesMatch(unit.mainType, [UnitType.lazer, UnitType.mine])) //#mine too, at this timing rate?
						unit.process( board, unitList );
				lazersTimer.reset;
			}
			
			with(m_display)
				draw( DisplayType.fpsBar );
			m_popUp.updateTimersEtc;
			if (doesMatch(ShipState.destroyed, [(cast(Ship)unitList[0]).state,
											    (cast(Ship)unitList[1]).state]))
				m_display.draw( DisplayType.gameOver );
			
			// And flip it all onto the screen
			with(m_display)
				draw( DisplayType.flip );

			++frameCount;
			
			//Tilde toggles
			if ( key[ ALLEGRO_KEY_TILDE ] )	{
				g_toDisplay ^= Show.fpsBar;
				g_toDisplay ^= Show.debugInfo;
				g_toDisplay ^= Show.players;
				holdKey(ALLEGRO_KEY_TILDE);
			}

			// Set to sudden death (shield set to minimin)
			if (key[ALLEGRO_KEY_LCTRL]) {
				do {
					poll_input();
					if (key[ALLEGRO_KEY_S]) {
						g_gameType = GameType.suddenDeath;
						foreach(i, ship; unitList[0..2])
							(cast(Ship)ship).shield.amount=1;
					}
				} while(key[ALLEGRO_KEY_LCTRL]);
				holdKey(ALLEGRO_KEY_S);
			}

			m_pointer.process;

			foreach(i, tk; tKeyPopUps)
				if (tk.keyTrigger)
					popUp.updateTimersEtc(pieceTypePopUps[i]);

			if ( tKeyEnter.keyTrigger )
				foreach( unit; m_unitList )
					if (doesMatch(unit.mainType, [UnitType.lazer, UnitType.mine]))
						unitList.remove( unit );
			
		} while(! key[ALLEGRO_KEY_ESCAPE] && ! key[ALLEGRO_KEY_ENTER]);
		return key[ALLEGRO_KEY_ENTER] != 0;
	}
}
