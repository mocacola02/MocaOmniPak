//================================================================================
// MOCASpawner.
//================================================================================
class MOCASpawner extends MOCAPawn;

struct SpawnedProperty
{
	var() string PropertyName;	// Moca: Name of property to edit on spawn.
	var() string PropertyValue;	// Moca: Value to assign to that property. Must be compatible type (ex: you can't assign a text string to a integer property).
};

struct SpawnSetting
{
	var() class<Actor> ActorToSpawn;		// Moca: Class of actor to spawn
	var() class<ParticleFX> SpawnParticles;	// Moca: Particle class to use when spawning
	var() Sound SpawnSound;					// Moca: Sound to play when spawning

	var() byte SpawnChance;					// Moca: Chance of spawning versus other spawn options. Higher = more likely.
	var float FinalWeight;					// Final calculated weight

	var() float SpawnDelay;					// Moca: How long of a delay to have after spawning.
	var() float SpawnVelocityMult;			// Moca: Intensity of velocity on spawned actor.

	var() Vector SpawnOffset;				// Moca: Location offset to spawn location.
	var() Rotator SpawnRotation;			// Moca: Rotation to use on spawned actor.

	var() array<SpawnedProperty> SpawnProperties;	// Moca: List of properties to set on spawned actor.
};

var() array<SpawnSetting> ListOfSpawns;	// Moca: List of actors that can be spawned.

var() bool bRandomSpawnOrder;		// Moca: Should spawn order be random? If false, spawns in the order of ListOfSpawns. Def: True
var() bool bRandomSpawnDirection;	// Moca: Spawn actors in random directions? Def: False
var() bool bVaryVelocity;			// Moca: Automatically vary velocity so actors don't fly into the same positions? Def: True
var() bool bSpawnerFacesHarry;		// Moca: Should the spawner face Harry so actors spawn in his direction? Def: False

var() Range SpawnCount;				// Moca: Min/Max range for how many actors can be spawned in one life. Def: Min 3 Max 6
var() int MaxLives;					// Moca: Maximum number of lives (aka how many times spawner can be triggered). Def: 3
var() float VaryVelocityIntensity;	// Moca: How intense should the variability of bVaryVelocity be? Def: 1.5

var() Vector GlobalSpawnOffset;		// Moca: Offset to apply to all spawns, combines with spawn-specific offsets. Def: (0,0,0)
var() Rotator GlobalSpawnRotation;	// Moca: Rotation to apply to all spawns, combines with spawn-specific rotations. Def: (0,0,0)


var int CurrentSpawnCount;	// Current spawn count
var int CurrentSpawnIdx;	// Current spawn index
var int TotalWeight;		// Total of all spawn weights
var int FinalMaxSpawnCount;	// Calculated max spawn count
var int ListLength;			// Length of spawn list


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If spawn list is empty
	if ( ListOfSpawns.Length <= 0 )
	{
		// Log error and destroy self
		Log("Error! "$string(Self)$" does not have anything in its spawn list! Destroying!");
		Destroy();
	}

	// Determine spawn weights
	SetSpawnWeights();
	// Store spawn list length
	ListLength = ListOfSpawns.Length;
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	// If idle, go to spawn
	if ( IsInState('stateIdle') )
	{
		GotoState('stateSpawn');
	}
}


////////////////////
// Main Functions
////////////////////

function SpawnItem()
{
	local ParticleFX SpawnedParticle;
	local Actor SpawnedActor;
	local float RandVelocityMult;
	local Vector SpawnLocation;
	local Vector SpawnDirection;
	local Rotator SpawnRotation;

	// If random spawn order, get a random spawn index
	if ( bRandomSpawnOrder )
	{
		CurrentSpawnIdx = GetWeightedRandomIndex();
	}

	// Get spawn location from spawner location + the global spawn offset + spawn-specific offset
	SpawnLocation = Location + GlobalSpawnOffset + ListOfSpawns[CurrentSpawnIdx].SpawnOffset;

	// If use random spawn direction
	if ( bRandomSpawnDirection )
	{
		// Get a random direction
		SpawnDirection = GetRandomDirection();
		// Get rotation from our direction
		SpawnRotation = Rotator(SpawnDirection);
	}
	// Otherwise
	else
	{
		// Get spawn rotation from spawner rotation + global spawn rotation + spawn-specific rotation
		SpawnRotation = Rotation + GlobalSpawnRotation + ListOfSpawns[CurrentSpawnIdx].SpawnRotation;
		// Get direction from rotation
		SpawnDirection = Vector(SpawnRotation);
	}

	// Spawn particles at spawn location
	SpawnedParticle = Spawn(GetSpawnParticles(),,,SpawnLocation);
	// Play spawn sound
	SpawnedParticle.PlaySound(GetSpawnSound());
	// Spawn actor with proper location & rotation
	SpawnedActor = Spawn(ListOfSpawns[CurrentSpawnIdx].ActorToSpawn,,,SpawnLocation,SpawnRotation);

	// If we are varying our velocity
	if ( bVaryVelocity )
	{
		// Get a random velocity mult between 0.5 and Vary intensity
		RandVelocityMult = RandRange(0.5,VaryVelocityIntensity);
	}
	// Otherwise, set multiplier to 1.0
	else
	{
		RandVelocityMult = 1.0;
	}

	// Set actor velocity to our Spawn direction * velocity multiplier * spawn-specific velocity
	SpawnedActor.Velocity = SpawnDirection * RandVelocityMult * ListOfSpawns[CurrentSpawnIdx].SpawnVelocityMult;

	// If we have spawn properties, set them
	if ( ListOfSpawns[CurrentSpawnIdx].SpawnProperties.Length > 0 )
	{
		SetSpawnProperties(SpawnedActor);
	}

	// Increment spawn count
	CurrentSpawnCount++;
}

