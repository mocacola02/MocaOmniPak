//================================================================================
// MOCAExplodingSpawner.
//================================================================================

//Quick repurposing of another actor I had, made to be more dynamic.

class MOCAExplodingSpawner extends MOCAPawn;

var Rotator explodeRot;
var() float AmountToFloat;                  //Moca: How high should the particle rise before exploding, Default: 15
var() bool shakeCamera;                     //Moca: Should the camera shake upon explosion
var() float fShakeTime;                     //Moca: How long should camera shake
var() float fRollMagnitude;                 //Moca: Shake roll intensity
var() float fVertMagnitude;                 //Moca: Shake vertical intensity
var() class<Actor> classToSpawn;            //Moca: What goodie should spawn when exploding
var() Class<ParticleFX> explodeParticle;    //Moca: What particle effect to use when exploding
var() Sound explodeSound;                   //Moca: What sound to play when exploding
var() int SpawnMin;                         //Moca: Minimum amount of items to spawn
var() int SpawnMax;                         //Moca: Maximum amount of items to spawn

var() class<ParticleFX> BuildUpParticle;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    harry = Harry(Level.PlayerHarryActor);
}

function Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other.IsA('harry') && !IsInState('Burst') )
  {
    GotoState('Burst');
  }
}

auto state stateIdle
{
    begin:
}

state Burst
{

    function SpawnEssence()
    {
        local int TotalToSpawn;
        local Vector Dir;
        local Vector Vel;
        local Actor newEssence;
        local Rotator SpawnRotation;

        TotalToSpawn = Clamp(Rand(SpawnMax), SpawnMin, SpawnMax);

        while (TotalToSpawn > 0)
        {
            SpawnRotation.Yaw = Rand(65536);
            SpawnRotation.Pitch = Rand(32768) - 16384;
            Dir = vector(SpawnRotation);

            Vel = Dir * RandRange(200, 400);

            newEssence = Spawn(classToSpawn,,,Location + Dir * 50, SpawnRotation);
            if (newEssence != None)
            {
                newEssence.Velocity = Vel;
                newEssence.SetPhysics(PHYS_Falling);
            }

            TotalToSpawn--;
        }

        Destroy();
    }


    event Tick(float DeltaTime)
    {
        local Vector DesiredLocation;

        DesiredLocation = Location;
        DesiredLocation.Z = DesiredLocation.Z + (AmountToFloat * DeltaTime);
        SetLocation(DesiredLocation);
    }

    begin:
        PlaySound(explodeSound,,0.5);
        sleep(5.75);
        Spawn(explodeParticle,,,,explodeRot);
        if (shakeCamera)
        {
            harry(Level.PlayerHarryActor).ShakeView(fShakeTime,fRollMagnitude,fVertMagnitude);
        } 
        sleep(0.25);
        SpawnEssence();
}

defaultproperties
{
     AmountToFloat=15
     shakeCamera=True
     fShakeTime=2
     fRollMagnitude=100
     fVertMagnitude=100
     classToSpawn=Class'HGame.Jellybean'
     explodeParticle=Class'HPParticle.BronzePickup'
     BuildUpParticle=Class'HPParticle.Godric_41_B'
     explodeSound=Sound'HPSounds.Magic_sfx.pickup_wizardcard'
     SpawnMin=4
     SpawnMax=16
     attachedParticleClass(0)=Class'HPParticle.SpellTarget_Lock'
     attachedParticleClass(1)=Class'HPParticle.TargetGlow'
     bHidden=True
     AmbientSound=Sound'HPSounds.Magic_sfx.wizardcard_rotate'
     bPersistent=True
     DrawType=DT_Sprite
     Texture=Texture'HPParticle.hp_fx.Particles.swirl001'
     AmbientGlow=200
     SoundRadius=8
     SoundVolume=255
     CollisionRadius=16
     CollisionHeight=24
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     explodeRot=(Pitch=16464,Roll=0,Yaw=0)
}
