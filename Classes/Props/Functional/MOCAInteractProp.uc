//================================================================================
// MOCAInteractProp.
//================================================================================

class MOCAInteractProp extends HProp;

var() bool bDestroyAfterInteract;
var() int Lives;
var() float CooldownDuration;


function InteractTraceHit()
{
	if ( !CanInteract() || IsInState('stateCooldown') )
	{
		return;
	}

	if ( Event != '' )
	{
		TriggerEvent(Event,Self,PlayerHarry);
	}

	StartCooldown();
	ProcessInteract();
}

function ProcessInteract();

function StartCooldown()
{
	if ( bDestroyAfterInteract && !CanInteract() )
	{
		Destroy();
	}

	CurrentCooldown = CooldownDuration;
	GotoState('stateCooldown');
}

function bool CanInteract()
{
	return Lives > 0;
}

auto state stateIdle
{
}

state stateCooldown
{
	begin:
		Sleep(CurrentCooldown);
		GotoState('stateIdle');
}


defaultproperties
{
	bDestroyAfterInteract=True
	Lives=1
	CooldownDuration=1.0
}