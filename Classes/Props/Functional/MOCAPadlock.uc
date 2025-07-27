//================================================================================
// MOCAPadlock.
//================================================================================

class MOCAPadlock extends MOCAHP3Objects;

var ParticleFX fxExplode;
var() Class<ParticleFX> fxExplodeClass;
var() bool fastOpen; //Moca: If true, use faster opening animation
var() Sound UnlockSounds[3]; //Moca: Sounds to use for unlock animation

function PreBeginPlay()
{
  PlayerHarry = harry(Level.PlayerHarryActor);
}

event Destroyed()
{
  if ( fxExplode != None )
  {
    fxExplode.Shutdown();
  }
  Super.Destroyed();
}

function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
  if (fastOpen)
  {
    GotoState('openUpFast');
  }
  else 
  {
    GotoState('openUp');
  }
  return True;
}

function OnAlohomoraExplode()
{
  TriggerEvent(Event,None,None);
  Destroy();
}


state openUp
{
    begin:
        PlaySound(GetUnlockSFX());
        PlayAnim('Open');
        FinishAnim();
        OnAlohomoraExplode();
}

state openUpFast
{
    begin:
        PlayAnim('open2');
        FinishAnim();
        OnAlohomoraExplode();
}

function Sound GetUnlockSFX()
{
    local int randNum;
    local Sound UnlockSFX;

    randNum = Rand(ArrayCount(UnlockSounds));
    UnlockSFX = UnlockSounds[randNum];
    return UnlockSFX;
}

defaultproperties
{
     fxExplodeClass=Class'HPParticle.Aloh_hit'
     UnlockSounds(0)=Sound'MocaSoundPak.Props.padlock01'
     UnlockSounds(1)=Sound'MocaSoundPak.Props.padlock02'
     UnlockSounds(2)=Sound'MocaSoundPak.Props.padlock03'
     eVulnerableToSpell=SPELL_Alohomora
     Mesh=SkeletalMesh'MocaModelPak.skPadlock'
     DrawScale=2.5
     CollisionRadius=8
     CollisionWidth=16
     CollisionHeight=8
     CollideType=CT_OrientedCylinder
     bBlockActors=False
     bBlockPlayers=False
}
