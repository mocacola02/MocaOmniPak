//================================================================================
// MOCAWand.
//================================================================================
class MOCAWand extends baseWand;

var bool bIsAiming;
var byte TargetLightBrightness, PrevLightBrightness;
var byte TargetLightHue, 		PrevLightHue;
var byte TargetLightSaturation, PrevLightSaturation;
var float BrightnessFadeTime;
var float HueFadeTime;
var float SaturationFadeTime;

//=========
// Events
//=========

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if( bIsAiming )
	{
		ResetWandEffects();

		if( PlayerHarry.SpellCursor.aCurrentTarget != None )
		{
			if( CurrentSpell.IsA('MOCAbaseSpell') )
			{
				SetupMocaWandEffects(class<MOCAbaseSpell>(CurrentSpell));
			}
			else
			{
				SetupStockWandEffects(CurrentSpell);
			}
		}
	}

	HandleLightValues(DeltaTime);
}


//=====================
// Wand FX Setups
//=====================

function StartChargingSpell(bool bChargeSpell, optional bool in_bHarryUsingSword, optional Class<baseSpell> ChargeSpellClass)
{
	Super.StartChargingSpell(bChargeSpell, in_bHarryUsingSword, ChargeSpellClass);
	bIsAiming = True;
}

function StopChargingSpell()
{
	super.StopChargingSpell();
	bIsAiming = False;
	TargetLightBrightness = 0;
}

function HandleLightValues(float DeltaTime)
{
	local float Alpha;

	if( LightBrightness != TargetLightBrightness )
	{
		BrightnessFadeTime += DeltaTime;
		Alpha = BrightnessFadeTime / MapDefault.BrightnessFadeTime;
		Alpha = FClamp(Alpha, 0.0, 1.0);
		
		LightBrightness = byte(Lerp(Alpha, PrevLightBrightness, TargetLightBrightness));
	}
	else
	{
		PrevLightBrightness = LightBrightness;
		BrightnessFadeTime = 0.0;
	}

	if( LightHue != TargetLightHue )
	{
		HueFadeTime += DeltaTime;
		Alpha = HueFadeTime / MapDefault.HueFadeTime;
		Alpha = FClamp(Alpha, 0.0, 1.0);

		LightHue = byte(Lerp(Alpha, PrevLightHue, TargetLightHue));
	}
	else
	{
		PrevLightHue = LightHue;
		HueFadeTime = 0.0;
	}

	if( LightSaturation != TargetLightSaturation )
	{
		SaturationFadeTime += DeltaTime;
		Alpha = SaturationFadeTime / MapDefault.SaturationFadeTime;
		Alpha = FClamp(Alpha, 0.0, 1.0);

		LightSaturation = byte(Lerp(Alpha, PrevLightSaturation, TargetLightSaturation));
	}
	else
	{
		PrevLightSaturation = LightSaturation;
		SaturationFadeTime = 0.0;
	}
}

function SetupMocaWandEffects(class<MOCAbaseSpell> MSpell)
{
	if( MSpell != None )
	{
		fxChargeParticles.Textures[0] = MSpell.Default.AimParticleTexture;

		fxChargeParticles.ColorStart.Base = MSpell.Default.AimParticleStartColor;
		fxChargeParticles.ColorStart.Rand = MSpell.Default.AimParticleStartColor;

		fxChargeParticles.ColorEnd.Base = MSpell.Default.AimParticleEndColor;
		fxChargeParticles.ColorEnd.Rand = MSpell.Default.AimParticleEndColor;

		TargetLightBrightness = MSpell.Default.AimLightBrightness;
		TargetLightHue = MSpell.Default.AimLightHue;
		TargetLightSaturation = MSpell.Default.AimLightSaturation;
	}
}

