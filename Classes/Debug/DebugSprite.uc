//================================================================================
// DebugSprite. for testing only
//================================================================================

class DebugSprite extends Sprite;

var float DespawnDelay;
var float CurrentTime;

// Function to start the despawn countdown when the actor is spawned
event PostBeginPlay()
{
    Super.PostBeginPlay();
    CurrentTime = 0.0;
}

// Function called every frame
event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    
    CurrentTime += DeltaTime;
    if (CurrentTime >= DespawnDelay)
    {
        DespawnSprite();
    }
}

// Function to despawn the actor
function DespawnSprite()
{
    Destroy();
}

defaultproperties
{
    CollisionHeight=0
    CollisionRadius=0
    CollisionWidth=0
    bBlockActors=false
    bBlockPlayers=false
    bCollideActors=false
    bCollideWorld=false
    DespawnDelay=10.0 // Default despawn delay of 3 seconds
}
