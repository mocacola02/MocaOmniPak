class MOCAbaseSpell extends baseSpell;

var WetTexture SpellWetTexture; // What wet texture to use when aiming over a compatible actor?
var byte AimLightBrightness;    // What brightness to use for the wand light when selecting a compatible actor?
var byte AimLightHue;   // What hue to use for the wand light when selecting a compatible actor?
var byte AimLightSaturation;    // What saturation to use for the wand light when selecting a compatible actor?
var Color AimParticleStartColor; // What color to use for the wand particle when selecting a compatible actor?
var Color AimParticleEndColor;
var Texture AimParticleTexture; // What particle texture to use for the wand particle when selecting a compatible actor?
var MOCAharry MocaPlayerHarry;

var ESpellType SpellToActAsRef;


function bool OnSpellHitHPawn (Actor aHit, Vector vHitLocation)
{
	Log("Hit HPawn");
	switch (SpellToActAsRef)
	{
		case SPELL_None:			return false;
		case SPELL_Flipendo:		return HPawn(aHit).HandleSpellFlipendo(self,vHitLocation);
		case SPELL_Lumos:			return HPawn(aHit).HandleSpellLumos(self,vHitLocation);
		case SPELL_Alohomora:		return HPawn(aHit).HandleSpellAlohomora(self,vHitLocation);
		case SPELL_Skurge:			return HPawn(aHit).HandleSpellSkurge(self,vHitLocation);
		case SPELL_Rictusempra:		return HPawn(aHit).HandleSpellRictusempra(self,vHitLocation);
		case SPELL_Diffindo:		return HPawn(aHit).HandleSpellDiffindo(self,vHitLocation);
		case SPELL_Spongify:		return HPawn(aHit).HandleSpellSpongify(self,vHitLocation);
		default:					return HPawn(aHit).HandleSpellFlipendo(self,vHitLocation);
	}
}

auto state stateIdle
{
begin:
	MocaPlayerHarry = MOCAharry(PlayerHarry);

	SpellToActAsRef = MocaPlayerHarry.DetermineSpellToActAs(self.Class);

	SpellType = MocaPlayerHarry.DetermineSpellType(self.Class);
	
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