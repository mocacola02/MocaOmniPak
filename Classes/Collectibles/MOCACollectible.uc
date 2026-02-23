//================================================================================
// MOCACollectible.
//================================================================================
class MOCACollectible extends HProp;

var() bool bAttractedToHarry;	// Moca: Should the collectible move toward Harry
var() bool bFallsToGround;		// Moca: Should collectible fall to ground

var() int IncrementAmount;		// Moca: How many of this item to add to our inventory

var() float AttractionDelay;	// Moca: How long to wait before attracting
var() float AttractionSpeed;	// Moca: How fast should the collectible fly to Harry
var() float AttractionRange;	// Moca: How far can attraction be activated
var() float RotationSpeed;		// Moca: How fast should the collectible spin?

var() Vector AttractionOffset;	// Moca: Offset to the position (Harry's location) to fly to

var() Sound PickUpSound;		// Moca: What sound to play on pickup


var float CurrentYaw;			// Current yaw
var float CurrentDelayTime;		// Current delay time for spawning


///////////
// Events
///////////

event PreBeginPlay()
{
	Super.PreBeginPlay();

	// Override nPickupIncrement & soundPickup
	nPickupIncrement = IncrementAmount;
	soundPickup = PickUpSound;
}


///////////////////
// Main Functions
///////////////////

function FlyToHarry(float DeltaTime)
{
	local float DistFromHarry;

	// Get distance from harry
	DistFromHarry = VSize(Location - PlayerHarry.Location);

	// If Harry is close
	if ( DistFromHarry <= AttractionRange )
	{
		// If we aren't already flying
		if ( Physics != PHYS_Flying )
		{
			// Enter flying mode
			SetPhysics(PHYS_Flying);
			SetCollision(True,False,False);
			bCollideWorld = False;
		}

		// Get target location & direction and go there (aka fly to Harry)
		local Vector TargetLocation, Direction;
		TargetLocation = PlayerHarry.Location + AttractionOffset;
		Direction = Normal(TargetLocation - Location);
		SetLocation(Location + Direction * AttractionSpeed * DeltaTime);
	}
	// Otherwise, if Harry is too far
	else
	{
		// If we aren't falling, go to falling
		if ( Physics != PHYS_Falling )
		{
			SetPhysics(PHYS_Falling);
			SetCollision(MapDefault.bCollideActors, MapDefault.bBlockActors, MapDefault.bBlockPlayers);
			bCollideWorld = MapDefault.bCollideWorld;
		}
	}
}


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		// If we should bounce, do that
		if ( bBounceIntoPlace || bBounce )
		{
			GotoState('BounceIntoPlace');
		}
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		// If attracted to Harry, fly to him
		if ( bAttractedToHarry )
		{
			FlyToHarry(DeltaTime);
		}
	}
}

state BounceIntoPlace
{
	event BeginState()
	{
		// If fall to ground, fall
		if ( bFallsToGround )
		{
			SetPhysics(PHYS_Falling);
		}
		// Otherwise, don't
		else
		{
			SetPhysics(PHYS_None);
		}
	}

	event Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);

		// If attracted to harry, fly to him
		if (bAttractedToHarry && AttractionDelay < CurrentDelayTime)
		{
			FlyToHarry(DeltaTime);
		}
		// Otherwise, don't
		else if (bAttractedToHarry)
		{
			CurrentDelayTime += DeltaTime;
		}
	}
}


defaultproperties
{
	bFallsToGround=True
	PickUpSound=Sound'HPSounds.Magic_sfx.pickup11'
	bPickupOnTouch=True
	EventToSendOnPickup=EarthPickupEvent
	PickupFlyTo=FT_HudPosition
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupEarth'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemEarth'
	bBounceIntoPlace=True
	soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
	Physics=PHYS_Walking
	bPersistent=True
	Mesh=SkeletalMesh'MocaModelPak.skEarthGem'
	AmbientGlow=200
	CollisionRadius=22
	CollisionHeight=12
	bBlockActors=False
	bBlockPlayers=False
	bProjTarget=False
	bBlockCamera=False
	bBounce=True
	RotationSpeed=160
	bAlignBottom=False
	AttractionSpeed=300.0
	bCanFly=True
	SoundVolMult=1.0
	IncrementAmount=1.0
	AttractionRange=128.0
}