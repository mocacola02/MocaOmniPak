//=============================================================================
// MOCAMusicComposer
//=============================================================================
class MOCAMusicComposer extends MOCAMusicActors;

struct DynamicTrack
{
	var() string Track;
	var() string NextTrack;
	var() int LoopCount;		// Moca: If bContinuousPlay, loop this many times before fading out
	var() float CheckInterval;
	var() float CrossfadeDuration;
};

var() array<DynamicTrack> TrackList;

var bool bReadyToProgress;
var bool bRandomContinuous;

var int PreviousTrack;
var int CurrentTrack;
var int CurrentHandle;
var int CurrentLoop;
var int TrackOverride;	// Moca: Set by MOCAComposerTrigger


///////////
// Events
///////////

event MusicTrackEnded();

event MusicTrackLooped()
{
	LoopCount++;
}


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

function BeginContinuous(optional int IdxOverride, optional bool bRandom)
{
	bRandomContinuous = bRandom;
	
	if ( IsValidIndex(IdxOverride) )
	{
		CurrentTrack = IdxOverride;
	}

	GotoState('stateContinuous');
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

	NewTrack = TrackList[CurrentTrack].Track;
	FadeTime = TrackList[CurrentTrack].CrossfadeDuration;

	StopMusic(CurrentHandle,FadeTime);
	LoopCount = 0;

	CurrentHandle = PlayMusic(NewTrack,FadeTime);
}

function ProgressTrack(optional int IdxOverride)
{
	local string TargetTrack;

	if ( IsValidIndex(IdxOverride) )
	{
		TargetTrack = TrackList[IdxOverride].Track;
	}
	else
	{
		TargetTrack = TrackList[IdxOverride].NextTrack;
	}

	PreviousTrack = CurrentTrack;
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

	for ( i = 0; i < TrackList.Length; i++ )
	{
		if ( TrackList[i].Track == TrackName )
		{
			return i;
		}
	}

	Log(string(Self)$" could not find next track "$TrackName);
	return 0;
}

function int GetRandomTrack()
{
	local int RandIdx;
	RandIdx = Rand(TrackList.Length);

	if ( RandIdx == PreviousTrack )
	{
		RandIdx += 1;
		if ( RandIdx > TrackList.Length )
		{
			RandIdx = 0;
		}
	}

	return RandIdx;
}


///////////
// States
///////////

state stateCounting
{
	event BeginState()
	{
		local float TimerInterval;
		
		TimerInterval = FClamp(TrackList[CurrentTrack].CheckInterval,0.0,99999.0);

		if ( TimerInterval <= 0.0 )
		{
			local string NewTrackFile;
			NewTrackFile = TrackList[CurrentTrack].Track;

			if (!Right(NewTrackFile, 4) ~= ".ogg")
			{
				NewTrackFile = NewTrackFile$".ogg";
			}

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

state stateContinuous
{
	begin:
		PreviousTrack = CurrentTrack;

		if ( bRandomContinuous )
		{
			CurrentTrack = GetRandomTrack();
		}
		else
		{
			CurrentTrack++;
			if ( CurrentTrack > TrackList.Length )
			{
				CurrentTrack = 0;
			}
		}

	loop:
		PlayNewTrack();
		Sleep(GetMusicLength(TrackList[CurrentTrack].Track));

		if ( LoopCount > TrackList[CurrentTrack].LoopCount )
		{
			Goto('begin');
		}
		
		Goto('loop');
}


defaultproperties
{
	TrackOverride=-1
}