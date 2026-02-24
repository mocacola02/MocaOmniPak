class MOCAComposerTrigger extends MOCATrigger;

enum ComposerCommand
{
	CC_Start,				// Moca: Starts playing
	CC_Queue,				// Moca: On the next timer interval, play the next track
	CC_Continue,			// Moca: Play the next track right now
	CC_Continuous,			// Moca: Continuously play music in the order of the track list
	CC_ContinuousRandom,	// Moca: Continuously play music in random order
	CC_Stop					// Moca: Stop playing
};

var() ComposerCommand CommandToSend;	// Moca: What command to send to the composer? Def: CC_Start

var() int TrackOverride;				// Moca: Force a specific track to play. -1 means don't override. Def: -1
var() float StopFadeTime;				// Moca: Fade out duration if CC_Stop. Def: 1.0

var MOCAMusicComposer Composer;	// Reference to composer actor


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	local MOCAMusicComposer A;
	
	// For each music composer with the matching event
	foreach AllActors(class'MOCAMusicComposer', A, Event)
	{
		// Send command
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