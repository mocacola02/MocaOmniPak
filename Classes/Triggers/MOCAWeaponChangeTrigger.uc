//================================================================================
// MOCAWeaponChangeTrigger.
//================================================================================

class MOCAWeaponChangeTrigger extends Trigger;

var MOCAharry PlayerHarry;
var() class<Weapon> WeaponToSpawn; // Change the type to class<Actor>
var bool inactive;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	PlayerHarry = MOCAharry(Level.PlayerHarryActor);
}

function Activate ( actor Other, pawn Instigator ) {
    if (!inactive)
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
        PlayerHarry.CurrentWeapon = 0;
    }
    else {
        PlayerHarry.CurrentWeapon = 1;
    }
    GotoState('Cooldown');
}

auto state On {
    begin:
        inactive = False;
}

state Cooldown {
    begin:
        inactive = True;
        //sleep(3.0);
        //GotoState('On');
        //Causes issues and i dont really need it to reactivate so............ poor coding it is :)
}

defaultproperties {
    WeaponToSpawn=class'HGame.baseWand'
}