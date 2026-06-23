//================================================================================
// DebugSprite. for testing only (THAT'S WHAT DEBUG MEANS DUMMY)
//================================================================================
class DebugSprite extends Sprite;

function Setup(float DespawnDelay)
{
	LifeSpan = DespawnDelay;
}


defaultproperties
{
	CollisionHeight=0
	CollisionRadius=0
	CollisionWidth=0
	bBlockActors=False
	bBlockPlayers=False
	bCollideActors=False
	bCollideWorld=False
	
	LifeSpan=0.0
}
