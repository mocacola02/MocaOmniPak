//================================================================================
// MOCAWeaponChangeTrigger.
//================================================================================

class MOCAWeaponChangeTrigger extends MOCATrigger;

var() bool bForceChangeWeapon;	// Moca: Force the weapon change, even if Harry doesn't have it yet. Def: True
var() class<Weapon> WeaponToSet;// Moca: Which weapon class to switch to. Def: class'MOCAWand'


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	local Weapon weap;
	
	if ( PlayerHarry.FindInventoryType(WeaponToSet) == None )
	{
		if ( !bForceChangeWeapon )
		{
			Log(self $ ": Harry does not have the desired weapon class. To bypass this, set bForceChangeWeapon to true.");
		}

		weap = Spawn(WeaponToSet, PlayerHarry);
		weap.BecomeItem();
		PlayerHarry.AddInventory(weap);

		weap.WeaponSet(PlayerHarry);
		weap.GiveAmmo(PlayerHarry);

		DebugLog("We didn't have " $ WeaponToSet $ ", so we spawned one: " $ weap);
	}
	else
	{
		DebugLog("We already have a " $ WeaponToSet $ ", so we're not spawning one");
	}

	PlayerHarry.SwitchWeapon(WeaponToSet.Default.InventoryGroup);
	PlayerHarry.ChangedWeapon();
	PlayerHarry.Weapon.GiveAmmo(PlayerHarry);
}


defaultproperties
{
	bForceChangeWeapon=True
	WeaponToSet=class'MOCAWand'
}