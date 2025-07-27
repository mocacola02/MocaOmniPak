class MOCAFireBall extends spellFireSmall;

var MOCAFireseedPlant Plant;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    Plant = MOCAFireseedPlant(Owner);
    GlobalSpeed = RandRange(Plant.FireballDistMin,Plant.FireballDistMax);
}

function Touch(Actor Other)
{
    local actor HitActor;
	local vector HitLocation, HitNormal, TestLocation;
	
    Super.Touch(Other);
    Log(string(HitLocation) @ "  " @ string(HitNormal) @ "  " @ string(TestLocation));
}

function bool OnSpellHitHPawn (Actor aHit, Vector HitLocation)
{
    Log("Hit HPawn  " @ string(aHit));
    if (aHit.IsA('MOCAFireBall') || aHit.IsA('MOCAFireSpot'))
    {
        return False;
    }
    Spawn(Class'FireballOnHarry',,,Location);
    return True;
}

function bool OnSpellHitWall (Actor aWall, Vector HitNormal)
{
    local Rotator AlignedRotation;
    local MOCAFireSpot FS;

    if (HitNormal.Z > 0.7)  // Adjust this threshold based on acceptable slope
    {
        // Calculate the rotation to align with the slope
        AlignedRotation = Rotator(HitNormal);  // Convert hit normal to rotator

        Log(string(AlignedRotation));

        // Spawn MOCAFireSpot at the hit location with the aligned rotation
        FS = Spawn(class'MOCAFireSpot',,, Location, AlignedRotation);
        FS.SetOwner(self);

        // Destroy the projectile on ground impact
        Destroy();  
    }
}

state StateFlying
{
  function BeginState()
  {
    if (!Plant.alwaysAttack)
    {
      CurrentDir = Normal(PlayerHarry.Location - Location);
    }
    else
    {
      CurrentDir = VRand();
    }
    
    Velocity = CurrentDir * GlobalSpeed;
    Velocity.Z += Plant.FireballLaunchHeight;
  }
  
  event Tick (float fTimeDelta)
  {
    Super.Tick(fTimeDelta);

    Velocity.Z -= fGravityEffect * fTimeDelta;

    if (fxFlyParticleEffect != None)
    {
      fxFlyParticleEffect.SetLocation(Location);
    }
  }
}

defaultproperties
{
     fGravityEffect=500
     LightBrightness=192
     LightHue=18
     LightSaturation=0
}
