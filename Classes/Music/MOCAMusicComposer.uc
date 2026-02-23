//=============================================================================
// MOCAMusicComposer
//=============================================================================
class MOCAMusicComposer extends MOCAMusicActors;

struct DynamicTrack
{
	var() string Track;				// Moca: Name of track (aka music file name)
	var() string NextTrack;			// Moca: Name of next track
	var() int LoopCount;			// Moca: If bContinuousPlay, loop this many times before fading out
	var() float CheckInterval;		// Moca: How often to check if we should progress (only applicable if using CC_Queue on MOCAComposerTrigger)
	var() float CrossfadeDuration;	// Moca: Duration of fade in seconds between current and next track
};

var() array<DynamicTrack> TrackList;	// List of tracks to play

var bool bReadyToProgress;	// Are we ready to progress
var bool bRandomContinuous;	// Are we doing random continuous playback

var int PreviousTrack;	// Previous track
var int CurrentTrack;	// Current track
var int CurrentHandle;	// Current song handle
var int CurrentLoop;	// Current loop iteration
var int TrackOverride;	// Set by MOCAComposerTrigger to override song order


///////////
// Events
///////////

event MusicTrackEnded();

event MusicTrackLooped()
{
	// Increment loop count
	CurrentLoop++;
}


///////////////////
// Main Functions
///////////////////

function BeginComposing(optional int IdxOverride)
{
	// If override index is valid, set that as our current track
	if ( IsValidIndex(IdxOverride) )
	{
		CurrentTrack = IdxOverride;
	}

	// Play first track
	PlayNewTrack();
	GotoState('stateCounting');
}

function BeginContinuous(optional int IdxOverride, optional bool bRandom)
{
	// Set bRandomContinuous to bRandom
	bRandomContinuous = bRandom;
	
	// If override index is valid, set that as current track
	if ( IsValidIndex(IdxOverride) )
	{
		CurrentTrack = IdxOverride;
	}

	// Go to continuous state
	GotoState('stateContinuous');
}

function StopComposing(float FadeTime)
{
	// Stop music
	StopMusic(CurrentHandle,FadeTime);
	// Reset handle
	CurrentHandle = 0;
	// Go to idle
	GotoState('stateIdle');
}

function PlayNewTrack()
{
	local float FadeTime;
	local string NewTrack;

	// Set new track to track name of current track (quite the comment)
	NewTrack = TrackList[CurrentTrack].Track;
	// Set fade time to crossfade duration of current track
	FadeTime = TrackList[CurrentTrack].CrossfadeDuration;

	// Stop previous song
	StopMusic(CurrentHandle,FadeTime);
	// Reset loop count
	CurrentLoop = 0;

	// If NewTrack is missing .ogg, add it
	if ( !Right(NewTrack, 4) ~= ".ogg" )
	{
		NewTrack = NewTrack$".ogg";
	}

	// Play new song and get handle
	CurrentHandle = PlayMusic(NewTrack,FadeTime);
}

function ProgressTrack(optional int IdxOverride)
{
	local string TargetTrack;

	// If override index is valid, set that as target track
	if ( IsValidIndex(IdxOverride) )
	{
		TargetTrack = TrackList[IdxOverride].Track;
	}
	// Otherwise, target track is the new track
	else
	{
		TargetTrack = TrackList[IdxOverride].NextTrack;
	}

	// Set previous track to current track
	PreviousTrack = CurrentTrack;
	// Set current track to next track
	CurrentTrack = GetTrackIndex(TargetTrack);
	// Play new track
	PlayNewTrack();
}


/////////////////////
// Helper Functions
/////////////////////

function bool IsValidIndex(int Idx)
{
	// Return if index is 0 or above and if index is within our tracklist length
	return Idx >= 0 && Idx <= TrackList.Length;
}

function int GetTrackIndex(string TrackName)
{
	local int i;

	// For each track in our track list
	for ( i = 0; i < TrackList.Length; i++ )
	{
		// If track equals our desired track name, return i
		if ( TrackList[i].Track == TrackName )
		{
			return i;
		}
	}

	// Otherwise we couldn't find the track, so return 0
	Log(string(Self)$" could not find next track "$TrackName);
	return 0;
}

function int GetRandomTrack()
{
	// Get random index from track list length
	local int RandIdx;
	RandIdx = Rand(TrackList.Length);

	// If random index is our previous track index, get a different valid one
	if ( RandIdx == PreviousTrack )
	{
		RandIdx += 1;
		if ( RandIdx > TrackList.Length )
		{
			RandIdx = 0;
		}
	}

	// Return final index
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
		
		// Get time interval
		TimerInterval = FClamp(TrackList[CurrentTrack].CheckInterval,0.0,99999.0);

		// If no interval, set it to song duration
		if ( TimerInterval <= 0.0 )
		{
			local string NewTrackFile;
			NewTrackFile = TrackList[CurrentTrack].Track;

			TimerInterval = GetMusicLength(NewTrackFile);

			bReadyToProgress = True;
		}

		// Set timer
		SetTimer(TimerInterval,True);
	}

	event Timer()
	{
		// If ready to progress, progress tracks
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
		// Store our previous  track
		PreviousTrack = CurrentTrack;

		// If random, get random track
		if ( bRandomContinuous )
		{
			CurrentTrack = GetRandomTrack();
		}
		// Otherwise, increment track index
		else
		{
			CurrentTrack++;
			if ( CurrentTrack > TrackList.Length )
			{
				CurrentTrack = 0;
			}
		}

	loop:
		// Play new track
		PlayNewTrack();
		// Sleep for song duration
		Sleep(GetMusicLength(TrackList[CurrentTrack].Track));

		// If done looping, go to begin
		if ( LoopCount > TrackList[CurrentTrack].LoopCount )
		{
			Goto('begin');
		}
		
		// Otherwise, loop
		Goto('loop');
}


defaultproperties
{
	TrackOverride=-1
}