//=============================================================================
// MOCATimelineTrigger.
//=============================================================================
class MOCATimelineTrigger extends MOCATrigger;

struct TimedEvent
{
	var() name EventName;
	var() name TimeToSendEvent;
};

var() array<TimedEvent> Timeline;
var() bool bDestroyWhenDone;
var() bool bLoopWhenDone;

var int CurrentIndex;


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( IsInState('statePlayTimeline') )
	{
		StopTimeline();
	}

	if ( MOCAHelper.IsEmpty(Timeline) )
	{
		Log(string(Self)$" has no events in its timeline. Destroying!");
		Destroy();
	}

	if ( bLoopWhenDone && bDestroyWhenDone )
	{
		Log(string(Self)$" is set to loop AND destroy which isn't correct, deactivating bDestroyWhenDone.");
		bDestroyWhenDone = False;
	}

	SortEvents();
	GotoState('statePlayTimeline');
}

function SortEvents()
{
	local int i,j;
	local TimedEvent EventToSort;

	for ( i = 0; i < Timeline.Length; i++ )
	{
		for ( j = 0; j < Timeline.Length; j++ )
		{
			if ( Timeline[j].TimeToSendEvent > Timelime[j + 1].TimeToSendEvent )
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
	if ( CurrentIndex > Timeline.Length )
	{
		StopTimeline();
		return;
	}

	if ( Timeline[CurrentIndex].EventName != '' )
	{
		foreach AllActors(class'Actor', TargetActor, Timeline[CurrentIndex].EventName)
		{
			TargetActor.Trigger(Self,Instigator);
		}
	}

	CurrentIndex++;
}

function StopTimeline()
{
	if ( bDestroyWhenDone && ( CurrentIndex >= Timeline.Length ) )
	{
		Destroy();
	}

	if ( bLoopWhenDone && ( CurrentIndex >= Timeline.Length ) )
	{
		CurrentIndex = 0;
		GotoState('statePlayTimeline');
	}
	else
	{
		GotoState(MapDefault.state);
	}
}


/////////////////////
// Helper Functions
/////////////////////	

function float GetWaitTime()
{
	local float StartTime,EndTime;
	StartTime = Timeline[CurrentIndex].TimeToSendEvent;
	EndTime = Timeline[CurrentIndex + 1].TimeToSendEvent;

	if ( CurrentIndex == 0 )
	{
		StartTime = 0.0;
	}

	return Abs(StartTime - EndTime);
}

///////////
// States
///////////

state statePlayTimeline
{
	begin:
		Sleep(WaitTime);
		SendEvent();
		Goto('begin');
}


defaultproperties
{
	bDestroyWhenDone=True
}