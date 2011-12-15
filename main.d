//#Note: not used in program, just a reference
module main;

version=Reference;

/+
pragma( lib, "liballegro5" );
pragma( lib, "libdallegro5" );
+/

//pragma(lib, "allegrobig5");
pragma(lib, "allegro");
pragma(lib, "allegro_acodec");
pragma(lib, "allegro_audio");
pragma(lib, "allegro_color");
pragma(lib, "allegro_dialog");
pragma(lib, "allegro_font");
pragma(lib, "allegro_image");
pragma(lib, "allegro_memfile");
pragma(lib, "allegro_physfs");
pragma(lib, "allegro_primitives");
pragma(lib, "allegro_ttf");
pragma(lib, "libdallegro5");
pragma(lib, "libjeca" );
pragma(lib, "libjext" );

import std.stdio;
import std.string: split;
import std.ascii;
import jeca.all;
import jext.all;
import game;

const NEED_WORK = "1) Shooting weakbricks [#] 2) New controls [## ] 3) Result screen [# ]"
	" 4) Start menu [ ] 5) Save game results [ ] 7) Draw in better order [ ]"
	" 8) clean up code [. ] 9) Draw stuff [ ] 10) Control problem"
	" 11) Ships getting stuck on each other [ ]";

const VERSION = "Thu Dec 15, 2011 - Working on being able to have more than 2 players.";
//const VERSION = "Mon Dec 12, 2011 - Updating Dallegro5";
//const VERSION = "Sat Dec 10, 2011 - Renamed PlayGround to Game";
//const VERSION = "Mon Dec 5, 2011 - fine tuning, a control fix, bit less speed intensive, fix mine damage being same as bolt and increased boost damage, added control problem to my simple road map.";
//const VERSION = "Sat Dec 3, 2011 - added draw stuff";
//const VERSION = "Fri Dec 2, 2011 - fixed a broken depency(sp) and worked the changes in, can now have multipul fonts";
//const VERSION = "Thu Dec 1, 2011 - fixed slice so it did actually work, also got xfbuild";
//const VERSION = "Wed Nov 30, 2011";
//const VERSION = "Tue Nov 29, 2011 - added slice and dollar doesn't work though";
//const VERSION = "Thur Nov 26, 2011 - modified the ship friction";
//const VERSION = "Thur Nov 24, 2011 - Tidying, renamed keyPress to keyTrigger, and grouped statements with commas, added with(symbol)";
//const VERSION = "Tue Nov 22, 2011 - Got slowing down working";
//const VERSION = "Mon Nov 21, 2011 - versions in setup module";
//connst VERSION = "Mon Nov 14, 2011";
//const VERSION = "Fri Nov 11, 2011 - Me not feel so good. Shrunk force popups key code.";
//const VERSION = "Thur Nov 10, 2011 - Fixed ship speed problem!";
//const VERSION = "Tue Nov 8, 2011 - Trouble with ships some times going too fast";
//const VERSION = "Wed Nov 2, 2011 - ship faster";
//const VERSION = "Tue Nov 1, 2011";
//const VERSION = "Mon Oct 31, 2011 - ship bouncing";
//const VERSION = "Sun(early hours and late hours) Oct 30, 2011 - larver bomb";
//const VERSION = "Sat Oct 29, 2011 - new control try - scraps better now";
//const VERSION = "Fri Oct 28, 2011"; // Nice-a-teas, added some sound
//const VERSION = "Thu Oct 27, 2011";
//const VERSION = "Wed Oct 26, 2011";
//const VERSION = "Tue Oct 25, 2011 - mines now";
//const VERSION = "Mon Oct 24, 2011";
//Didn't program on Sunday
//const VERSION = "Sat Oct 22, 2011";
//const VERSION = "Fri Oct 21, 2011 - started";

pragma(msg, NEED_WORK);
pragma(msg, VERSION);

void main(string[] args) {
	writeln(NEED_WORK);
	writeln(VERSION);
	Init( "-m full -wxh 1024 768".split ~ args );
	scope( exit )
		Deinit;

	//#Note: not used in program, just a reference
	version(Reference) {
		//             first   second   third    fourth    fifth
		auto fonts = "ddrolive ddrocr lemgreen epicpinjec jaltext".split;
		int width, height;
		enum first = 0, second = 1, third = 2, fourth = 3, fifth = 4;
		//int fontIndex = first;
		//int fontIndex = second; //*
		//int fontIndex = third;
		int fontIndex = fourth;
		//int fontIndex = fifth;
		auto lettersSource = Bmp.loadBitmap( `fonts\` ~ fonts[ fontIndex ] ~ `.bmp` );
		switch( fontIndex ) {
			default: break;
			case first:
				width = 16;
				height = 16;
			break;
			case second:
				width = 16;
				height = 25;
				al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, width + 1, 0 ) );
			break;
			case third:
				width = 8;
				height = 17;
			break;
			case fourth:
				width = 25;
				height = 25 + 1;
				/+
				g_bmpLetters = getLetters( lettersSource,
					"!$' +,-." ~ digits ~ letters,
					width );
				+/
			break;
			case fifth:
				width = 15;
				height = 17;
			break;
		}
		al_convert_mask_to_alpha( lettersSource, al_get_pixel( lettersSource, 1, 0 ) );
		//if ( fontIndex != fourth )
		//	g_bmpLetters = getLetters( lettersSource, null, g_width + 1);
	} // reference only

	(new Game(args)).run;
}
