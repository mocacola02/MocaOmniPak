//================================================================================
// MOCAMenuTrigger.
//================================================================================

class MOCAMenuTrigger extends MOCATrigger;

var() string MenuName;

function Activate ( actor Other, pawn Instigator )
{
    ProcessTrigger();
}

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
