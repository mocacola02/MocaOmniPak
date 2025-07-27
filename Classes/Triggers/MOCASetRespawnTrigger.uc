//================================================================================
// MOCASetRespawnTrigger.
//================================================================================

class MOCASetRespawnTrigger extends Trigger;


var MOCAharry PlayerHarry;
var() Vector respawnLocation;
var() Rotator respawnRotation;

event PreBeginPlay()
{
	Super.PreBeginPlay();
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
}