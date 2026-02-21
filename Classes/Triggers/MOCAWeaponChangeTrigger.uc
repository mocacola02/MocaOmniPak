//================================================================================
// MOCAWeaponChangeTrigger.
//================================================================================

class MOCAWeaponChangeTrigger extends MOCATrigger;

var() bool bForceChangeWeapon;
var() class<Weapon> WeaponToSet; // Change the type to class<Actor>


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( PlayerHarry.IsA('MOCAharry') )
	{
		MOCAharry(PlayerHarry).SetWeaponByClass(WeaponToSet,bForceChangeWeapon);
	}
	else
	{
		MOCAHelpers.PushError("MOCAWeaponChangeTrigger requires MOCAharry! Please replace harry with MOCAharry.");
	}
}


defaultproperties
{
	bForceChangeWeapon=True
	WeaponToSet=class'MOCAWand'
}