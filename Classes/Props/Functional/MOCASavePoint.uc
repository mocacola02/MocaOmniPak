//================================================================================
// MOCASavePoint.
//================================================================================

class MOCASavePoint extends SavePoint;

var() Sound SaveJingle; 		// Moca: What sound to play after saving
var() float JingleVolumeMult; 	// Moca: Volume control for SaveJingle
var() float TimeToRegenerate; 	// Moca: If SaveOnce=False, how long should it take to regen
var() float BobStrength; 		// Moca: How intense should the floating movement be

event PostBeginPlay()
{
    Super.PostBeginPlay();
    fWaitTime = TimeToRegenerate;
    fBobAmount = BobStrength;
}

function OnSaveGame()
{
    Super.OnSaveGame();
    if (SaveJingle != None)
    {
        PlaySound(SaveJingle, SLOT_None, JingleVolumeMult);
    }
    fWaitTime = TimeToRegenerate;
}

defaultproperties
{
     SaveJingle=Sound'MocaSoundPak.Music_Cues.hp1_save'
     JingleVolumeMult=0.8
     TimeToRegenerate=10
     BobStrength=10
}
