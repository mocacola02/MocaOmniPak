//================================================================================
// MOCASavePoint.
//================================================================================

class MOCASavePoint extends SavePoint;

var() float RegenerateTime;	// Moca: Time it takes for savepoint to reappear. Def: 10.0
var() float BobStrength;	// Moca: Intensity of the bobbing movement. Def: 10.0
var() Sound SaveSFX;		// Moca: Sound to play when savepoint is touched. Def: Sound'MocaSoundPak.hp1_save'


event PostBeginPlay()
{
	Super.PostBeginPlay();
	// Set parent vars to our child ones
	fWaitTime = RegenerateTime;
	fBobAmount = BobStrength;
}

function OnSaveGame()
{
	Super.OnSaveGame();

	// If we have a sound, play it
	if ( SaveSFX != None )
	{
		PlaySound(SaveSFX);
	}

	// Reset wait time
	fWaitTime = RegenerateTime;
}


defaultproperties
{
	SaveSFX=Sound'MocaSoundPak.hp1_save'
	RegenerateTime=10.0
	BobStrength=10.0
}