function SetupStockWandEffects(Class<baseSpell> spellClass)
{
    switch (spellClass)
    {
        case Class'spellFlipendo':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 254;
            fxChargeParticles.ColorStart.Base.G = 142;
            fxChargeParticles.ColorStart.Base.B = 61;

            fxChargeParticles.ColorEnd.Base.R = 201;
            fxChargeParticles.ColorEnd.Base.G = 85;
            fxChargeParticles.ColorEnd.Base.B = 46;

            TargetLightBrightness = 100;
            TargetLightHue = 24;
            TargetLightSaturation = 0;
            return;

        case Class'spellLumos':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 255;
            fxChargeParticles.ColorStart.Base.G = 237;
            fxChargeParticles.ColorStart.Base.B = 15;

            fxChargeParticles.ColorEnd.Base.R = 255;
            fxChargeParticles.ColorEnd.Base.G = 191;
            fxChargeParticles.ColorEnd.Base.B = 60;

            TargetLightBrightness = 128;
            TargetLightHue = 42;
            TargetLightSaturation = 0;
            return;

        case Class'spellAlohomora':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.Key3';

            fxChargeParticles.ColorStart.Base.R = 253;
            fxChargeParticles.ColorStart.Base.G = 152;
            fxChargeParticles.ColorStart.Base.B = 0;

            fxChargeParticles.ColorEnd.Base.R = 255;
            fxChargeParticles.ColorEnd.Base.G = 202;
            fxChargeParticles.ColorEnd.Base.B = 40;

            TargetLightBrightness = 128;
            TargetLightHue = 42;
            TargetLightSaturation = 0;
            return;

        case Class'spellSkurge':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 34;
            fxChargeParticles.ColorStart.Base.G = 67;
            fxChargeParticles.ColorStart.Base.B = 255;

            fxChargeParticles.ColorEnd.Base.R = 113;
            fxChargeParticles.ColorEnd.Base.G = 6;
            fxChargeParticles.ColorEnd.Base.B = 164;

            TargetLightBrightness = 128;
            TargetLightHue = 145;
            TargetLightSaturation = 32;
            return;

        case Class'spellRictusempra':
        case Class'spellDuelRictusempra':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 207;
            fxChargeParticles.ColorStart.Base.G = 46;
            fxChargeParticles.ColorStart.Base.B = 50;

            fxChargeParticles.ColorEnd.Base.R = 255;
            fxChargeParticles.ColorEnd.Base.G = 111;
            fxChargeParticles.ColorEnd.Base.B = 55;

            TargetLightBrightness = 100;
            TargetLightHue = 0;
            TargetLightSaturation = 0;
            return;

        case Class'spellDiffindo':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.Les_Sparkle_03';

            fxChargeParticles.ColorStart.Base.R = 121;
            fxChargeParticles.ColorStart.Base.G = 255;
            fxChargeParticles.ColorStart.Base.B = 11;

            fxChargeParticles.ColorEnd.Base.R = 121;
            fxChargeParticles.ColorEnd.Base.G = 255;
            fxChargeParticles.ColorEnd.Base.B = 11;

            TargetLightBrightness = 100;
            TargetLightHue = 80;
            TargetLightSaturation = 0;
            return;

        case Class'spellSpongify':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 143;
            fxChargeParticles.ColorStart.Base.G = 63;
            fxChargeParticles.ColorStart.Base.B = 192;

            fxChargeParticles.ColorEnd.Base.R = 43;
            fxChargeParticles.ColorEnd.Base.G = 62;
            fxChargeParticles.ColorEnd.Base.B = 138;

            TargetLightBrightness = 100;
            TargetLightHue = 192;
            TargetLightSaturation = 50;
            return;

        case Class'spellDuelMimblewimble':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 34;
            fxChargeParticles.ColorStart.Base.G = 67;
            fxChargeParticles.ColorStart.Base.B = 255;

            fxChargeParticles.ColorEnd.Base.R = 113;
            fxChargeParticles.ColorEnd.Base.G = 6;
            fxChargeParticles.ColorEnd.Base.B = 164;

            TargetLightBrightness = 128;
            TargetLightHue = 145;
            TargetLightSaturation = 32;
            return;

        case Class'spellDuelExpelliarmus':
            fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

            fxChargeParticles.ColorStart.Base.R = 255;
            fxChargeParticles.ColorStart.Base.G = 237;
            fxChargeParticles.ColorStart.Base.B = 15;

            fxChargeParticles.ColorEnd.Base.R = 255;
            fxChargeParticles.ColorEnd.Base.G = 191;
            fxChargeParticles.ColorEnd.Base.B = 60;

            TargetLightBrightness = 128;
            TargetLightHue = 42;
            TargetLightSaturation = 0;
            return;
    }
}

function ResetWandEffects()
{
	fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';

	fxChargeParticles.ColorStart.Base.R = 255;
	fxChargeParticles.ColorStart.Base.G = 255;
	fxChargeParticles.ColorStart.Base.B = 255;
	fxChargeParticles.ColorStart.Base.A = 0;

	fxChargeParticles.ColorEnd.Base.R = 255;
	fxChargeParticles.ColorEnd.Base.G = 255;
	fxChargeParticles.ColorEnd.Base.B = 255;
	fxChargeParticles.ColorEnd.Base.A = 0;

	TargetLightBrightness = 128;
	TargetLightHue = 0;
	TargetLightSaturation = 255;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	BrightnessFadeTime=0.125
	HueFadeTime=0.2
	SaturationFadeTime=0.2

	LightBrightness=128
	LightSaturation=255
	LightHue=0
	bReallyDynamicLight=True
	LightType=LT_Steady
	LightEffect=LE_WateryShimmer
	LightRadius=8

	InventoryGroup=2
}