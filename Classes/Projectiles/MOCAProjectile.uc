//============================================================
// MOCAProjectile.
//============================================================

class MOCAProjectile extends Projectile;

var bool bNoDespawnEmit;
var class<ParticleFX> ParticleClass;
var class<ParticleFX> DespawnEmitter;
var ParticleFX ParticleActor;

var class<Actor> LandedClass;
var Sound LandedSound;

var float DamageToDeal;
var name DamageName;

var bool bUseSpawnRotation;
var float LaunchSpeed;
var float LaunchAngle;
var float GravityScale;
var float TargetInaccuracy;
var float MinRange;
var float MaxRange;
var Actor TargetActor;

var Vector DesiredDirection;
var Vector InitialDirection;
var Vector ShotTarget;
var Vector Gravity;

var bool bHomingTowardTarget;
var float HomingStrength;
var float HomingAccuracy;

var harry PlayerHarry;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);
	Gravity = (Region.Zone.ZoneGravity * 0.5) * GravityScale;
	LaunchProjectile();
}

event Tick(float DeltaTime)
{
	local Vector NewDirection;
	local Vector CurrentTargetDirection;

	Super.Tick(DeltaTime);

	Velocity.Z += (Gravity.Z) * DeltaTime;

	if ( bHomingTowardTarget )
	{
		CurrentTargetDirection = Normal((PlayerHarry.Location - Location) + (ShotTarget - GetShotTarget()));

		NewDirection = Normal(Velocity);
		NewDirection = Normal((NewDirection + (CurrentTargetDirection - NewDirection) * HomingStrength) * DeltaTime);

		Velocity = Normal(NewDirection) * VSize(Velocity);
	}

	if ( ParticleActor != None )
	{
		ParticleActor.SetLocation(Location);
	}
}

event Landed(vector HitNormal)
{
	Super.Landed(HitNormal);
	OnLand(HitNormal);
}

event HitWall(vector HitNormal, actor HitWall)
{
	Super.HitWall(HitNormal, HitWall);
	OnLand(HitNormal);
}


///////////////////
// Main Functions
///////////////////

function LaunchProjectile()
{
	InitialDirection = Vector(Rotation);
	Velocity = InitialDirection * LaunchSpeed;

	ShotTarget = GetShotTarget();

	if ( ParticleClass != None && ParticleActor == None )
	{
		ParticleActor = Spawn(ParticleClass,Self,,Location);
	}
}

function KillProjectile()
{
	if ( ParticleActor != None )
	{
		ParticleActor.Shutdown();
	}

	if ( !bNoDespawnEmit )
	{
		Spawn(DespawnEmitter);
	}

	PlaySound(LandedSound,SLOT_Misc);
	Destroy();
}

function OnLand(Vector HitNormal)
{
	local float SlopeAngle;
	SlopeAngle = ACos(HitNormal.Z) * (180 / Pi);

	if ( SlopeAngle < 45.0 && LandedClass != None )
	{
		Spawn(LandedClass,,,Location,Rotation,True);
	}

	KillProjectile();
}

event Touch(Actor Other)
{
	Super.Touch(Other);

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

	FinalInaccuracy.X = RandRange(-TargetInaccuracy,TargetInaccuracy);
	FinalInaccuracy.Y = RandRange(-TargetInaccuracy,TargetInaccuracy);
	FinalInaccuracy.Z = RandRange(-TargetInaccuracy,TargetInaccuracy);

	FinalRange = RandRange(MinRange,MaxRange);

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

	MinRange=1000
	MaxRange=1000

	TargetInaccuracy=8.0

	SoundRadius=384
	TransientSoundRadius=384
}