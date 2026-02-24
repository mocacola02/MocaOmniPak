//================================================================================
// MOCAWeaponChangeTrigger.
//================================================================================

class MOCAWeaponChangeTrigger extends MOCATrigger;

var() bool bForceChangeWeapon;	// Moca: Force the weapon change, even if Harry doesn't have it yet. Def: True
var() class<Weapon> WeaponToSet;// Moca: Which weapon class to switch to. Def: class'MOCAWand'


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If Harry is MOCAharry
	if ( PlayerHarry.IsA('MOCAharry') )
	{
		// Set weapon
		MOCAharry(PlayerHarry).SetWeaponByClass(WeaponToSet,bForceChangeWeapon);
	}
	// Otherwise, push error
	else
	{
		PushError("MOCAWeaponChangeTrigger requires MOCAharry! Please replace harry with MOCAharry.");
	}
}


defaultproperties
{
	bForceChangeWeapon=True
	WeaponToSet=class'MOCAWand'
}