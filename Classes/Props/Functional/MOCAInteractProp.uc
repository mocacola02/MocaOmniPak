//================================================================================
// MOCAInteractProp.
//================================================================================

class MOCAInteractProp extends HProp;

var() bool bDestroyAfterInteract;	// Moca: Should the prop destroy itself after interact? Useful for interact triggers. Def: False
var() int Lives;					// Moca: How many lives does the interactable have? Def: 1
var() float CooldownDuration;		// Moca: Cooldown between interacts. Def: 1.0


function InteractTraceHit()
{
	// If we can't interact or we're cooling down, return
	if ( !CanInteract() || IsInState('stateCooldown') )
	{
		return;
	}

	// If we have an event, emit it
	if ( Event != '' )
	{
		TriggerEvent(Event,Self,PlayerHarry);
	}

	// Start cooldown
	StartCooldown();
	// Do interact action
	ProcessInteract();
}

function ProcessInteract();	// Define in child classes

function StartCooldown()
{
	// If destroy after interact and we're out of lives
	if ( bDestroyAfterInteract && !CanInteract() )
	{
		// Destroy self
		Destroy();
	}
	// Start cooldown
	GotoState('stateCooldown');
}

function bool CanInteract()
{
	// Return true if we still have lives
	return Lives > 0;
}

auto state stateIdle
{
}

state stateCooldown
{
	begin:
		// Wait for cooldown, then go back to idle
		Sleep(CooldownDuration);
		GotoState('stateIdle');
}


defaultproperties
{
	Lives=1
	CooldownDuration=1.0
}