function ProcessSpell()
{
	// If hit by spell and not spawning, start spawning
	if ( !IsInState('stateSpawn') )
	{
		GotoState('stateSpawn');
	}
}


/////////////////////
// Helper Functions
/////////////////////

function SetSpawnProperties(Actor SpawnedActor)
{
	local int i;
	local string PropName;
	local string PropVal;

	// For each spawn property in the current property list
	for ( i = 0; i < ListOfSpawns[CurrentSpawnIdx].SpawnProperties.Length; i++ )
	{
		// Get property name and value
		PropName = ListOfSpawns[CurrentSpawnIdx].SpawnProperties[i].PropertyName;
		PropVal = ListOfSpawns[CurrentSpawnIdx].SpawnProperties[i].PropertyValue;

		// If valid property name, set the property with PropValue
		if ( PropName != "" )
		{
			SpawnedActor.SetPropertyText(PropName,PropVal);
		}
	}
}

function SetSpawnWeights()
{
	local int i;

	// For each item in the spawn list
	for ( i = 0; i < ListLength; i++ )
	{
		// Increase total weight by current item's spawn chance
		TotalWeight += int(ListOfSpawns[i].SpawnChance);
	}

	// Determine final weight for each item
	for ( i = 0; i < ListLength; i++ )
	{
		ListOfSpawns[i].FinalWeight = ListOfSpawns[i].SpawnChance / TotalWeight;
	}
}

function bool ShouldDie()
{
	// Return true if out of lives
	return MaxLives <= 0;
}

function int GetMaxSpawnCount()
{
	local float FloatCount;
	local int RandCount;
	// Get random number between our min and max spawn count
	FloatCount = RandRange(SpawnCount.Min,SpawnCount.Max);
	// Round our result into an integer
	RandCount = Round(FloatCount);
	// Make sure its a valid integer for this operation
	RandCount = Clamp(RandCount,1,MAXINT);
	// Return final int
	return RandCount;
}

function int GetWeightedRandomIndex()
{
	local int i;
	local float IndexRoll;
	
	// Roll a random number between 0.0 and 1.0 multiplied by total weight
	IndexRoll = FRand() * TotalWeight;

	// For each item in the spawn list
	for ( i = 0; i < ListLength; i++ )
	{
		// If its final weight is 0.0 or less, ignore this item
		if ( ListOfSpawns[i].FinalWeight <= 0.0 )
		{
			continue;
		}

		// Subtract our weight from index roll
		IndexRoll -= ListOfSpawns[i].FinalWeight;
		// If index roll is now 0.0 or less, return this item
		if ( IndexRoll <= 0.0 )
		{
			return i;
		}
	}

	// As a fallback, return 0
	return 0;
}

function float GetSpawnDelay()
{
	// Return current item's spawn delay
	return ListOfSpawns[CurrentSpawnIdx].SpawnDelay;
}

function Vector GetRandomDirection()
{
	local float Theta;
	local float Radius;
	local float Z;
	local Vector Direction;

	// Calculate theta with randomness
	Theta = FRand() * (2 * Pi);
	// Calculate Z with randomness
	Z = (FRand() * 2) - 1.0;
	// Calculate direction radius
	Radius = Sqrt(1.0 - Z * Z);
	// Calculate final direction
	Direction.X = Radius * Cos(Theta);
	Direction.Y = Radius * Sin(Theta);
	Direction.Z = Z;
	// Return random direction
	return Direction;
}

function Sound GetSpawnSound()
{
	// Return current item's spawn sound
	return ListOfSpawns[CurrentSpawnIdx].SpawnSound;
}

function class<ParticleFX> GetSpawnParticles()
{
	// Return current item's spawn particles
	return ListOfSpawns[CurrentSpawnIdx].SpawnParticles;
}


///////////
// States
///////////

auto state stateIdle
{
}

state stateSpawn
{
	event BeginState()
	{
		// Make us uncastable during spawn
		eVulnerableToSpell = SPELL_None;
		// Decrease lives
		MaxLives--;

		// If we should face harry, face turn to him
		if ( bSpawnerFacesHarry )
		{
			EnableTurnTo(PlayerHarry);
		}
	}

	event EndState()
	{
		// If we should die, then destroy self
		if ( ShouldDie() )
		{
			Destroy();
		}

		// Reset spell vulnerability
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
		// Reset spawn count
		CurrentSpawnCount = 0;
		// Disable turn to harry
		DisableTurnTo();
	}

	begin:
		// Get number of actors to spawn
		FinalMaxSpawnCount = GetMaxSpawnCount();
		// Spawn actor
		SpawnItem();
		// Wait for spawn delay
		Sleep(GetSpawnDelay());
		// If we've exceeded max spawn count, go to idle
		if ( CurrentSpawnCount >= FinalMaxSpawnCount )
		{
			GotoState('stateIdle');
		}
		// Otherwise, loop
		Goto('begin');
}

defaultproperties
{
	ListOfSpawns(0)=(ActorToSpawn=class'Jellybean',SpawnParticles=class'Spawn_flash_1',SpawnSound=Sound'spawn_bean01',SpawnChance=255,SpawnDelay=1.0,SpawnVelocityMult=1.0)

	bRandomSpawnOrder=True
	bVaryVelocity=True
	VaryVelocityIntensity=1.5

	SpawnCount=(Min=3.0,Max=6.0)
	MaxLives=3

	Physics=PHYS_None
	eVulnerableToSpell=SPELL_Flipendo
	DrawType=DT_Sprite
	Texture=Texture'MocaTexturePak.EditorIco.MOCASpawnerIcon'
	bHidden=True
	bBlockPlayers=False
}