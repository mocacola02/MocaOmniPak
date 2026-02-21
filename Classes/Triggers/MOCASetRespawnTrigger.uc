//================================================================================
// MOCASetRespawnTrigger.
//================================================================================

class MOCASetRespawnTrigger extends MOCATrigger;

var() Vector RespawnLocation;
var() Rotator RespawnRotation;
var() bool bUseTriggerTransform; //If true, use the location and rotation of this trigger. Def: True


event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bUseTriggerTransform )
	{
		RespawnLocation = Location;
		RespawnRotation = Rotation;
	}
}

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( PlayerHarry.IsA(MOCAharry) )
	{
		MOCAharry(harry).SetRespawnPosition(RespawnLocation,RespawnRotation);
	}
	else
	{
		MOCAHelpers.PushError("MOCASetRespawnTrigger requires MOCAharry to work! Please replace harry with MOCAharry.");
	}
}

defaultproperties
{
	bUseOwnTransform=True
	bTriggerOnceOnly=True
}