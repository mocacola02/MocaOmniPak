class MOCAbaseSpell extends baseSpell;

var WetTexture SpellWetTexture; // What wet texture to use when aiming over a compatible actor?
var byte AimLightBrightness;    // What brightness to use for the wand light when selecting a compatible actor?
var byte AimLightHue;   // What hue to use for the wand light when selecting a compatible actor?
var byte AimLightSaturation;    // What saturation to use for the wand light when selecting a compatible actor?
var Color AimParticleStartColor; // What color to use for the wand particle when selecting a compatible actor?
var Color AimParticleEndColor;
var Texture AimParticleTexture; // What particle texture to use for the wand particle when selecting a compatible actor?

auto state stateIdle
{
begin:
  GotoState('StateFlying');
}

state StateFlying
{
  function BeginState()
  {
    Velocity = vector(Rotation) * Speed;
  }
  
  event Tick (float fTimeDelta)
  {
    Super.Tick(fTimeDelta);
    UpdateRotationWithSeeking(fTimeDelta);
    if ( fxFlyParticleEffect != None )
    {
      fxFlyParticleEffect.SetLocation(Location);
    }
  }
  begin:
}