class MOCAWeapon extends HWeapon;

var(MOCADebug) bool bDebugLogging;
var harry PlayerHarry;


event PostBeginPlay()
{
	super.PostBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);

	if ( !bDebugLogging && PlayerHarry.IsA('MOCAharry') )
	{
		bDebugLogging = MOCAharry(PlayerHarry).bDebugLogging;
	}
}

function DebugLog(string Msg)
{
	if ( bDebugLogging )
	{
		Log(self $ ": " $ Msg);
	}
}
