//#What's this?
//#maybe have stp 1.0 being one pixel
module base;

import std.math;
import std.random;
import jeca.all;
import jext.all;

alias double dub;

enum UnitType { ship, lazer, mine };
enum PieceType { blank, weakBrick, brick, darkBrick, shieldBoost, weaponBoostThree, weaponBoostTen,
	             larverBomb };
enum DisplayType { board, units, text, fpsBar, gameOver, flip };
enum Show: int { fpsBar = 1, debugInfo = 2, players = 4 };
enum ShipState {good, blowingUp, destroyed};

enum GameType {normal, suddenDeath};
GameType g_gameType;

int g_toDisplay;
int g_shipTimer = 40_000;

LetterManager g_letterBase;

class DebugInfo {
	void draw() {
		if ( g_toDisplay & Show.debugInfo )
			g_letterBase.draw( g_Draw.text );
	}
}
DebugInfo g_debugInfo;

static this() {
	g_debugInfo = new DebugInfo;
	g_gameType = GameType.normal;
	g_ballStartPostions = [180, 400,  720, 100, 400, 200];
}

dub[] g_ballStartPostions;
Bmp[][] g_frameGfx; //#What's this?
Bmp[] g_larverBlowFramesGfx;
Bmp g_flashGfx;

enum Sound {shoot, blowUp};
Snd[] g_snds;

Snd g_morris;

Snd[] g_smallBlows;
Snd[] g_medBlows;
Snd[] g_largeBlows;

//smallBlows[uniform(0,$)].play;

void bumpLimit(ref int number, int step, int limit ) {
	number+=step;
	if (step < 0 && number < limit || step > 0 && number > step)
		number=limit;
}

/// From pixel position to cell position
uint pos(dub num) {
	return cast(uint)(num / 24);
}

bool doesMatch(T1,T2)(T1 value, T2[] possibles) {
	foreach(p; possibles)
		if (value == p)
			return true;
	return false;
}

dub getAngle( dub x,dub y, dub tx, dub ty )
{
	return correct( atan2( ty - y, tx - x ) );
}

dub correct( dub angle ) {
  static dub a=PI * 2;
  while(angle > a) angle -= a;
  while(angle < 0) angle += a;

  return angle;
}

//#maybe have stp 1.0 being one pixel ( 'dx=stp*#*cos(ang);' )
void xyaim( ref dub dx, ref dub dy, dub stp, dub ang )
{
  dx = stp * cos( ang );
  dy = stp * sin( ang );
}
