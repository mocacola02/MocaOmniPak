class MOCAContinuousMusicTrigger extends MusicTrigger;

var() array<String> songList;           //List of songs to play
var() array<float> delayBetweenSong;    //How many seconds of delay after the song in the corresponding songList slot finishes playing
var() array<int> numberOfLoops;         //How many times should the song in the corresponding songList slot loop before fading out?
var() bool randomizeOrder;              //Should the song list be randomized? If false, it plays them in order of the list. Def: False
var() bool preventRepeats;              //Should songs all be played once before repeating? Def: True

var int currentLoop;
var int currentSong;
var array<String> playedSongs;

function PostBeginPlay()
{
    super.PostBeginPlay();

    if (preventRepeats && !randomizeOrder)
    {
        preventRepeats = false;
    }

    if (randomizeOrder)
    {
        DetermineSong();
    }
}

function DetermineSong()
{
    local int songIndex;
    if (randomizeOrder)
    {  
        songIndex = rand(songList.Length);

        Song = songList[songIndex];
        currentSong = songIndex;
    }
    else
    {
        songIndex++;
    }
}

event MusicTrackLooped()
{
	super.MusicTrackLooped();

    if (currentLoop >= numberOfLoops[currentSong])
    {
        if(preventRepeats)
        {  
            playedSongs.AddItem(songList[currentSong]);
            Log(string(songList.Length));
            songList.RemoveItem(songList[currentSong]);
            Log(string(songList.Length));
            if (songList.Length <= 0)
            {
                songList = playedSongs;
                playedSongs.Empty();
            }
        }
        currentLoop = 0;
        StopAllMusic(FadeOutTime);
        GotoState('stateWaiting');
    }
    else
    {
        currentLoop++;
    }
}



state stateWaiting
{
    begin:
        sleep(delayBetweenSong[currentSong]);
        DetermineSong();
        ProcessTrigger();
}

defaultproperties
{
    songList(0)="SM_CDA_DADAAction_01"
    songList(1)="sm_cda_dadaShaft-S_02"
    songList(2)="sm_cda_skurgeActionEdit_02_ogg"

    delayBetweenSong(0)=10
    delayBetweenSong(1)=5
    delayBetweenSong(2)=20

    numberOfLoops(0)=1
    numberOfLoops(1)=2
    numberOfLoops(2)=3

    bTriggerOnceOnly=True
}