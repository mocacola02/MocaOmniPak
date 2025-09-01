//============================================================
// MOCAFireBall.
//============================================================

class MOCAFireBall extends MOCAProjectile;

var MOCAFireseedPlant Plant;

event PostBeginPlay()
{
    Super.PostBeginPlay();

    Plant = MOCAFireseedPlant(Owner);

    if (Plant == None)
    {
		return;
    }

    LaunchSpeed = RandRange(Plant.FireballDistMin, Plant.FireballDistMax);
}

function vector GetShotTarget()
{
    if (Plant != None && !Plant.alwaysAttack && PlayerHarry != None)
        return PlayerHarry.Location;
    else
        return Super.GetShotTarget();
}

function LaunchProjectile()
{
    local vector ToTarget;
	local vector HorizDir;

    ShotTarget = GetShotTarget();

    ToTarget = ShotTarget - Location;
	HorizDir.Z = Plant.FireballLaunchHeight;
	HorizDir = Normal(ToTarget);

    // Set velocity based on LaunchSpeed
    Velocity = HorizDir * LaunchSpeed;

    // Spawn particle if any
    if (ParticleClass != None && ParticleActor == None)
    {
        ParticleActor = Spawn(ParticleClass, self);
        if (ParticleActor != None)
            ParticleActor.SetBase(self);
    }
}

defaultproperties
{
	LaunchSpeed=350
    Damage=30
    LifeSpan=6.0
    LightType=LT_Steady
    bReallyDynamicLight=True
    LightBrightness=192
    LightHue=18
    LightSaturation=0
    ParticleClass=Class'HPParticle.Crabfire'
}
