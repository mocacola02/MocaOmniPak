//================================================================================
// MOCASetRespawnTrigger.
//================================================================================

class MOCASetRespawnTrigger extends MOCATrigger;

var() bool bUseTriggerTransform;// Moca: If true, use the location and rotation of this trigger instead of RespawnLocation and RespawnRotation. Def: True
var() Vector RespawnLocation;	// Moca: Location to respawn Harry at
var() float RespawnYaw;			// Moca: Rotation to respawn Harry at


event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If use trigger transform, set respawn loc & rot to our own loc & rot
	if ( bUseTriggerTransform )
	{
		RespawnLocation = Location;
		RespawnYaw = Rotation.Yaw;
	}

	if ( !PlayerHarry.IsA('MOCAharry') )
	{
		PlayerHarry.ChessTargetLocation = PlayerHarry.Location;
	}
}

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If Harry is MOCAharry, set respawn pos
	if ( PlayerHarry.IsA('MOCAharry') )
	{
		MOCAharry(PlayerHarry).SetRespawnPosition(RespawnLocation, RespawnYaw);
	}
	// Otherwise, use an unused vector on Harry as our respawn location
	else
	{
		PlayerHarry.ChessTargetLocation = RespawnLocation;
	}
}

defaultproperties
{
	bUseTriggerTransform=True
	bTriggerOnceOnly=True
}