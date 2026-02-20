class MOCAComposerTrigger extends MOCATrigger;

enum ComposerCommand
{
	CC_Start,
	CC_Queue,
	CC_Continue,
	CC_Continuous,
	CC_ContinuousRandom,
	CC_Stop
};

var() ComposerCommand CommandToSend;

var() int TrackOverride;
var() float StopFadeTime;

var MOCAMusicComposer Composer;


event Activate(Actor Other, Pawn Instigator)
{
	ProcessTrigger();
}

function ProcessTrigger()
{
	local MOCAMusicComposer A;
	
	foreach AllActors(class'MOCAMusicComposer', A, Event)
	{
		switch (CommandToSend)
		{
			case CC_Start: A.BeginComposing(TrackOverride); break;
			case CC_Queue: A.bReadyToProgress = True; break;
			case CC_Continue: A.ProgressTrack(TrackOverride); break;
			case CC_Continuous: A.BeginContinuous(TrackOverride); break;
			case CC_ContinuousRandom: A.BeginContinuous(TrackOverride,True); break;
			default: A.StopComposing(StopFadeTime); break;
		}
	}
}


defaultproperties
{
	TrackOverride=-1
	StopFadeTime=1.0
	bTriggerOnceOnly=True
}