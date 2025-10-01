//============================================================
// MOCAProjectile.
//============================================================

class MOCAProjectile extends Projectile;

var() class<ParticleFX> ParticleClass;    	// Moca: What effect to spawn (e.g. fireball trail)
var() class<ParticleFX> DespawnEmitter; 	// Moca: Particles to spawn on destroy

var() class<Actor> LandedClass;				// Moca: What class to spawn when the particle lands on the ground?
var() Sound LandedSound;

var() bool bUseSpawnRotation;    			// Moca: If true, launch using projectile's own rotation
var(ProjectileHoming) bool bHomingTowardTarget;  			// Moca: If true, steer gently toward ShotTarget

var() float DamageToDeal;					// Moca: How much damage to deal to Harry. Def: 10
var(ProjectilePhysics) float LaunchSpeed;         			// Moca: Initial speed of projectile
var(ProjectilePhysics) float LaunchAngle;         			// Moca: Angle in degrees (0 = forward, 90 = straight up)
var(ProjectilePhysics) float GravityScale;        			// Moca: Scale gravity effect (1.0 = normal, 0.0 = none)
var(ProjectilePhysics) float TargetInaccuracy;				// Moca: How inaccurate is the projectile? The higher this value is, the further it can possibly land from the intended target. Def: 8.0
var(ProjectilePhysics) float MinRange;
var(ProjectilePhysics) float MaxRange;
var(ProjectileHoming) float HomingStrength;      			// Moca: Blend factor (0 = none, 1 = instant snap)
var(ProjectileHoming) float HomingAccuracy;					// Moca: How accurate is the homing? 0.0 is most accurate, with higher numbers being less accurate. Def: 50

var() name DamageName; 						// Moca: Name of the damage type harry will take

var ParticleFX ParticleActor;            	// Instance of spawned effect

var vector DesiredDirection;     			// Stored direction to target (for homing)
var vector InitialDir;           			// Stored initial launch direction
var vector ShotTarget;           			// Where this projectile is aimed
var vector Gravity;							// Projectile gravity

var harry PlayerHarry;

var bool bNoDespawnEmit;					// Whether or not to use a particle emission on despawn

event PostBeginPlay()
{
    Super.PostBeginPlay();
    PlayerHarry = Harry(Level.PlayerHarryActor);
    Gravity = Region.Zone.ZoneGravity * 0.5;
    LaunchProjectile();
}

function vector GetShotTarget()
{
	local float FinalRange;
	local float NegativeTI;
	local Vector FinalInaccuracy;

	NegativeTI = TargetInaccuracy * -1.0;
	
	FinalInaccuracy.X = RandRange(NegativeTI,TargetInaccuracy);
	FinalInaccuracy.Y = RandRange(NegativeTI,TargetInaccuracy);
	FinalInaccuracy.Z = RandRange(NegativeTI,TargetInaccuracy);

	FinalRange = RandRange(MinRange,MaxRange);

    if (Owner != None)
        return Owner.Location + Vector(Owner.Rotation) + FinalInaccuracy * FinalRange;
    else
        return Location + Vector(Rotation) + FinalInaccuracy * FinalRange;
}

function LaunchProjectile()
{
    local vector AimError;

    // Fire in spawn rotation
    InitialDir = vector(Rotation);
    Velocity   = InitialDir * LaunchSpeed;

    // Pick a target with some error
    ShotTarget = GetShotTarget();

    // Add random aim offset (error cone)
    AimError.X = FRand() * HomingAccuracy; // tweak values for spread
    AimError.Y = FRand() * HomingAccuracy;
    AimError.Z = FRand() * HomingAccuracy;
    ShotTarget += AimError;

    // Spawn attached particle if specified
    if (ParticleClass != None && ParticleActor == None)
    {
        ParticleActor = Spawn(ParticleClass, self);
        if (ParticleActor != None)
            ParticleActor.SetBase(self);
    }
}

event Tick(float DeltaTime)
{
    local vector NewDir, CurrentTargetDir;

    Super.Tick(DeltaTime);

    // Gravity
    Velocity.Z += (Gravity.Z * GravityScale) * DeltaTime;

    if (bHomingTowardTarget)
    {
        // Always re-aim at Harry's current position (plus error offset we baked in)
        if (PlayerHarry != None)
            CurrentTargetDir = Normal((PlayerHarry.Location - Location) + (ShotTarget - GetShotTarget()));
        else
            CurrentTargetDir = Normal(ShotTarget - Location);

        NewDir = Normal(Velocity);
        NewDir = Normal(NewDir + (CurrentTargetDir - NewDir) * HomingStrength * DeltaTime);

        Velocity = Normal(NewDir) * VSize(Velocity);
    }

    if (ParticleActor != None)
        ParticleActor.SetLocation(Location);
}

function OnLand(vector HitNormal)
{
	local float SlopeAngle;
	SlopeAngle = acos(HitNormal.Z) * (180 / Pi);
	Log("Projectile landed slope angle: " $ string(SlopeAngle));

	if (SlopeAngle < 45.0 && LandedClass != None)
	{
		Log("Spawning landed class");
		Spawn(LandedClass,,,Location,Rotation,True);
	}

    KillProjectile();
}

function KillProjectile()
{
    if (ParticleActor != None)
    {
        ParticleActor.Shutdown();
        ParticleActor = None;
    }

    if (!bNoDespawnEmit)
    {
        Spawn(DespawnEmitter);
    }

	PlaySound(LandedSound,SLOT_Misc);
    Destroy();
}

event Touch(Actor Other)
{
    super.Touch(Other);
    if (Other.IsA('harry'))
    {
        PlayerHarry.TakeDamage(DamageToDeal,Pawn(Owner),Location,Velocity,DamageName);
        KillProjectile();
    }
}

event HitWall(vector HitNormal, actor HitWall)
{
    super.HitWall(HitNormal, HitWall);
	
    OnLand(HitNormal);
}

defaultproperties
{
    DespawnEmitter=Class'SmokeExplo_01'
    LaunchSpeed=600.0
    LaunchAngle=0.0
    GravityScale=1.0
    LifeSpan=6.0
    Damage=20
    MomentumTransfer=50000
    ParticleClass=None
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
