//============================================================
// MOCAProjectile.
//============================================================
class MOCAProjectile extends Projectile;

var bool bNoDespawnEmit;				// Don't emit particles on despawn
var class<ParticleFX> ParticleClass;	// Normal particles
var class<ParticleFX> DespawnEmitter;	// Despawn particles
var ParticleFX ParticleActor;			// Particle actor ref

var class<Actor> LandedClass;			// Actor to spawn when landed
var Sound LandedSound;					// Sound to play when landed

var float DamageToDeal;					// Damage to deal to other
var name DamageName;					// Name of damage type

var bool bUseSpawnRotation;				// Use spawner's rotation
var float LaunchSpeed;					// Launch speed of projectile
var float LaunchAngle;					// Launch angle
var float GravityScale;					// Gravity scale to apply to velocity
var float TargetInaccuracy;				// How inaccurate the projectile is
var Range DesiredRadius;				// How far the projectile can travel
var Actor TargetActor;					// Actor to shoot towards

var Vector DesiredDirection;			// Desired direction to move in
var Vector InitialDirection;			// Initial direction
var Vector ShotTarget;					// Location of shot target
var Vector Gravity;						// Gravity force

var bool bHomingTowardTarget;			// Should it home in on target
var float HomingStrength;				// Strength of homing
var float HomingAccuracy;				// Accuracy of homing

var harry PlayerHarry;					// Player ref


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Get player ref, determine gravity, and launch projectile
	PlayerHarry = harry(Level.PlayerHarryActor);
	Gravity = (Region.Zone.ZoneGravity * 0.5) * GravityScale;
	LaunchProjectile();
}

event Tick(float DeltaTime)
{
	local Vector NewDirection;
	local Vector CurrentTargetDirection;

	Super.Tick(DeltaTime);

	// Add gravity force
	Velocity.Z += (Gravity.Z) * DeltaTime;

	// If homing on target
	if ( bHomingTowardTarget )
	{
		// Get direction to target
		CurrentTargetDirection = Normal((PlayerHarry.Location - Location) + (ShotTarget - GetShotTarget()));

		// Determine final direction
		NewDirection = Normal(Velocity);
		NewDirection = Normal((NewDirection + (CurrentTargetDirection - NewDirection) * HomingStrength) * DeltaTime);

		// Set velocity towards target
		Velocity = Normal(NewDirection) * VSize(Velocity);
	}

	// If we have a particle actor, update its location
	if ( ParticleActor != None )
	{
		ParticleActor.SetLocation(Location);
	}
}

event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	// Handle landing
	OnLand(HitNormal);
}

event HitWall(vector HitNormal, actor HitWall)
{
	Super.HitWall(HitNormal, HitWall);
	// Handle landing
	OnLand(HitNormal);
}


///////////////////
// Main Functions
///////////////////

function LaunchProjectile()
{
	// Set initial direction
	InitialDirection = Vector(Rotation);
	// Set velocity using direction & launch speed
	Velocity = InitialDirection * LaunchSpeed;

	// Determine shot target location
	ShotTarget = GetShotTarget();

	// If we have a particle class but no actor, spawn the actor
	if ( ParticleClass != None && ParticleActor == None )
	{
		ParticleActor = Spawn(ParticleClass,Self,,Location);
	}
}

function KillProjectile()
{
	// Shutdown particles if needed
	if ( ParticleActor != None )
	{
		ParticleActor.Shutdown();
	}

	// If not bNoDespawnEmit, spawn despawn emitter
	if ( !bNoDespawnEmit )
	{
		Spawn(DespawnEmitter);
	}

	// Play landed sound & destroy
	PlaySound(LandedSound,SLOT_Misc);
	Destroy();
}

function OnLand(Vector HitNormal)
{
	local float SlopeAngle;
	// Determine slope angle
	SlopeAngle = ACos(HitNormal.Z) * (180 / Pi);

	// If actually ground, spawn our landed class
	if ( SlopeAngle < 45.0 && LandedClass != None )
	{
		Spawn(LandedClass,,,Location,Rotation,True);
	}

	// Destroy self
	KillProjectile();
}

event Touch(Actor Other)
{
	Super.Touch(Other);

	// If touched Harry, damage him
	if ( Other == PlayerHarry )
	{
		PlayerHarry.TakeDamage(DamageToDeal,Pawn(Owner),Location,Velocity,DamageName);
		KillProjectile();
	}
}


/////////////////////
// Helper Functions
/////////////////////

function Vector GetShotTarget()
{
	local float FinalRange;
	local Vector FinalInaccuracy;

	// Determine inaccuracy
	FinalInaccuracy.X = RandRange(-TargetInaccuracy,TargetInaccuracy);
	FinalInaccuracy.Y = RandRange(-TargetInaccuracy,TargetInaccuracy);
	FinalInaccuracy.Z = RandRange(-TargetInaccuracy,TargetInaccuracy);

	// Determine final range
	FinalRange = RandRange(DesiredRadius.Min,DesiredRadius.Max);

	// Return target location
	return ( TargetActor.Location + FinalInaccuracy ) * FinalRange;
}


defaultproperties
{
	DespawnEmitter=Class'SmokeExplo_01'
	LaunchSpeed=600.0
	GravityScale=1.0
	LifeSpan=6.0
	Damage=20
	MomentumTransfer=50000
	DamageToDeal=10
	DamageName=MOCAProjectile

	HomingStrength=0.25
	HomingAccuracy=64.0

	DesiredRadius=(Min=1000,Max=1000)

	TargetInaccuracy=8.0

	SoundRadius=384
	TransientSoundRadius=384
}