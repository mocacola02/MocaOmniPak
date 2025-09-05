//================================================================================
// MOCASetRespawnTrigger.
//================================================================================

class MOCASetRespawnTrigger extends MOCATrigger;

var() Vector respawnLocation;
var() Rotator respawnRotation;
var() bool useOwnTransform; //If true, use the location and rotation of this trigger. Def: True

event PreBeginPlay()
{
	Super.PreBeginPlay();

    if (useOwnTransform)
    {
        respawnLocation = Location;
        respawnRotation = Rotation;
    }

    if (!PlayerHarry.IsA('MOCAharry'))
    {
        Log("RESPAWN TRIGGERS REQUIRE MOCAHARRY!!!!!!!");
        Destroy();
    }
}

function Activate ( actor Other, pawn Instigator )
{
    ProcessTrigger();
}

function ProcessTrigger()
{
    Log("Set respawn to " $ respawnLocation);
    MOCAharry(PlayerHarry).respawnLoc = respawnLocation;
    MOCAharry(PlayerHarry).respawnRot = respawnRotation;
}

defaultproperties {
    bTriggerOnceOnly=True
    useOwnTransform=True
}