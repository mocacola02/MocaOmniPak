//=============================================================================
// MOCARandomDispatcher.
//=============================================================================
class MOCARandomDispatcher extends MOCATrigger;

struct EventDispatch
{
	var() bool bEventFiresOnceOnly;	// Moca: Should this event only fire once
	var() name OutEvent;			// Moca: What event to emit
	var() float OutDelay;			// Moca: Delay before emitting event
};

var() bool bOnceAtATime;				// Moca: Only emit one event per trigger. Def: False
var() bool bResetWhenDone;				// Moca: Should dispatcher reset when done? Def: False
var() array<EventDispatch> ListofEvents;// Moca: List of events to dispatch

var int i;	// Current index


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If not dispatching, dispatch
	if ( !IsInState('stateDispatch') )
	{
		Instigator = EventInstigator;
		GotoState('stateDispatch');
	}
	// Otherwise, stop dispatching and go to initial state
	else
	{
		GotoState(InitialState);
	}
}

state stateDispatch
{
	begin:
		// Get rand index
		i = Rand(ListofEvents.Length);

		// If index has a valid out event
		if ( ListofEvents[i].OutEvent != '' )
		{
			// Delay
			Sleep(ListofEvents[i].OutDelay);
			// Emit event
			TriggerEvent(ListofEvents[i].OutEvent,Self,None);
		}
		// Otherwise, if bEventFiresOnceOnly or out event is empty, remove this index
		else if ( ListOfEvents[i].bEventFiresOnceOnly || ListOfEvents[i].OutEvent == '' )
		{
			ListOfEvents.Remove(i);
		}

		// If list is empty
		if ( ListOfEvents.Length <= 0 )
		{
			// If reset when done, reset list
			if ( bResetWhenDone )
			{
				ListOfEvents = MapDefault.ListOfEvents;
			}
			// Otherwise, destroy self
			else
			{
				Destroy();
			}
		}

		// If once at a time, go back to initial state
		if ( bOnceAtATime )
		{
			GotoState(InitialState);
		}
		// Otherwise loop
		Goto('begin');
}