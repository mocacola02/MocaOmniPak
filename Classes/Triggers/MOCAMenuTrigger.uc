//================================================================================
// MOCAMenuTrigger.
//================================================================================

class MOCAMenuTrigger extends MOCATrigger;

var() string MenuName;	// MAIN, INPUT, SOUNDVIDEO, LANG, LANGUAGE, INGAME, FOLIO, MAP, QUID, QUIDDITCH, DUEL, HPOINTS, CHALLENGES, CREDITSPAGE


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// Pause game
	HPConsole(PlayerHarry.Player.Console).menuBook.bGamePlaying = False;
	// Open menu
	HPConsole(PlayerHarry.Player.Console).menuBook.OpenBook(MenuName);
	// Launch window
	HPConsole(PlayerHarry.Player.Console).LaunchUWindow();
}

defaultproperties
{
	MenuName="INGAME"
}