//================================================================================
// MOCAbaseSpell.
//================================================================================
class MOCAbaseSpell extends baseSpell;

var byte AimLightBrightness;
var byte AimLightHue;
var byte AimLightSaturation;

var Color AimParticleStartColor;
var Color AimParticleEndColor;

var Texture AimParticleTexture;
var WetTexture SpellWetTexture;


event PostBeginPlay()
{
	super.PostBeginPlay();

	if ( PlayerHarry.IsA('MOCAharry') )
	{
		SpellType = MOCAharry(PlayerHarry).GetSpellToReplicate(self.Class);

		if ( SpellType == SPELL_None )
		{
			SpellType = MOCAharry(PlayerHarry).GetSpellType(self.Class);
		}
	}

	GotoState('StateFlying');
}

///////////////////
// Main Functions
///////////////////

function bool OnSpellHitHPawn(Actor HitActor, Vector HitLocation)
{
	local bool bResult;
	// If MOCAPawn or MOCAChar, HandleSpell
	if ( HitActor.IsA('MOCAPawn') )
	{
		return MOCAPawn(HitActor).HandleSpell(Self,HitLocation);
	}
	else if ( HitActor.IsA('MOCAChar') )
	{
		return MOCAChar(HitActor).HandleSpell(Self,HitLocation);
	}
	// Otherwise, use stock behavior
	else
	{
		switch (SpellType)
		{
				case SPELL_Rictusempra:
					return HPawn(HitActor).HandleSpellRictusempra(None,HitLocation);
				case SPELL_Alohomora:
					return HPawn(HitActor).HandleSpellAlohomora(None,HitLocation);
				case SPELL_Diffindo:
					return HPawn(HitActor).HandleSpellDiffindo(None,HitLocation);
				case SPELL_Ecto:
					return HPawn(HitActor).HandleSpellEcto(None,HitLocation);
				case SPELL_Flipendo:
					return HPawn(HitActor).HandleSpellFlipendo(None,HitLocation);
				case SPELL_Lumos:
					return HPawn(HitActor).HandleSpellLumos(None,HitLocation);
				case SPELL_Rictusempra:
					return HPawn(HitActor).HandleSpellRictusempra(None,HitLocation);
				case SPELL_Skurge:
					return HPawn(HitActor).HandleSpellSkurge(None,HitLocation);
				case SPELL_Spongify:
					return HPawn(HitActor).HandleSpellSpongify(None,HitLocation);
			}
	}

	return False;
}


///////////
// States
///////////

auto state StateFlying
{
	event Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);
		// Update rotation
		UpdateRotationWithSeeking(DeltaTime);

		// Move particle effect
		if ( fxFlyParticleEffect != None )
		{
			fxFlyParticleEffect.SetLocation(Location);
		}
	}

	begin:
		// Set velocity
		Velocity = Vector(Rotation) * Speed;
}