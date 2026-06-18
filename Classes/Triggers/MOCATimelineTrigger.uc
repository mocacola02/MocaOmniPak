//=============================================================================
// MOCATimelineTrigger.
//=============================================================================
class MOCATimelineTrigger extends MOCATrigger;

struct TimedEvent
{
	var() name EventName;		// Moca: Event to emit.
	var() float TimeToSendEvent;// Moca: When to send event.
};

var() array<TimedEvent> Timeline;	// Moca: List of events to play on timeline.
var() bool bDestroyWhenDone;		// Moca: Should the trigger destroy when timeline ends? Def: True
var() bool bLoopWhenDone;			// Moca: Should the trigger loop when done? Def: False

var int CurrentIndex;	// Current event index


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If we're playing timeline, stop it
	if ( IsInState('statePlayTimeline') )
	{
		StopTimeline();
	}

	// If timeline is empty, destroy self
	if ( Timeline.Length <= 0 )
	{
		Log(string(Self)$" has no events in its timeline. Destroying!");
		Destroy();
		return;
	}

	// If set to loop and destroy, disable destroy
	if ( bLoopWhenDone && bDestroyWhenDone )
	{
		Log(string(Self)$" is set to loop AND destroy which isn't correct, deactivating bDestroyWhenDone.");
		bDestroyWhenDone = False;
	}

	// Sort events in chronological order
	SortEvents();
	// Play timeline
	GotoState('statePlayTimeline');
}

function SortEvents()
{
	local int i,j;
	local TimedEvent EventToSort;

	// For each item in the timeline
	for ( i = 0; i < Timeline.Length; i++ )
	{
		// Search through each item again
		for ( j = 0; j < Timeline.Length - 1; j++ )
		{
			if ( Timeline[j].TimeToSendEvent > Timeline[j + 1].TimeToSendEvent )
			{
				EventToSort = Timeline[j];
				Timeline[j] = Timeline[j + 1];
				Timeline[j + 1] = EventToSort;
			}
		}
	}
}

function SendEvent()
{
	// If finished list, stop timeline
	if ( CurrentIndex > Timeline.Length )
	{
		StopTimeline();
		return;
	}
	// Emit event
	TriggerEvent(Timeline[CurrentIndex].EventName,Self,None);
	// Increment index
	CurrentIndex++;
}

function StopTimeline()
{
	// If destroy when done and we're out of indices, destroy self
	if ( bDestroyWhenDone && ( CurrentIndex >= Timeline.Length ) )
	{
		Destroy();
		return;
	}

	// If loop when done and we're out of indices, reset index and replay
	if ( bLoopWhenDone && ( CurrentIndex >= Timeline.Length ) )
	{
		CurrentIndex = 0;
		GotoState('statePlayTimeline');
	}
	// Otherwise, go back to initial state
	else
	{
		GotoState(InitialState);
	}
}


/////////////////////
// Helper Functions
/////////////////////	

function float GetWaitTime()
{
    local float StartTime, EndTime;

    // Time of the event we're about to send
    EndTime = Timeline[CurrentIndex].TimeToSendEvent;

    // Time of the previous event (0.0 if this is the first one)
    if ( CurrentIndex == 0 )
    {
        StartTime = 0.0;
    }
    else
    {
        StartTime = Timeline[CurrentIndex - 1].TimeToSendEvent;
    }

    return Abs(EndTime - StartTime);
}

///////////
// States
///////////

state statePlayTimeline
{
	begin:
		if( GetWaitTime() > 0.0 )
		{
			// Sleep for wait time
			Sleep(GetWaitTime());
		}
		else
		{
			SleepForTick();
		}

		// Send event
		SendEvent();
		// Loop
		Goto('begin');
}


defaultproperties
{
	bDestroyWhenDone=True
	ReTriggerDelay=1.0
}