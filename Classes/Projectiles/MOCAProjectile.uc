class MOCAProjectile extends Projectile;

var bool bNoDespawnEmit;
var class<ParticleFX> ParticleClass;
var class<ParticleFX> DespawnEmitter;
var ParticleFX ParticleActor;
var class<Actor> LandedClass;
var Sound LandedSound;

var float DamageToDeal;
var name DamageName;

var float LaunchSpeed;
var float GravityScale;
var float TargetInaccuracy;

var bool bHomingTowardTarget;
var float HomingStrength;   // 0.0 = no homing, 1.0 = instant lock

var Vector Gravity;
var Vector ShotTarget;
var harry PlayerHarry;
var Actor TargetActor;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);
	Gravity = Region.Zone.ZoneGravity * GravityScale;

	LaunchProjectile();
}

event Tick(float DeltaTime)
{
	local Vector HomingDir;

	Super.Tick(DeltaTime);

	// Apply gravity to velocity each tick
	Velocity += Gravity * DeltaTime;

	// Homing: steer velocity toward the fixed ShotTarget
	if ( bHomingTowardTarget )
	{
		HomingDir = Normal(ShotTarget - Location);
		Velocity = Normal(Velocity + HomingDir * HomingStrength) * VSize(Velocity);
	}

	// Keep particle attached
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

event Touch(Actor Other)
{
	Super.Touch(Other);

	if ( Other == PlayerHarry )
	{
		PlayerHarry.TakeDamage(DamageToDeal, Pawn(Owner), Location, Velocity, DamageName);
		KillProjectile();
	}
}


///////////////////
// Main Functions
///////////////////

function LaunchProjectile()
{
	local Vector AimDir;
	local Vector Inaccuracy;

	// Compute a fixed shot target at spawn time only
	if ( TargetActor != None )
	{
		Inaccuracy.X = RandRange(-TargetInaccuracy, TargetInaccuracy);
		Inaccuracy.Y = RandRange(-TargetInaccuracy, TargetInaccuracy);
		Inaccuracy.Z = RandRange(-TargetInaccuracy, TargetInaccuracy);

		ShotTarget = TargetActor.Location + Inaccuracy;

		Log(string(TargetActor)$" Location: "$string(TargetActor.Location)$" | Inaccuracy: "$string(Inaccuracy)$" | ShotTarget: "$string(ShotTarget));

		// Aim from our location toward the target, plus inaccuracy offset
		AimDir = Normal(ShotTarget - Location);
	}
	else
	{
		AimDir = Vector(Rotation);
	}

	Velocity = AimDir * LaunchSpeed;
	

	if ( ParticleClass != None && ParticleActor == None )
	{
		ParticleActor = Spawn(ParticleClass, Self,, Location);
	}
}

function KillProjectile()
{
    if ( ParticleActor != None )
	{
		ParticleActor.Shutdown();
	}

    if ( !bNoDespawnEmit && DespawnEmitter != None )
	{
		Spawn(DespawnEmitter);
	}
    
    PlaySound(LandedSound, SLOT_Misc);
    Destroy();
}

function OnLand(Vector HitNormal)
{
	local float SlopeAngle;
	SlopeAngle = ACos(HitNormal.Z) * (180.0 / Pi);

	if (SlopeAngle < 45.0 && LandedClass != None)
	{
		Spawn(LandedClass,,, Location, Rotation);
	}

	KillProjectile();
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
    TargetInaccuracy=8.0
    SoundRadius=384
    TransientSoundRadius=384
}