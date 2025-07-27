//================================================================================
// MOCAMenuTrigger.
//================================================================================

class MOCAMenuTrigger extends Trigger;

var harry PlayerHarry;
var() string MenuName;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);
}

function Activate ( actor Other, pawn Instigator ) {
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
