//================================================================================
// MOCAThrownObject. aka totally not a copy and paste of the bowtruckle projectile (i would've just extended from it but im dumb and i decided to just make a copy so i can easiy reference it from here instead of hgame because im lazy. Cope and Seethe)
//================================================================================

class MOCAThrownObject extends HProp;

var Class<ParticleFX> DestroyParticle;
var int Damage;
var float MaxLiveTime;
var Sound destroySounds[3];

function Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other == PlayerHarry )
  {
    PlayerHarry.TakeDamage(Damage,self,Location,vect(0.00,0.00,0.00),'None');
    DestroyObj();
  }
}

function DestroyObj()
{
  local Actor p;

  p = Spawn(DestroyParticle,,,Location,rot(0,0,0));
  PlaySoundMiss(p);
  Destroy();
}

function float PlaySoundMiss (Actor p)
{
  local float duration;
  local Sound snd;

  switch (Rand(3))
  {
    case 0:
    snd = destroySounds[0];
    break;
    case 1:
    snd = destroySounds[1];
    break;
    case 2:
    snd = destroySounds[2];
    break;
    default:
    snd = None;
    break;
  }
  duration = GetSoundDuration(snd);
  p.PlaySound(snd);
  return duration;
}

auto state twigno
{
  function Tick (float DeltaTime)
  {
    MaxLiveTime -= DeltaTime;
    if ( MaxLiveTime < 0 )
    {
      DestroyObj();
    }
  }
  
  function HitWall (Vector HitNormal, Actor Wall)
  {
    DestroyObj();
  }
 
 begin:
 loop:
  Sleep(1.0);
  goto ('Loop');
}

defaultproperties
{
     DestroyParticle=Class'HPParticle.DustCloud01_tiny'
     MaxLiveTime=8
     Physics=PHYS_Falling
     Mesh=SkeletalMesh'MocaModelPak.skFemur'
     DrawScale=0.6
     AmbientGlow=32
     CollisionRadius=5
     CollisionHeight=24
     CollideType=CT_OrientedCylinder
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
     destroySounds(0)=Sound'TrenchRun_wood_collision04'
     destroySounds(1)=Sound'TrenchRun_wood_collision01'
     destroySounds(2)=Sound'TrenchRun_wood_collision02'
}
