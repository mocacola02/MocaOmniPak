class MOCAbaseSpell extends baseSpell;

var byte AimLightBrightness;
var byte AimLightHue;
var byte AimLightSaturation;

var Color AimParticleStartColor;
var Color AimParticleEndColor;

var Texture AimParticleTexture;
var WetTexture SpellWetTexture;

var MOCAharry MocaPlayer;

var ESpellType SpellToActAs;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	MocaPlayer = MOCAharry(PlayerHarry);
	SpellToActAs = MocaPlayer.DetermineSpellType(Self.Class);
}


///////////////////
// Main Functions
///////////////////

function bool OnSpellHitHPawn(Actor HitActor, Vector HitLocation)
{
	if ( HitActor.IsA('MOCAPawn') )
	{
		return MOCAPawn(HitActor).HandleSpell(Self,HitLocation);
	}
	else if ( HitActor.IsA('MOCAChar') )
	{
		return MOCAChar(HitActor).HandleSpell(Self,HitLocation);
	}
	else
	{
		switch (SpellToActAs)
		{
			case SPELL_None:			return False;
			case SPELL_Flipendo:		return HPawn(aHit).HandleSpellFlipendo(Self,HitLocation);
			case SPELL_Lumos:			return HPawn(aHit).HandleSpellLumos(Self,HitLocation);
			case SPELL_Alohomora:		return HPawn(aHit).HandleSpellAlohomora(Self,HitLocation);
			case SPELL_Skurge:			return HPawn(aHit).HandleSpellSkurge(Self,HitLocation);
			case SPELL_Rictusempra:		return HPawn(aHit).HandleSpellRictusempra(Self,HitLocation);
			case SPELL_Diffindo:		return HPawn(aHit).HandleSpellDiffindo(Self,HitLocation);
			case SPELL_Spongify:		return HPawn(aHit).HandleSpellSpongify(Self,HitLocation);
			default:					return HPawn(aHit).HandleSpellFlipendo(Self,HitLocation);
		}
	}
}


///////////
// States
///////////

auto state StateFlying
{
	event Tick(float DeltaTime)
	{
		Super.Tick(DeltaTime);
		UpdateRotationWithSeeking(DeltaTime);

		if ( fxFlyParticleEffect != None )
		{
			fxFlyParticleEffect.SetLocation(Location);
		}
	}

	begin:
		Velocity = Vect(Rotation) * Speed;
}