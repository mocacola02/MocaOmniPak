//=============================================================================
// MOCATimelineTrigger.
//=============================================================================
class MOCATimelineTrigger extends MOCATrigger;

struct TimedEvent
{
    var() name timedEventName;      //Name of event to trigger
    var() float timeToSendEvent;    //What point in the timeline to trigger it?
};

var() array<TimedEvent> listOfEvents;
var() bool bDestroyWhenDone; // Should the trigger destroy when timeline is done? Def: True
var() bool bLoopWhenDone;    // Should the timeline loop on finish?

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

    if (bLoopWhenDone && bDestroyWhenDone)
    {
        Log("Timeline shouldn't loop AND destroy, deactivating bDestroyWhenDone on: " $ string(self));
        bDestroyWhenDone = false;
    }

    SortEvents();
}

function SortEvents()
{
    local int i, j;
    local TimedEvent temp;

    Log("Timeline index length sanity check before: " $ string(listOfEvents.Length));

    // Bubble sort: compare pairs and swap if out of order
    for (i = 0; i < listOfEvents.Length; i++)
    {
        for (j = 0; j < listOfEvents.Length - 1; j++)
        {
            if (listOfEvents[j].timeToSendEvent > listOfEvents[j + 1].timeToSendEvent)
            {
                // Swap
                temp = listOfEvents[j];
                listOfEvents[j] = listOfEvents[j + 1];
                listOfEvents[j + 1] = temp;
                Log("Reordering " $ string(listOfEvents[j].timedEventName));
            }
        }
    }

    Log("Timeline index length sanity check after: " $ string(listOfEvents.Length));
}


event Activate(Actor Other, Pawn Instigator)
{
    Log("Timeline activating from state: " $ string(GetStateName()));
    if (!IsInState('stateCount'))
    {
        GotoState('stateCount');
    }
    else
    {
        Log("uhh actually nvm (is timeline already running?)");
    }
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
            if (bDestroyWhenDone)
            {
                Destroy();
            }
            
            if (bLoopWhenDone)
            {
                Goto('begin');
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
    bDestroyWhenDone=True
    Texture=Texture'MocaTexturePak.EditorIco.ICO_TimelineTrigger'
}