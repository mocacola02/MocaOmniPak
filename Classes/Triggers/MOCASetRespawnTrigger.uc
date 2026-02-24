//================================================================================
// MOCASetRespawnTrigger.
//================================================================================

class MOCASetRespawnTrigger extends MOCATrigger;

var() bool bUseTriggerTransform;// Moca: If true, use the location and rotation of this trigger instead of RespawnLocation and RespawnRotation. Def: True
var() Vector RespawnLocation;	// Moca: Location to respawn Harry at
var() Rotator RespawnRotation;	// Moca: Rotation to respawn Harry at


event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If use trigger transform, set respawn loc & rot to our own loc & rot
	if ( bUseTriggerTransform )
	{
		RespawnLocation = Location;
		RespawnRotation = Rotation;
	}
}

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If Harry is MOCAharry, set respawn pos
	if ( PlayerHarry.IsA('MOCAharry') )
	{
		MOCAharry(PlayerHarry).SetRespawnPosition(RespawnLocation,RespawnRotation);
	}
	// Otherwise, push error
	else
	{
		PushError("MOCASetRespawnTrigger requires MOCAharry to work! Please replace harry with MOCAharry.");
	}
}

defaultproperties
{
	bUseTriggerTransform=True
	bTriggerOnceOnly=True
}