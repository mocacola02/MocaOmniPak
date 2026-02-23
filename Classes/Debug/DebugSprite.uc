//================================================================================
// DebugSprite. for testing only (THAT'S WHAT DEBUG MEANS DUMMY)
//================================================================================

class DebugSprite extends Sprite;

var float DespawnDelay;	// How long before despawning
var float CurrentTime;	// Current time accrued


event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	CurrentTime += DeltaTime;	// Increment time

	// If we've surpassed the delay, destroy
	if ( CurrentTime >= DespawnDelay )
	{
		Destroy();
	}
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
	DespawnDelay=10.0
}
