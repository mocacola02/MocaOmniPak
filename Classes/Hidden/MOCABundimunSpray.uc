//================================================================================
// MOCABundimunSpray.
//================================================================================

class MOCABundimunSpray extends HiddenHPawn;

var bool bCooldown;
var float DamageToDeal;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	local Vector EmitLocation;
	EmitLocation = Location;
	EmitLocation.Z -= 16;

	Spawn(Class'BundimunMist',Self,,EmitLocation,,True);
}

event Touch(Actor Other)
{
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
	bCooldown = False;
}


defaultproperties
{
	LifeSpan=3.0
	TransientRadius=2048
}