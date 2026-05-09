//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() float TimeOutDuration;	// Moca: How long to deactivate trigger after activation. Def: 4.0

var name HarryCaughtState;

///////////////////
// Main Functions
///////////////////


event PostBeginPlay()
{
	if ( !PlayerHarry.IsA('MOCAharry') && HarryCaughtState == '' )
	{
		PushError("MOCAStealthTrigger requires MOCAharry or a defined HarryCaughtState if using a custom Harry.");
	}

	if ( PlayerHarry.IsA('MOCAharry') )
	{
		HarryCaughtState = 'stateCaught';
	}
}


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If not in timeout and harry isn't already caught
	if ( !IsInState('stateTimeout') && !PlayerHarry.IsInState(HarryCaughtState) )
	{
		if ( PlayerHarry.IsA('MOCAharry') )
		{
			MOCAharry(PlayerHarry).GetCaught(Self,Event);
		}
		else
		{
			PlayerHarry.GotoState(HarryCaughtState);
		}
		

		if ( Owner.IsA('MOCAWatcher') && MOCAWatcher(Owner).CanCatchHarry() )
		{
			Owner.GotoState('stateCatch');
		}
		else
		{
			GotoState('stateTimeout');
		}
	}
}

function Reset()
{
	// If in state timeout, go to initial state
	if ( IsInState('stateTimeout') )
	{
		GotoState(InitialState);
	}
}

state stateTimeout
{
	begin:
		// Sleep for timeout duration, then reset
		Sleep(TimeOutDuration);
		Reset();
}

defaultproperties
{
	TimeOutDuration=4.0

	CollisionHeight=35
	CollisionRadius=42
	CollisionWidth=0
	CollideType=CT_Box
}    