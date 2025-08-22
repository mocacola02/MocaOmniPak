//=============================================================================
// MOCATimelineTrigger.
//=============================================================================
class MOCATimelineTrigger extends Triggers;

struct TimedEvent
{
    var() name timedEventName;      //Name of event to trigger
    var() float timeToSendEvent;    //What point in the timeline to trigger it?
};

var() array<TimedEvent> listOfEvents;
var() bool destroyWhenDone; // Should the trigger destroy when timeline is done? Def: True

var float waitTime;

var int currIndex;
var int nextIndex;

event PostBeginPlay()
{
    super.PostBeginPlay();
    if (listOfEvents.Length <= 0)
    {
        Log("No events set, destroying: " $ string(self));
        Destroy();
    }
}


function Trigger(Actor Other, Pawn Instigator)
{
    if (IsInState('stateDormant'))
    {
        GotoState('stateCount');
    }
}

auto state stateDormant
{
}

state stateCount
{
    function sendEvent()
    {
        local name currEvent;
        currIndex = nextIndex;
        nextIndex++;

        currEvent = listOfEvents[currIndex].timedEventName;

        if( currEvent != '' )
		{
            Log("Broadcasting event: " $ string(currEvent));
			foreach AllActors( class 'Actor', Target, currEvent )
				Target.Trigger( Self, Instigator );
		}
    }

    begin:
        if (nextIndex > listOfEvents.Length)
        {
            Log("Finished timeline");
            currIndex = 0;
            nextIndex = 0;
            if (destroyWhenDone)
            {
                Destroy();
            }
            
            GotoState('stateDormant');
        }

        waitTime = Abs(listOfEvents[currIndex].timeToSendEvent - listOfEvents[nextIndex].timeToSendEvent);
        sleep(waitTime);
        sendEvent();
        Goto('begin');
}

defaultproperties
{
    destroyWhenDone=True
    Texture=Texture'MocaTexturePak.EditorIco.ICO_TimelineTrigger'
}