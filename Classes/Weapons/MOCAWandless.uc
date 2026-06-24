//================================================================================
// MOCAWandless.
//================================================================================
class MOCAWandless extends MOCAWeapon;

var bool bActAsAllSpells;
var float TraceLength;


function AltFire(float Value)
{
	HandleTrace();
}

function HandleTrace()
{
	local Vector TraceStart, TraceEnd, TraceDirection;
	local Vector HitLoc, HitN;
	local Actor HitActor;
	local MOCADebugSprite Sprite1, Sprite2;

	TraceStart = PlayerHarry.Cam.Location;
    TraceDirection = vector(PlayerHarry.Cam.Rotation);
    TraceEnd = TraceStart + TraceDirection * TraceLength;

	if ( bDebugLogging )
	{
		Sprite1 = Spawn(Class'MOCADebugSprite',self,,TraceStart);
		Sprite2 = Spawn(Class'MOCADebugSprite',self,,TraceEnd);

		Sprite1.Setup(2.0);
		Sprite2.Setup(2.0);
	}

	foreach TraceActors(Class'Actor', HitActor, HitLoc, HitN, TraceEnd, TraceStart)
	{
		if ( bActAsAllSpells && HitActor.IsA('HPawn') )
		{
			HPawn(HitActor).CallHandleSpellBySpellType(HPawn(HitActor).eVulnerableToSpell, HitLoc);
		}
		else if ( HitActor.IsA('chestbronze') )
		{
			chestbronze(HitActor).HandleSpellAlohomora();
		}
		else if ( HitActor.IsA('BronzeCauldron') )
		{
			BronzeCauldron(HitActor).HandleSpellFlipendo();
		}
		else if ( HitActor.IsA('MOCAInteractiveProp') )
		{
			MOCAInteractiveProp(HitActor).HandleWandlessInteract();
		}
	}
}


defaultproperties
{
	TraceLength=384.0

	InventoryGroup=1
}