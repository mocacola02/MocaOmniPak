//================================================================================
// MOCAbaseHands.
//================================================================================

class MOCAbaseHands extends HWeapon;


event PostBeginPlay()
{
	MocaPlayer = MOCAharry(Owner);
}

function AltFire( float Value )
{
	local float TraceStart,TraceEnd;
	local MOCAInteractProp HitProp;
	TraceStart = MocaPlayer.Cam.Location;
	TraceEnd = TraceStart + Vect(MocaPlayer.Cam.Rotation) * 256.0;
	HitProp = TraceForInteractable(TraceStart,TraceEnd);

	Log("Interact trace found "$string(HitProp));
}

function Actor TraceForInteractable(Vector TraceStart, Vector TraceEnd, optional Vector TraceExtent)
{
	local Vector HitLocation,HitNormal;
	local MOCAharry MocaPlayer;
	local MOCAInteractProp HitProp;

	MocaPlayer = MOCAharry(Owner);

	foreach TraceActors(Class'MOCAInteractProp',HitProp,HitLocation,HitNormal,TraceEnd,TraceStart,TraceExtent)
	{
		break;
	}

	if ( HitProp != None )
	{
		HitProp.InteractTraceHit();
		MocaPlayer.GotoState('stateInteract');
	}

	return HitProp;
}

defaultproperties
{
	InventoryGroup=1
}