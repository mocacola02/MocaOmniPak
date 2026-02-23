//================================================================================
// MOCABundimunSpray.
//================================================================================
class MOCABundimunSpray extends HiddenHPawn;

var bool bCooldown;		// Are we cooling down
var float DamageToDeal;	// How much damage to deal


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	local Vector EmitLocation;
	// Set emit location slightly below our location
	EmitLocation = Location;
	EmitLocation.Z -= 16;

	// Spawn mist particles
	Spawn(Class'BundimunMist',Self,,EmitLocation,,True);
}

event Touch(Actor Other)
{
	// If other is Harry and we're not cooling down, hurt Harry and enable cooldown
	if ( Other == PlayerHarry && !bCooldown )
	{
		bCooldown = True;
		Other.TakeDamage(DamageToDeal,Self,Location,Vect(0,0,0),'BundimunSpray');
		PlaySound(Sound'spell_hit',SLOT_Interact);
		SetTimer(1.0);
	}
}

event Timer()
{
	// Reset cooldown
	bCooldown = False;
}


defaultproperties
{
	LifeSpan=3.0
	TransientRadius=2048
}