//================================================================================
// MOCASpawner.
//================================================================================
class MOCASpawner extends MOCAPawn;

struct SpawnedProperty
{
	var() string PropertyName;
	var() string PropertyValue;
};

struct SpawnSetting
{
	var() class<Actor> ActorToSpawn;
	var() class<ParticleFX> SpawnParticles;
	var() Sound SpawnSound;

	var() byte SpawnChance;
	var float FinalWeight;

	var() float SpawnDelay;
	var() float SpawnVelocityMult;

	var() Vector SpawnOffset;
	var() Rotator SpawnRotation;

	var() array<SpawnedProperty> SpawnProperties;
};

var() array<SpawnSetting> ListOfSpawns;

var() bool bRandomSpawnOrder;
var() bool bRandomSpawnDirection;
var() bool bVaryVelocity;
var() bool bSpawnerFacesHarry;

var() int MinSpawnCount;
var() int MaxSpawnCount;
var() int MaxLives;
var() float VaryVelocityIntensity;

var() Vector GlobalSpawnOffset;
var() Rotator GlobalSpawnRotation;


var int CurrentSpawnCount;
var int CurrentSpawnIdx;
var int TotalWeight;
var int FinalMaxSpawnCount;
var int ListLength;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( MOCAHelpers.IsEmpty(ListOfSpawns) )
	{
		Log("Error! "$string(Self)$" does not have anything in its spawn list! Destroying!");
		Destroy();
	}

	SetSpawnWeights();

	ListLength = ListOfSpawns.Length;
}

event Trigger(Actor Other, Pawn EventInstigator)
{
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

	if ( bRandomSpawnOrder )
	{
		CurrentSpawnIdx = GetWeightedRandomIndex;
	}

	SpawnLocation = Location + GlobalSpawnOffset + ListOfSpawns[CurrentSpawnIdx].SpawnOffset;

	SpawnedParticle = Spawn(GetSpawnParticles(),,,SpawnLocation);

	if ( bRandomSpawnDirection )
	{
		SpawnDirection = GetRandomDirection();
		SpawnRotation = Rotator(SpawnDirection);
	}
	else
	{
		SpawnRotation = Rotation + GlobalSpawnRotation + ListOfSpawns[CurrentSpawnIdx].SpawnRotation;
		SpawnDirection = Vector(FinalRot);
	}

	SpawnedParticle = Spawn(GetSpawnParticles(),,,SpawnLocation);
	SpawnedParticle.PlaySound(GetSpawnSound());

	SpawnedActor = Spawn(ListOfSpawns[CurrentSpawnIdx].ActorToSpawn,,,SpawnLocation,SpawnRotation);

	if ( bVaryVelocity )
	{
		RandVelocityMult = Range(1.0,VaryVelocityIntensity);
	}
	else
	{
		RandVelocityMult = 1.0;
	}

	SpawnedActor.Velocity = SpawnDirection * RandVelocityMult * ListOfSpawns[CurrentSpawnIdx].SpawnVelocityMult;

	if ( ListOfSpawns[CurrentSpawnIdx].SpawnProperties.Length > 0 )
	{
		SetSpawnProperties(SpawnedActor);
	}

	CurrentSpawnCount++;
}

function ProcessSpell()
{
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

	for ( i = 0; i < ListOfSpawns[CurrentSpawnIdx].SpawnProperties.Length; i++ )
	{
		PropName = ListOfSpawns[CurrentSpawnIdx].SpawnProperties[i].PropertyName;
		PropVal = ListOfSpawns[CurrentSpawnIdx].SpawnProperties[i].PropertyValue;

		if ( PropName != "" )
		{
			SpawnedActor.SetPropertyText(PropName,PropVal);
		}
	}
}

function SetSpawnWeights()
{
	local int i;

	for ( i = 0; i < ListLength; i++ )
	{
		TotalWeight += int(ListOfSpawns[i].SpawnChance);
	}

	for ( i = 0; i < ListLength; i++ )
	{
		ListOfSpawns[i].FinalWeight = ListOfSpawns[i].SpawnChance / TotalWeight;
	}
}

function bool ShouldDie()
{
	return MaxLives <= 0;
}

function int GetMaxSpawnCount()
{
	local int RandCount;
	RandCount = Clamp(Rand(MaxSpawnCount),MinSpawnCount,MaxSpawnCount);
	RandCount = Clamp(RandCount,1,MAXINT);
	return RandCount;
}

function int GetWeightedRandomIndex()
{
	local int i;
	
	Roll = FRand() * TotalWeight;

	for ( i = 0; i < ListLength; i++ )
	{
		if ( ListOfSpawns[i].FinalWeight <= 0.0 )
		{
			continue;
		}

		Roll -= ListOfSpawns[i].FinalWeight;
		if ( Roll <= 0.0 )
		{
			return i;
		}
	}

	return 0;
}

function float GetSpawnDelay()
{
	return ListOfSpawns[CurrentSpawnIdx].SpawnDelay;
}

function Vector GetRandomDirection()
{
	local float Theta;
	local float Radius;
	local float Z;
	local Vector Direction;

	Theta = FRand() * (2 * Pi);

	Z = (FRand() * 2) - 1.0;

	Radius = Sqrt(1.0 - Z * Z);

	Direction.X = Radius * Cos(Theta);
	Direction.Y = Radius * Sin(Theta);
	Direction.Z = Z;

	return Direction;
}

function Sound GetSpawnSound()
{
	return ListOfSpawns[CurrentSpawnIdx].SpawnSound;
}

function class<ParticleFX> GetSpawnParticles()
{
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
		eVulnerableToSpell = SPELL_None;
		MaxLives--;

		if ( bTurnSpawnerTowardsHarry )
		{
			EnableTurnTo(PlayerHarry);
		}
	}

	event EndState()
	{
		if ( ShouldDie() )
		{
			Destroy();
		}

		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
		CurrentSpawnCount = 0;

		DisableTurnTo();
	}

	begin:
		FinalMaxSpawnCount = GetMaxSpawnCount();
		SpawnItem();
		Sleep(GetSpawnDelay());

		if ( CurrentSpawnCount >= FinalMaxSpawnCount )
		{
			GotoState('stateIdle');
		}

		Goto('begin');
}

defaultproperties
{
	ListOfSpawns(0)=(ActorToSpawn=class'Jellybean',SpawnParticles=class'Spawn_flash_1',SpawnSound=Sound'spawn_bean01',SpawnChance=255,SpawnDelay=1.0,SpawnVelocityMult=1.0)

	bRandomSpawnOrder=True
	bVaryVelocity=True
	VaryVelocityIntensity=1.5

	MinSpawnCount=3
	MaxSpawnCount=6
	MaxLives=3

	Physics=PHYS_None
	eVulnerableToSpell=SPELL_Flipendo
	DrawType=DT_Sprite
	Texture=Texure'MocaTexturePak.EditorIco.MOCASpawnerIcon'
	bHidden=True
	bBlockPlayers=False
}