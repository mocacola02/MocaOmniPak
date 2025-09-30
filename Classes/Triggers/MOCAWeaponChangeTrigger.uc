//================================================================================
// MOCAWeaponChangeTrigger.
//================================================================================

class MOCAWeaponChangeTrigger extends MOCATrigger;

var() class<Weapon> WeaponToSpawn; // Change the type to class<Actor>
var bool bInactive;

function PreBeginPlay()
{
    Super.PreBeginPlay();

    if (!PlayerHarry.IsA('MOCAharry'))
    {
        Log("MOCAWEAPONCHANGETRIGGER REQUIRES MOCAHARRY!!!!!");
        Destroy();
    }
}

function Activate ( actor Other, pawn Instigator ) {
    if (!bInactive)
    {
        ProcessTrigger();
    }
}

function ProcessTrigger()
{
    local Weapon weap;

    weap = Spawn(WeaponToSpawn, self); // Cast the spawned actor to Weapon
    PlayerHarry.AddInventory(weap); // Add the weapon to the player's inventory
    weap.WeaponSet(PlayerHarry); // Set the weapon       
    weap.GiveAmmo(PlayerHarry); // Give ammo to the weapon if needed
    PlayerHarry.SwitchWeapon(1);
    log(string(self) $ " spawning weap " $ string(weap)); // Log the spawning of the weapon
    if (WeaponToSpawn == class'HGame.MOCAbaseHands') {
        MOCAharry(PlayerHarry).CurrentWeapon = 0;
    }
    else {
        MOCAharry(PlayerHarry).CurrentWeapon = 1;
    }
    GotoState('Cooldown');
}

defaultproperties {
    WeaponToSpawn=class'MocaOmniPak.MOCAWand'
}