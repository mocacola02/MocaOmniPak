//================================================================================
// MOCAMenuTrigger.
//================================================================================

class MOCAMenuTrigger extends MOCATrigger;

var() string MenuName;	// MAIN, INPUT, SOUNDVIDEO, LANG, LANGUAGE, INGAME, FOLIO, MAP, QUID, QUIDDITCH, DUEL, HPOINTS, CHALLENGES, CREDITSPAGE


function ProcessTrigger()
{
	HPConsole(PlayerHarry.Player.Console).menuBook.bGamePlaying = False;
	HPConsole(PlayerHarry.Player.Console).menuBook.OpenBook(MenuName);
	HPConsole(PlayerHarry.Player.Console).LaunchUWindow();
}

defaultproperties
{
	MenuName="INGAME"
}