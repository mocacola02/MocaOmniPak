//=============================================================================
// MOCAMusicComposer
//=============================================================================
class MOCAMusicComposer extends MOCAMusicActors;

struct DynamicTrack
{
	var() string Track;
	var() string NextTrack;
	var() float CheckInterval;
	var() float CrossfadeDuration;
};

var() array<DynamicTrack> ListOfTracks;


var bool bReadyToProgress;

var int PreviousTrack;
var int CurrentTrack;
var int CurrentHandle;
var int TrackOverride;	// Moca: Set by MOCAComposerTrigger


///////////
// Events
///////////

event MusicTrackEnded();
event MusicTrackLooped();


///////////////////
// Main Functions
///////////////////

function BeginComposing(optional int IdxOverride)
{
	if ( IsValidIndex(IdxOverride) )
	{
		CurrentTrack = IdxOverride;
	}

	PlayNewTrack();
	GotoState('stateCounting');
}

function StopComposing(float FadeTime)
{
	StopMusic(CurrentHandle,FadeTime);
	CurrentHandle = 0;
	GotoState('stateIdle');
}

function PlayNewTrack()
{
	local float FadeTime;
	local string NewTrack;

	NewTrack = ListOfTracks[CurrentTrack].Track;
	FadeTime = ListOfTracks[CurrentTrack].CrossfadeDuration;

	StopMusic(CurrentHandle,FadeTime);

	CurrentHandle = PlayMusic(NewTrack,FadeTime);
}

function ProgressTrack(optional int IdxOverride)
{
	local string TargetTrack;

	PreviousTrack = CurrentTrack;

	if ( IsValidIndex(IdxOverride) )
	{
		TargetTrack = ListOfTracks[IdxOverride].Track;
	}
	else
	{
		TargetTrack = ListOfTracks[IdxOverride].NextTrack;
	}

	CurrentTrack = GetTrackIndex(TargetTrack);
	PlayNewTrack();
}


/////////////////////
// Helper Functions
/////////////////////

function bool IsValidIndex(int Idx)
{
	return Idx >= 0 && Idx <= TrackList.Length;
}

function int GetTrackIndex(string TrackName)
{
	local int i;

	for ( i = 0; i < ListOfTracks.Length; i++ )
	{
		if ( ListOfTracks[i].Track == TrackName )
		{
			return i;
		}
	}

	Log(string(Self)$" could not find next track "$TrackName);
	return 0;
}


///////////
// States
///////////

state stateCounting
{
	event BeginState()
	{
		local float TimerInterval;
		
		TimerInterval = FClamp(ListOfTracks[CurrentTrack].CheckInterval,0.0,99999.0);

		if ( TimerInterval <= 0.0 )
		{
			local string NewTrackFile;
			NewTrackFile = ListOfTracks[CurrentTrack].Track$".ogg";

			TimerInterval = GetMusicLength(NewTrackFile);

			bReadyToProgress = True;
		}

		SetTimer(TimerInterval,True);
	}

	event Timer()
	{
		if ( bReadyToProgress )
		{
			bReadyToProgress = False;

			ProgressTrack(TrackOverride);
			TrackOverride = MapDefault.TrackOverride;

			GotoState('stateIdle');
		}
	}
}


defaultproperties
{
	TrackOverride=-1
}