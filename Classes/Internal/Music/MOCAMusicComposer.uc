//=============================================================================
// MOCAMusicComposer
//=============================================================================
class MOCAMusicComposer extends MOCAMusicActors;

struct DynamicTracks
{
	//var() string SongName;				// Moca: Name of track (aka music file name)
	var() string SongName;				// Moca: Name of track (aka music file name)
	//var() string NextSongName;			// Moca: Name of next track
	var() string NextSongName;			// Moca: Name of next track
	var() float CheckRate;			// Moca: How often to check if we should progress (only applicable if using CC_Queue on MOCAComposerTrigger)
	var() float CrossFadeLength;	// Moca: Duration of fade in seconds between current and next track
	var() int LoopCount;			// Moca: If bContinuousPlay, loop this many times before fading out
	//var() float CheckRate;		// Moca: How often to check if we should progress (only applicable if using CC_Queue on MOCAComposerTrigger)
	//var() float CrossFadeLength;	// Moca: Duration of fade in seconds between current and next track	
};

var() array<DynamicTracks> ListOfSongs;	// Moca: List of tracks to play

var bool bReadyToProgress;	// Are we ready to progress
var bool bRandomContinuous;	// Are we doing random continuous playback

var int PrevSongIndex;	// Previous track
var int SongIndex;	// Current track
var int SongHandle;	// Current song handle
var int CurrentLoop;	// Current loop iteration
var int SongOverride;	// Set by MOCAComposerTrigger to override song order


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
		SongIndex = IdxOverride;
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
		SongIndex = IdxOverride;
	}

	// Go to continuous state
	GotoState('stateContinuous');
}

function StopComposing(float FadeTime)
{
	// Stop music
	StopMusic(SongHandle,FadeTime);
	// Reset handle
	SongHandle = 0;
	// Go to idle
	GotoState('stateIdle');
}

function PlayNewTrack()
{
	local float FadeTime;
	local string NewTrack;

	// Set new track to track name of current track (quite the comment)
	NewTrack = ListOfSongs[SongIndex].SongName;
	// Set fade time to crossfade duration of current track
	FadeTime = ListOfSongs[SongIndex].CrossFadeLength;

	// Stop previous song
	StopMusic(SongHandle,FadeTime);
	// Reset loop count
	CurrentLoop = 0;

	// If NewTrack is missing .ogg, add it
	if ( !(Right(NewTrack, 4) ~= ".ogg") )
	{
		NewTrack = NewTrack$".ogg";
	}

	// Play new song and get handle
	SongHandle = PlayMusic(NewTrack,FadeTime);
}

function ProgressTrack(optional int IdxOverride)
{
	local string TargetTrack;

	// If override index is valid, set that as target track
	if ( IsValidIndex(IdxOverride) )
	{
		TargetTrack = ListOfSongs[IdxOverride].SongName;
	}
	// Otherwise, target track is the new track
	else
	{
		TargetTrack = ListOfSongs[IdxOverride].NextSongName;
	}

	// Set previous track to current track
	PrevSongIndex = SongIndex;
	// Set current track to next track
	SongIndex = GetTrackIndex(TargetTrack);
	// Play new track
	PlayNewTrack();
}


/////////////////////
// Helper Functions
/////////////////////

function bool IsValidIndex(int Idx)
{
	// Return if index is 0 or above and if index is within our tracklist length
	return Idx >= 0 && Idx <= ListOfSongs.Length;
}

function int GetTrackIndex(string TrackName)
{
	local int i;

	// For each track in our track list
	for ( i = 0; i < ListOfSongs.Length; i++ )
	{
		// If track equals our desired track name, return i
		if ( ListOfSongs[i].SongName == TrackName )
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
	RandIdx = Rand(ListOfSongs.Length);

	// If random index is our previous track index, get a different valid one
	if ( RandIdx == PrevSongIndex )
	{
		RandIdx += 1;
		if ( RandIdx > ListOfSongs.Length )
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
		TimerInterval = FClamp(ListOfSongs[SongIndex].CheckRate,0.0,99999.0);

		// If no interval, set it to song duration
		if ( TimerInterval <= 0.0 )
		{
			local string NewTrackFile;
			NewTrackFile = ListOfSongs[SongIndex].SongName;

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

			ProgressTrack(SongOverride);
			SongOverride = MapDefault.SongOverride;

			GotoState('stateIdle');
		}
	}
}

state stateContinuous
{
	begin:
		// Store our previous  track
		PrevSongIndex = SongIndex;

		// If random, get random track
		if ( bRandomContinuous )
		{
			SongIndex = GetRandomTrack();
		}
		// Otherwise, increment track index
		else
		{
			SongIndex++;
			if ( SongIndex > ListOfSongs.Length )
			{
				SongIndex = 0;
			}
		}

	loop:
		// Play new track
		PlayNewTrack();
		// Sleep for song duration
		Sleep(GetMusicLength(ListOfSongs[SongIndex].SongName));

		// If done looping, go to begin
		if ( CurrentLoop > ListOfSongs[SongIndex].LoopCount )
		{
			Goto('begin');
		}
		
		// Otherwise, loop
		Goto('loop');
}


defaultproperties
{
	SongOverride=-1
}