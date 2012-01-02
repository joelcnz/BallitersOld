//#set number of players
//#morris
module setup;

version=Player2LaptopKeys;
//version=Player2KeyPadKeys;

import std.stdio;
import std.string: split;
import std.random;
import jeca.all;
import jext.all;
import base, ship, fps, display, unitlist, board, popup, gameover, larverbombblow, pointer;

class SetUp {
	this( string[] args ) {}
	
	void setUp( ref Bmp spriteSet, ref UnitList unitList, ref Board board, ref Fps fps, ref PopUp popUp, ref Display display,
		        ref GameOver gameOver, ref LarverBombBlow laverBombBlow, ref Pointer pointer) {
		
		g_letterBase = new LetterManager(Bmp.loadBitmap( `fonts\`~"lemgreen.bmp"),
										 Square( 0, 0, DISPLAY_W, DISPLAY_H ), 8, 17 );
		
		spriteSet = new Bmp( `gfx\B2sprites.bmp` );
		
		al_convert_mask_to_alpha( spriteSet.bitmap, Colour.magenta ); // mono transparincy(sp)
		
		auto blankGfx = new Bmp( 8, 8 );

		Bmp getSlice( int x, int y ) {
			return Bmp.getBmpSlice( spriteSet.bitmap, x, y, 8, 8, 0, 0, 0 );
		}

		auto shipGfx1 =            getSlice(0,         144);
		auto shipGfx2 =            getSlice(0,         144 + 8);
		auto shipGfx3 =            getSlice(0,         144 + 8 + 8);

		auto brickGfx =            getSlice(0,         136);
		auto darkBrickGfx =        getSlice(8,         136);

		auto weakBrickGfx =        getSlice(100,       90);
		auto shieldBoostGfx =      getSlice(0,         176);
		auto weaponBoostThreeGfx = getSlice(8,         176);
		auto weaponBoostTenGfx =   getSlice(8 + 8,     176);
		auto larverBombGfx =       getSlice(8 + 8 + 8, 176);
		auto lazerBeamGfx =        getSlice(8 + 8 +16, 176);
		g_flashGfx =               getSlice(0,         168);

		g_larverBlowFramesGfx.length = 0;
		foreach(x; 0 .. 5) {
			g_larverBlowFramesGfx~=getSlice(x*8, 184);
			g_larverBlowFramesGfx[$-1].resize(24, 24);
		}

		// resize to bigger
		foreach( graphic; [blankGfx, shipGfx1, shipGfx2, shipGfx3, brickGfx, darkBrickGfx,
			weakBrickGfx, shieldBoostGfx, weaponBoostThreeGfx, weaponBoostTenGfx, larverBombGfx,
			lazerBeamGfx, g_flashGfx] ) {
			with( graphic )
				resize( width * 3, height * 3 );
		}

		//#I think need to change to 2D array
		Bmp[] shipBlowGfx1;
		foreach( x; 0 .. 7 ) {
			shipBlowGfx1 ~= getSlice( 8 + x * 8, 144 );
			with( shipBlowGfx1[x] )
				shipBlowGfx1[x].resize( width * 3, height * 3 );
		}
		Bmp[] shipBlowGfx2;
		foreach( x; 0 .. 7 ) {
			shipBlowGfx2 ~= getSlice( 8 + x * 8, 144 + 8 );
			with( shipBlowGfx2[x] )
				shipBlowGfx2[x].resize( width * 3, height * 3 );
		}
		Bmp[] shipBlowGfx3;
		foreach( x; 0 .. 7 ) {
			shipBlowGfx3 ~= getSlice( 8 + x * 8, 144 + 8 + 8);
			with( shipBlowGfx3[x] )
				shipBlowGfx3[x].resize( width * 3, height * 3 );
		}

		board = new Board([blankGfx, weakBrickGfx, brickGfx, darkBrickGfx, shieldBoostGfx, weaponBoostThreeGfx,
			weaponBoostTenGfx, larverBombGfx, lazerBeamGfx], `levels\area01.txt`);
		
		unitList = new UnitList; // a must!

		(new Ship()).idCurrent = 0;
		void player1() {
			unitList.append( new Ship( shipGfx1, shipBlowGfx1, -1, -1,
									  [ALLEGRO_KEY_E, ALLEGRO_KEY_F, ALLEGRO_KEY_D, ALLEGRO_KEY_S, ALLEGRO_KEY_Z, ALLEGRO_KEY_X,
									  ALLEGRO_KEY_A ] ) );
			/+
			// Sean's keys
			unitList.append( new Ship( shipGfx1, shipBlowGfx1, -1, -1,
									  [ALLEGRO_KEY_W, ALLEGRO_KEY_D, ALLEGRO_KEY_S, ALLEGRO_KEY_A,
									   ALLEGRO_KEY_LSHIFT, ALLEGRO_KEY_ALT, ALLEGRO_KEY_SPACE ] ) );
			+/
		}

		void player2() {
			/+
			unitList.append( new Ship( shipGfx2, shipBlowGfx2, -1, -1,
									       [ALLEGRO_KEY_UP, ALLEGRO_KEY_RIGHT, ALLEGRO_KEY_DOWN, ALLEGRO_KEY_LEFT,
									  ALLEGRO_KEY_SLASH, ALLEGRO_KEY_FULLSTOP, ALLEGRO_KEY_COMMA ] ) );
			+/
			unitList.append( new Ship( shipGfx2, shipBlowGfx2, -1, -1,
				[ALLEGRO_KEY_UP, ALLEGRO_KEY_RIGHT, ALLEGRO_KEY_DOWN, ALLEGRO_KEY_LEFT,
				ALLEGRO_KEY_RCTRL, ALLEGRO_KEY_RSHIFT, ALLEGRO_KEY_SLASH ] ) );
		}

		// incomplete from now on
		void player3() {
			unitList.append( new Ship( shipGfx3, shipBlowGfx3, -1, -1,
									  [ALLEGRO_KEY_PAD_8, ALLEGRO_KEY_PAD_6, ALLEGRO_KEY_PAD_5, ALLEGRO_KEY_PAD_4,
									  ALLEGRO_KEY_PAD_1, ALLEGRO_KEY_PAD_2,
									  ALLEGRO_KEY_PAD_3 ] ) );
		}

		void player4() {
			unitList.append( new Ship( shipGfx3, shipBlowGfx3, -1, -1,
									  [ALLEGRO_KEY_I, ALLEGRO_KEY_L, ALLEGRO_KEY_K, ALLEGRO_KEY_J,
									  ALLEGRO_KEY_B, ALLEGRO_KEY_N,
									  ALLEGRO_KEY_M ] ) );
		}

		//#set number of players
		const numPlayers = 2; // 4 max
		foreach(addPlayer; [&player1, &player2, &player3, &player4][0..numPlayers])
			addPlayer();

		void playerFacing1() {
			//(cast(Ship)unitList[0]).faceAngle = getAngle( unitList[0].xpos, unitList[0].ypos, unitList[1].xpos, unitList[1].ypos );
			(cast(Ship)unitList[0]).faceAngle = getAngle(0,0, 5,0);
		}
		void playerFacing2() {
			(cast(Ship)unitList[1]).faceAngle = getAngle(0,0, -5,0); //getAngle( unitList[1].xpos, unitList[1].ypos, unitList[0].xpos, unitList[0].ypos );
		}
		void playerFacing3() {
			(cast(Ship)unitList[2]).faceAngle = getAngle(0,0, 5,5);
		}
		void playerFacing4() {
			(cast(Ship)unitList[3]).faceAngle = getAngle(0,0, 5,5);
		}
		foreach(facePlayer; [&playerFacing2, &playerFacing2, &playerFacing3, &playerFacing4][0..numPlayers])
			facePlayer();
		fps = new Fps(`fonts\ddrocr.bmp`);
		
		popUp = new PopUp( board, unitList );
		g_frameGfx = new Bmp[][](13, 6);
		foreach( y; 0 .. 13)
			foreach( x; 0 .. 6)
				g_frameGfx[y][x] = getSlice( 108 + x * 8, 90 + y * 8 ),
				g_frameGfx[y][x].resize( 8 * 3, 8 * 3 );    

		Ship[] ships;
		foreach(ship; unitList[0..2]) //3])
			ships ~= cast(Ship)ship;
		gameOver = new GameOver(ships);

		display = new Display( board, unitList, fps, gameOver, g_debugInfo );

		g_snds.length = 0;
		foreach( snd; "shoot.wav blowup.wav".split )
			g_snds ~= new Snd( `sfx\` ~ snd );

		g_smallBlows.length = 0;
		foreach( snd; "dumb.ogg dumb2.ogg dumb3.ogg".split )
			g_smallBlows ~= new Snd( `sfx\smallExplosions\` ~ snd );

		g_win.length = 0;
		foreach( snd; "SeanWinHaha.wav SeanWinHaha2.wav".split )
			g_win ~= new Snd( `sfx\` ~ snd );

//		foreach( snd; "Start.wav Start2.wav".split )
//			g_start ~= new Snd( `sfx\` ~ snd );

		g_lazerShots.length = 0;
		foreach( snd; "shoot.wav".split )
//		foreach( snd; "lazerfire.wav".split )
			g_lazerShots ~= new Snd( `sfx\` ~ snd );

		g_startGame.length = 0;
		foreach( snd; "startGame.wav".split )
			g_startGame ~= new Snd( `sfx\` ~ snd );

		pointer = new Pointer(board);

		//#morriss
		g_morris = new Snd(`sfx\smallExplosions\0.wav`);
	}

}
