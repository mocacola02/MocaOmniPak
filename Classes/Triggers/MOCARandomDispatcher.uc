//=============================================================================
// MOCARandomDispatcher.
//=============================================================================
class MOCARandomDispatcher extends Triggers;

//-----------------------------------------------------------------------------
// Dispatcher variables.

var() Array<name>  OutEvents; // Events to select from.
var() Array<float> OutDelays; // Relative delays before generating events.
var() bool bDispatchAllAtOnce; //Moca: Should it randomly dispatch all events after a single trigger?
var() bool bEventsFireOnce; //Moca: Should it be able to trigger events multiple times?
var int i;                // Internal counter.

function Trigger( actor Other, pawn EventInstigator )
{
	Activate(Other,EventInstigator);
}

event Activate( actor Other, pawn EventInstigator )
{
	Log("MRD TRIGGERED!!!!!!!!!!!!");
	if (!IsInState('Dispatch'))
	{
		Log("Starting dispatch...");
		Instigator = EventInstigator;
		if (bDispatchAllAtOnce)
		{
			gotostate('Dispatch', 'loop');
		}
		else
		{
			gotostate('Dispatch', 'fire');
		}
	}
	else
	{
		Log("pausing dispatch");
		gotostate('');
	}
}

function RemoveEventFromList()
{
	OutEvents.Remove(i,1);
	OutDelays.Remove(i,1);
}

state Dispatch
{
	fire:
		Log("TRIGGERED - Fire.");
		disable('Trigger');
		i = Rand(OutEvents.Length);
		if( OutEvents[i] != '' )
		{
			Sleep( OutDelays[i] );
			foreach AllActors( class 'Actor', Target, OutEvents[i] )
			{
				Log("Triggering:  " @ string(Target));
				Target.Trigger( Self, Instigator );
			}
				
		}
		if (bEventsFireOnce)
		{
			RemoveEventFromList();
		}
		if (OutEvents.Length <= 0)
		{
			Destroy();
		}
		enable('Trigger');
		gotostate('');

	loop:
		Log("TRIGGERED - Loop.");
		while (OutEvents.Length > 0)
		{
			i = Rand(OutEvents.Length);
			if( OutEvents[i] != '' )
			{
				Sleep( OutDelays[i] );
				foreach AllActors( class 'Actor', Target, OutEvents[i] )
					Target.Trigger( Self, Instigator );
			}
			if (bEventsFireOnce)
			{
				RemoveEventFromList();
			}
		}
		Destroy();
}

defaultproperties
{
     bEventsFireOnce=True
     Texture=Texture'MocaTexturePak.EditorIco.ICO_RandomDispatcher'
}
