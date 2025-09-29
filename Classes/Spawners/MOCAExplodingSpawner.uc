//================================================================================
// MOCAExplodingSpawner.
//================================================================================

class MOCAExplodingSpawner extends MOCASpawner;

var Rotator explodeRot;
var() float AmountToFloat;                  // Moca: How high should the particle rise before exploding, Default: 15
var() bool shakeCamera;                     // Moca: Should the camera shake upon explosion
var() float fShakeTime;                     // Moca: How long should camera shake
var() float fRollMagnitude;                 // Moca: Shake roll intensity
var() float fVertMagnitude;                 // Moca: Shake vertical intensity
var() Class<ParticleFX> explodeParticle;    // Moca: What particle effect to use when exploding
var() Sound explodeSound;                   // Moca: What sound to play when exploding

var() class<ParticleFX> BuildUpParticle;

event Touch (Actor Other)
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
            PlayerHarry.ShakeView(fShakeTime,fRollMagnitude,fVertMagnitude);
        } 
        sleep(0.25);
        killAttachedParticleFX(0.0);
        GotoState('stateSpawn');
}

defaultproperties
{
     AmountToFloat=15
     shakeCamera=True
     fShakeTime=2
     fRollMagnitude=100
     fVertMagnitude=100
     explodeParticle=Class'HPParticle.BronzePickup'
     BuildUpParticle=Class'HPParticle.Godric_41_B'
     explodeSound=Sound'HPSounds.Magic_sfx.pickup_wizardcard'
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
     minAmountToSpawn=5
     maxAmountToSpawn=20
     eVulnerableToSpell=SPELL_None
     listOfSpawns(0)=(actorToSpawn=Class'Jellybean',spawnChance=255,spawnDelay=0.0,spawnSound=Sound'spawn_bean01',spawnParticle=Class'Spawn_flash_1',velocityMult=1.0)
     maxVelocityVariance=32
     Rotation=(Pitch=16384,Yaw=0,Roll=0)
    }
