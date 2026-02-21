//=============================================================================
// MOCARandomDispatcher.
//=============================================================================
class MOCARandomDispatcher extends MOCATrigger;

struct EventDispatch
{
	var() bool bEventFiresOnceOnly;
	var() name OutEvent;
	var() float OutDelay;
};

var() bool bOnceAtATime;
var() bool bResetIfEmptied;
var() array<EventDispatch> ListofEvents;

var int i;


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( !IsInState('stateDispatch') )
	{
		Instigator = EventInstigator;
		GotoState('stateDispatch');
	}
	else
	{
		GotoState(LastValidState);
	}
}

state stateDispatch
{
	begin:
		i = Rand(ListofEvents.Length);

		if ( ListofEvents[i].OutEvent != '' )
		{
			Sleep(ListofEvents[i].OutDelay);
			
			foreach AllActors(class'Actor',TargetActor,ListofEvents[i].OutEvent)
			{
				TargetActor.Trigger(Self,Instigator);
			}
		}
		else if ( ListOfEvents[i].bEventFiresOnceOnly || ListOfEvents[i].OutEvent == '' )
		{
			ListOfEvents.RemoveItem(i);
		}

		if ( MOCAHelpers.IsEmpty(ListOfEvents) )
		{
			if ( bResetIfEmptied )
			{
				ListOfEvents = MapDefault.ListOfEvents;
			}
			else
			{
				Destroy();
			}
		}

		if ( bOnceAtATime )
		{
			GotoState(LastValidState);
		}

		Goto('begin');
}