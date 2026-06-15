//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() float TimeOutDuration;	// Moca: How long to deactivate trigger after activation. Def: 4.0

var name HarryCaughtState;


//=========
// Events
//=========

event PostBeginPlay()
{
	if ( PlayerHarry.IsA('MOCAharry') )
	{
		HarryCaughtState = 'stateCaught';
	}
}


//===================
// Trigger Handling
//===================

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	Log("Stealth trigger processing: " $ Other);
	// If not in timeout and harry isn't already caught
	if ( !IsInState('stateTimeout') && !PlayerHarry.IsInState(HarryCaughtState) )
	{
		if ( PlayerHarry.IsA('MOCAharry') )
		{
			MOCAharry(PlayerHarry).GetCaught(Self,Event);
		}
		else if (HarryCaughtState != '')
		{
			PlayerHarry.GotoState(HarryCaughtState);
		}
		

		if ( Owner.IsA('MOCAWatcher') && MOCAWatcher(Owner).CanCatchHarry() )
		{
			Owner.GotoState('stateCatch');
		}

		GotoState('stateTimeout');
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


//=========
// States
//=========

state stateTimeout
{
	begin:
		// Sleep for timeout duration, then reset
		Sleep(TimeOutDuration);
		Reset();
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	TimeOutDuration=4.0

	CollisionHeight=35
	CollisionRadius=42

	CollideType=CT_Box
}    