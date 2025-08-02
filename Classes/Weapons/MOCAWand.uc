//================================================================================
// MOCAWand.
//================================================================================

class MOCAWand extends baseWand;

var bool isAiming;

function PostBeginPlay()
{
    super.PostBeginPlay();
}

event Tick (float fTimeDelta)
{
    Super.Tick(fTimeDelta);
    if (isAiming)
    {
        fxChargeParticles.Textures[0] = GetParticleTexture(CurrentSpell);
        GetParticleColor(CurrentSpell);
        GetLightColor(CurrentSpell);
        if (PlayerHarry.SpellCursor.aCurrentTarget == None)
        {
            LightBrightness = 128;
            LightSaturation = 255;
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';
            fxChargeParticles.ColorStart.Base.R = 255; fxChargeParticles.ColorStart.Base.G = 255; fxChargeParticles.ColorStart.Base.B = 255; fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 255; fxChargeParticles.ColorEnd.Base.B = 255; fxChargeParticles.ColorEnd.Base.A = 0;
        }
    }
}

function StartChargingSpell (bool bChargeSpell, optional bool in_bHarryUsingSword, optional Class<baseSpell> ChargeSpellClass)
{
    Super.StartChargingSpell(bChargeSpell,in_bHarryUsingSword,ChargeSpellClass);
    isAiming = true;
    fxChargeParticles.bEmit = true;
    LightType = LT_Steady;
}

function StopChargingSpell()
{
    Super.StopChargingSpell();
    isAiming = false;
    fxChargeParticles.bEmit = false;
    LightType = LT_None;
}

function Texture GetParticleTexture (Class<baseSpell> spellClass)
{
  switch (spellClass)
  {
    case Class'spellFlipendo':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    case Class'spellLumos':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    case Class'spellAlohomora':
    return Texture'HPParticle.hp_fx.Particles.Key3';
    case Class'spellSkurge':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    case Class'spellRictusempra':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    case Class'spellDiffindo':
    return Texture'HPParticle.hp_fx.Particles.Les_Sparkle_03';
    case Class'spellSpongify':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    case Class'spellDuelRictusempra':
    return Texture'HPParticle.hp_fx.Particles.Les_Sparkle_04';
    case Class'spellDuelMimblewimble':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    case Class'spellDuelExpelliarmus':
    return Texture'HPParticle.hp_fx.Particles.flare4';
    default: break;
  }

  return Texture'HPParticle.hp_fx.Particles.flare4';
}

function GetParticleColor (Class<baseSpell> spellClass)
{
    switch (spellClass)
    {
        case Class'spellFlipendo':
            fxChargeParticles.ColorStart.Base.R = 254; fxChargeParticles.ColorStart.Base.G = 142; fxChargeParticles.ColorStart.Base.B = 61; fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 201; fxChargeParticles.ColorEnd.Base.G = 85;  fxChargeParticles.ColorEnd.Base.B = 46; fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellLumos':
            fxChargeParticles.ColorStart.Base.R = 255; fxChargeParticles.ColorStart.Base.G = 237; fxChargeParticles.ColorStart.Base.B = 15;  fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 191; fxChargeParticles.ColorEnd.Base.B = 60;  fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellAlohomora':
            fxChargeParticles.ColorStart.Base.R = 253; fxChargeParticles.ColorStart.Base.G = 152; fxChargeParticles.ColorStart.Base.B = 0;   fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 202; fxChargeParticles.ColorEnd.Base.B = 40;  fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellSkurge':
            fxChargeParticles.ColorStart.Base.R = 34;  fxChargeParticles.ColorStart.Base.G = 67;  fxChargeParticles.ColorStart.Base.B = 255; fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 113; fxChargeParticles.ColorEnd.Base.G = 6;   fxChargeParticles.ColorEnd.Base.B = 164; fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellRictusempra':
            fxChargeParticles.ColorStart.Base.R = 207; fxChargeParticles.ColorStart.Base.G = 46;  fxChargeParticles.ColorStart.Base.B = 50;  fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 111; fxChargeParticles.ColorEnd.Base.B = 55;  fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellDiffindo':
            fxChargeParticles.ColorStart.Base.R = 121; fxChargeParticles.ColorStart.Base.G = 255; fxChargeParticles.ColorStart.Base.B = 11;  fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 121;   fxChargeParticles.ColorEnd.Base.G = 255;   fxChargeParticles.ColorEnd.Base.B = 11;   fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellSpongify':
            fxChargeParticles.ColorStart.Base.R = 143; fxChargeParticles.ColorStart.Base.G = 63;  fxChargeParticles.ColorStart.Base.B = 192; fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 43;  fxChargeParticles.ColorEnd.Base.G = 62;  fxChargeParticles.ColorEnd.Base.B = 138; fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellDuelRictusempra':
            fxChargeParticles.ColorStart.Base.R = 207; fxChargeParticles.ColorStart.Base.G = 46;  fxChargeParticles.ColorStart.Base.B = 50;  fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 111; fxChargeParticles.ColorEnd.Base.B = 55;  fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellDuelMimblewimble':
            fxChargeParticles.ColorStart.Base.R = 34;  fxChargeParticles.ColorStart.Base.G = 67;  fxChargeParticles.ColorStart.Base.B = 255; fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 113; fxChargeParticles.ColorEnd.Base.G = 6;   fxChargeParticles.ColorEnd.Base.B = 164; fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        case Class'spellDuelExpelliarmus':
            fxChargeParticles.ColorStart.Base.R = 255; fxChargeParticles.ColorStart.Base.G = 237; fxChargeParticles.ColorStart.Base.B = 15;  fxChargeParticles.ColorStart.Base.A = 0;
            fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 191; fxChargeParticles.ColorEnd.Base.B = 60;  fxChargeParticles.ColorEnd.Base.A = 0;
            return;
        default:
            break;
    }
    return;
}

function GetLightColor (Class<baseSpell> spellClass)
{
    switch (spellClass)
    {
        case Class'spellFlipendo':
            LightBrightness = 100;
            LightHue = 24;
            LightSaturation = 0;
            return;
        case Class'spellLumos':
            LightBrightness = 128;
            LightHue = 42;
            LightSaturation = 0;
            return;
        case Class'spellAlohomora':
            LightBrightness = 128;
            LightHue = 42;
            LightSaturation = 0;
            return;
        case Class'spellSkurge':
            LightBrightness = 128;
            LightHue = 145;
            LightSaturation = 32;
            return;
        case Class'spellRictusempra':
            LightBrightness = 100;
            LightHue = 0;
            LightSaturation = 0;
            return;
        case Class'spellDiffindo':
            LightBrightness = 100;
            LightHue = 80;
            LightSaturation = 0;
            return;
        case Class'spellSpongify':
            LightBrightness = 100;
            LightHue = 192;
            LightSaturation = 50;
            return;
        case Class'spellDuelRictusempra':
            LightBrightness = 100;
            LightHue = 0;
            LightSaturation = 0;
            return;
        case Class'spellDuelMimblewimble':
            LightBrightness = 128;
            LightHue = 145;
            LightSaturation = 32;
            return;
        case Class'spellDuelExpelliarmus':
            LightBrightness = 128;
            LightHue = 42;
            LightSaturation = 0;
            return;
        default:
            break;
    }
    return;
}

defaultproperties
{
    LightBrightness=128
    LightSaturation=255
    bReallyDynamicLight=True
    LightEffect=LE_WateryShimmer
    LightRadius=6
    LightType=LT_None
    fxChargeParticleFXClass=Class'MocaOmniPak.MOCAWandParticles'
}