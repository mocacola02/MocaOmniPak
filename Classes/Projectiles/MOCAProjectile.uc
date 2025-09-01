//============================================================
// MOCAProjectile.
//============================================================

class MOCAProjectile extends Projectile;

var() float LaunchSpeed;         // Initial speed of projectile
var() float LaunchAngle;         // Angle in degrees (0 = forward, 90 = straight up)
var() float GravityScale;        // Scale gravity effect (1.0 = normal, 0.0 = none)
var() class<ParticleFX> DespawnEmitter; // Particles to spawn on destroy
var() int DamageToHarry; // How much damage should Harry take?
var() name DamageName; // Name of the damage type harry will take

var vector InitialDir;           // Stored initial launch direction
var vector ShotTarget;           // Where this projectile is aimed
var vector Gravity;
var harry PlayerHarry;
var bool NoDespawnEmit;

var() class<ParticleFX> ParticleClass;    // What effect to spawn (e.g. fireball trail)
var Actor ParticleActor;             // Instance of spawned effect

event PostBeginPlay()
{
    Super.PostBeginPlay();
    PlayerHarry = Harry(Level.PlayerHarryActor);
    Gravity = Region.Zone.ZoneGravity * 0.5;
    LaunchProjectile();
}

function vector GetShotTarget()
{
    // Default: straight forward from owner
    if (Owner != None)
        return Owner.Location + Vector(Owner.Rotation) * 1000;
    else
        return Location + Vector(Rotation) * 1000;
}

function LaunchProjectile()
{
    local vector ToTarget;

    ShotTarget = GetShotTarget();

    // Direction to target
    ToTarget = Normal(ShotTarget - Location);

    // Optionally tilt upwards by LaunchAngle
    if (LaunchAngle != 0)
        ToTarget = Normal(ToTarget >> Rotator(vect(0,0,1) * LaunchAngle));

    InitialDir = ToTarget;
    Velocity   = ToTarget * LaunchSpeed;

    // Spawn attached particle if specified
    if (ParticleClass != None && ParticleActor == None)
    {
        ParticleActor = Spawn(ParticleClass, self);
        if (ParticleActor != None)
            ParticleActor.SetBase(self); // attach to projectile
    }
}

function OnLand(vector HitNormal)
{
    //Set behavior in child classes
    KillProjectile();
}

function KillProjectile()
{
    if (ParticleActor != None)
    {
        ParticleActor.Destroy();
        ParticleActor = None;
    }

    if (!NoDespawnEmit)
    {
        Spawn(DespawnEmitter);
    }

    Destroy();
}

event Touch(Actor Other)
{
    super.Touch(Other);
    if (Other.IsA('harry'))
    {
        PlayerHarry.TakeDamage(DamageToHarry,Pawn(Owner),Location,Velocity,DamageName);
        Destroy();
    }
}

event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    Velocity.Z += (Gravity.Z * GravityScale) * DeltaTime;

    if (ParticleActor != None)
        ParticleActor.SetLocation(Location);
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
    DamageToHarry=10
    DamageName=MOCAProjectile
}
