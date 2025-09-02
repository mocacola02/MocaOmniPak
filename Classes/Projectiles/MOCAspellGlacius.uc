class MOCAspellGlacius extends MOCAbaseSpell;

defaultproperties
{
    fxFlyParticleEffectClass=Class'MocaOmniPak.Glacius_fly'

    fxHitParticleEffectClass=Class'HPParticle.PixieHit'

	DrawType=DT_None

    SpellWetTexture=WetTexture'MocaTexturePak.Spells.WetGlacius'

    AimParticleTexture=Texture'HPParticle.hp_fx.Particles.Sparkle_5'

    AimParticleStartColor=(R=128,G=128,B=128)

    AimParticleEndColor=(R=30,G=30,B=30)

    AimLightBrightness=128
    AimLightHue=150
    AimLightSaturation=96

    CastSound=Sound'MocaSoundPak.Magic.spell_glacius_cast'
}