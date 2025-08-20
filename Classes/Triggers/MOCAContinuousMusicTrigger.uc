class MOCAContinuousMusicTrigger extends MusicTrigger;

// Needs cleanup, repetitive stuff going on

var(MOCASongArrays) array<String> songList;           //List of songs to play
var(MOCASongArrays) array<float> delayBetweenSong;    //How many seconds of delay after the song in the corresponding songList slot finishes playing
var(MOCASongArrays) array<int> numberOfLoops;         //How many times should the song in the corresponding songList slot loop before fading out?
var() bool randomizeOrder;              //Should the song list be randomized? If false, it plays them in order of the list. Def: False
var() bool preventRepeats;              //Should songs all be played once before repeating? Def: True
var() bool killPlayingTriggers;         //Should already playing MOCAContinuousMusicTriggers be destroyed

var int currentLoop;
var int songIndex;
var array<int> playedSongs;
var bool isPlaying;
var bool coolingDown;
var bool firstPlay;
var int previousIndex;

function PostBeginPlay()
{
    super.PostBeginPlay();

    if (preventRepeats && !randomizeOrder)
    {
        Log("We don't need prevent repeats for non-randomized playback");
        preventRepeats = false;
    }
}

function ProcessTrigger()
{
    local MOCAContinuousMusicTrigger A;

    if (killPlayingTriggers)
    {
        foreach AllActors(class'MOCAContinuousMusicTrigger', A)
        {
            if (A.isPlaying && A != self)
            {
                Log("Destroying other trigger: " $ string(A));
                A.Destroy();
            }
        }
    }

    isPlaying = true;

    if (songList.Length <= 1)
    {
        Log("One or less songs are set, just use a regular MusicTrigger!! Destroying self");
        Destroy();
    }

    DetermineSong();

    Log("Processing " $ string(self));
    super.ProcessTrigger();
}


function DetermineSong()
{
    local bool invalidMatch;
    local int retryAttempts;
    local int maxAttempts;

    maxAttempts = Clamp(songList.Length + 32, 0, 249);

    Log("Determining song");

    if (randomizeOrder) //If randomized
    {  
        songIndex = rand(songList.Length);  //Get random index

        Log("Our random index is " $ string(songIndex));

        if (preventRepeats) // If preventing repeats
        {
            Log("Trying to prevent repeats...");

            if (playedSongs.Length > 0)
            {
                invalidMatch = CheckForRepeat();
                Log("Do we have an invalid match: " $ string(invalidMatch));
            }

            if (playedSongs.Length >= songList.Length)
            {
                Log("Played songs is full, clear it and start over");
                playedSongs.Empty();
                if (songIndex == previousIndex)
                {
                    Log("Don't play the last song again!");
                    songIndex += 1;

                    if (songIndex > songList.Length)
                    {
                        Log("oop that song don't exist, reset to index 0");
                        songIndex = 0;
                    }
                }
                else
                {
                    invalidMatch = false;
                }
            }

            else if (invalidMatch)
            {
                Log("Retrying our selection");
                while(invalidMatch && retryAttempts < maxAttempts)
                {
                    retryAttempts++;
                    Log("Retry attempt number " $ string(retryAttempts) $ " out of " $ string(maxAttempts));
                    songIndex = rand(songList.Length);
                    invalidMatch = CheckForRepeat();
                    Log("Was retried index " $ string(songIndex) $ " valid? " $ string(!invalidMatch));
                }
            }

            AddUniqueItem(playedSongs,songIndex);
        }
        
        Song = songList[songIndex]; // We'll play the new song
        Log("Song has been set to " $ Song);

        previousIndex = songIndex;
    }

    else
    {
        Song = songList[songIndex];
        Log("Song has been set to " $ Song $ " of index " $ string(songIndex));
        songIndex++;
        Log("Next song index: " $ string(songIndex));
        if (songIndex > songList.Length)
        {
            Log("We reached the end of the list, so reset actually");
            songIndex = 0;
        }
    }
}

function bool CheckForRepeat()
{
    local int i;
    for (i = 0; i < playedSongs.Length; i++)
    {
        if (playedSongs[i] == songIndex)
        {
                return true;
        }
    }
    return false;
}

event MusicTrackLooped()
{
	super.MusicTrackLooped();

    if (currentLoop >= numberOfLoops[songIndex])
    {
        Log("Reached loop limit, stopping music");
        currentLoop = 0;
        StopAllMusic(FadeOutTime);
        GotoState('stateWaiting');
    }
    else
    {
        Log("Number of loops left versus total allowed loops: " $ string(numberOfLoops[songIndex] - currentLoop) $ " | " $ string(numberOfLoops[songIndex]));
        currentLoop++;
    }
}

function AddUniqueItem(out array<Int> Arr, int Value)
{
    local int i;

    // Check if Value already exists
    for (i = 0; i < Arr.Length; i++)
    {
        if (Arr[i] == Value)
        {
            Log("Already in array, don't add. In theory this message should not be printed!");
            return; // Already in array, return its index
        }
    }

    // If not found, add it
    Log("Adding value " $ string(Value));
    Arr.AddItem(Value);
}

state stateWaiting
{
    begin:
        Log("Waiting");
        sleep(delayBetweenSong[songIndex]);
        Log("Continuing");
        bTriggered = false;
        ProcessTrigger();
        GotoState('NormalTrigger');
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
    killPlayingTriggers=True
}