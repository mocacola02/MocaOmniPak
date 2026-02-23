//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() float TimeOutDuration;
var() name EventOnTrigger;


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( !IsInState('stateTimeout') && !PlayerHarry.IsInState('stateCaught') )
	{
		PlayerHarry.GetCaught(Self,EventOnTrigger);

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
	if ( IsInState('stateTimeout') )
	{
		GotoState(LastValidState);
	}
}

state stateTimeout
{
	begin:
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