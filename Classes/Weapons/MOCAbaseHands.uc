//================================================================================
// MOCAbaseHands.
//================================================================================

class MOCAbaseHands extends HWeapon;

var MOCAharry MocaPlayer;	// Player ref


event PostBeginPlay()
{
	// Set player ref
	MocaPlayer = MOCAharry(Owner);
}

function AltFire( float Value )
{
	local Vector TraceStart,TraceEnd;
	local MOCAInteractProp HitProp;
	// Start trace at BaseCam location
	TraceStart = MocaPlayer.Cam.Location;
	// End trace 256.0 units in front of TraceEnd
	TraceEnd = TraceStart + Vector(MocaPlayer.Cam.Rotation) * 256.0;
	// Trace for MOCAInteractProp
	HitProp = TraceForInteractable(TraceStart,TraceEnd);
	Log("Interact trace found "$string(HitProp));
}

function MOCAInteractProp TraceForInteractable(Vector TraceStart, Vector TraceEnd, optional Vector TraceExtent)
{
	local Vector HitLocation,HitNormal;
	local MOCAInteractProp HitProp;

	// Trace for MOCAInteractProp
	foreach TraceActors(Class'MOCAInteractProp',HitProp,HitLocation,HitNormal,TraceEnd,TraceStart,TraceExtent)
	{
		// End trace if we find one
		break;
	}

	// If we have a HitProp, set up interaction
	if ( HitProp != None )
	{
		HitProp.InteractTraceHit();
		MocaPlayer.GotoState('stateInteract');
	}
	// Return hit prop
	return HitProp;
}

defaultproperties
{
	InventoryGroup=1
}