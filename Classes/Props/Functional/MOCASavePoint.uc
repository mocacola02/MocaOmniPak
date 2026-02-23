//================================================================================
// MOCASavePoint.
//================================================================================

class MOCASavePoint extends SavePoint;

var() float RegenerateTime;
var() float BobStrength;
var() Sound SaveSFX;


event PostBeginPlay()
{
	Super.PostBeginPlay();
	fWaitTime = RegenerateTime;
	fBobAmount = BobStrength;
}

function OnSaveGame()
{
	Super.OnSaveGame();

	if ( SaveSFX != None )
	{
		PlaySound(SaveSFX);
	}

	fWaitTime = RegenerateTime;
}


defaultproperties
{
	SaveSFX=Sound'MocaSoundPak.hp1_save'
	RegenerateTime=10.0
	BobStrength=10.0
}