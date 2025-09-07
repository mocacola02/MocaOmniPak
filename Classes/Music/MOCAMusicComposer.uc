class MOCAMusicComposer extends MOCAMusicActors;

struct DynamicTracks
{
    var() string SongName; 			//Moca: Name of song to play
    var() string NextSongName;      //Moca: Name of the next song after this one
    var() float CheckRate;          //Moca: Second intervals to check. For example, if set to 4.0, it will mark points every 4th second in the song, and activate when it hits one of those marks. If 0.0, it will wait until the end of the song to switch.
    var() float CrossFadeLength;    //Moca: Amount of fade to use when changing from this track to the next
};

var() array<DynamicTracks> ListOfSongs; //Moca: List of songs.

var bool ReadyToProgress;

var int PrevSongIndex;
var int SongIndex;
var int SongHandle;
var int SongOverride;

// EVENTS
event MusicTrackEnded();
event MusicTrackLooped();

function BeginComposing(optional int Override)
{
	Log(string(self) $ " is starting to compose!");
	if (Override >= 0 && Override <= ListOfSongs.Length)
	{
		SongIndex = Override;
	}
	PlayNewSong();
	GotoState('stateCounting');
}

function StopComposing(float FadeTime)
{
	Log(string(self) $ " is stopping their composition!");
	StopMusic(SongHandle, FadeTime);
	SongHandle = 0;
	GotoState('stateDormant');
}

function ReadyUp(optional int Override)
{
	//If not in stateCounting, just immediately progress
	Log(string(self) $ " isn't counting, so we're ready to progress!");
	ProgressSongs(Override);
}

function PlayNewSong()
{
	local string Song;
	local float FadeTime;
	local bool ShouldPlayOnce;
	Song = ListOfSongs[SongIndex].SongName;
	FadeTime = ListOfSongs[PrevSongIndex].CrossFadeLength;

	StopMusic(SongHandle, FadeTime);

	SongHandle = PlayMusic(Song, FadeTime);

	Log(string(self) $ " is playing new song " $ Song);
}

function ProgressSongs(optional int Override)
{
	local int i;
	local string TargetSong;

	PrevSongIndex = SongIndex;

	if (Override >= 0 && Override <= ListOfSongs.Length)
	{
		TargetSong = ListOfSongs[Override].SongName;
	}
	else
	{
		TargetSong = ListOfSongs[SongIndex].NextSongName;
	}

	for (i=0; i < ListOfSongs.Length; i++)
	{
		if (ListOfSongs[i].SongName == TargetSong)
		{
			SongIndex = i;
			break;
		}
		else
		{
			SongIndex = 0;
		}
	}

	Log("New song index for " $ string(self) $ " will be " $ string(SongIndex));

	PlayNewSong();
}

// STATES

state stateDormant
{
	event Tick (float DeltaTime)
	{
		if (SongHandle != 0)
		{
			GotoState('stateCounting');
		}
	}
}

state stateCounting
{
	event BeginState()
	{
		local float TimerCheckRate;
		if (ListOfSongs[SongIndex].CheckRate > 0.0)
		{
			TimerCheckRate = ListOfSongs[SongIndex].CheckRate;
		}
		else
		{
			local string SongFileName;
			ReadyToProgress = True;
			SongFileName = ListOfSongs[SongIndex].SongName $ ".ogg";
			Log(string(self) $ " is attemping to get length of file " $ SongFileName);
			TimerCheckRate = GetMusicLength(SongFileName);
		}

		Log(string(self) $ " is resetting its timer with rate " $ string(TimerCheckRate));
		SetTimer(TimerCheckRate, true);
	}

	event EndState()
	{
		Log(string(self) $ " is no longer counting.");
	}
	

	event Timer()
	{
		if (ReadyToProgress)
		{
			Log(string(self) $ " was ready to progress so let's do this");
			ReadyToProgress = False;
			ProgressSongs(SongOverride);
			SongOverride = -1;
			GotoState('stateDormant');
		}
	}

	function ReadyUp(optional int Override)
	{
		Log(string(self) $ " is counting and has ready'd up!");
		ReadyToProgress = True;
		SongOverride = Override;
	}

	begin:
}

defaultproperties
{
	SongOverride=-1
}