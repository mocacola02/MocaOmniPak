//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() float TimeOutDuration;	// Moca: How long to deactivate trigger after activation. Def: 4.0


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If not in timeout and harry isn't already caught and harry is a MOCAharry
	if ( !IsInState('stateTimeout') && !PlayerHarry.IsInState('stateCaught') && PlayerHarry.IsA('MOCAharry') )
	{
		MOCAharry(PlayerHarry).GetCaught(Self,Event);

		if ( Owner.IsA('MOCAWatcher') && MOCAWatcher(Owner).CanCatchHarry() )
		{
			Owner.GotoState('stateCatch');
		}
		else
		{
			GotoState('stateTimeout');
		}
	}
	// If Harry isn't MOCAharry, push error
	else if ( !PlayerHarry.IsA('MOCAharry') )
	{
		PushError("MOCAStealthTrigger requires MOCAharry! Please replace harry with MOCAharry.");
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