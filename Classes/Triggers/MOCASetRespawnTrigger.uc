//================================================================================
// MOCASetRespawnTrigger.
//================================================================================

class MOCASetRespawnTrigger extends Trigger;


var MOCAharry PlayerHarry;
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

	PlayerHarry = MOCAharry(Level.PlayerHarryActor);
}

function Activate ( actor Other, pawn Instigator ) {
    ProcessTrigger();
}

function ProcessTrigger()
{
    Log("Set respawn to " $ respawnLocation);
    PlayerHarry.respawnLoc = respawnLocation;
    PlayerHarry.respawnRot = respawnRotation;
}

defaultproperties {
    bTriggerOnceOnly=True
    useOwnTransform=True
}