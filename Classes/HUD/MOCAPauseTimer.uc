class MOCAPauseTimer extends MOCATrigger;

enum ActionMode
{
	AM_None,		// Moca: No specific action, just pause for a given time
	AM_LoadLevel,	// Moca: Load a level during the pause, used for MOCATriggerChangeLevel
	AM_ShowDialogue	// Moca: Not yet implemented.
};

var() ActionMode ActionToDo;	// Moca: What action mode to use
var() bool bDestroyWhenDone;		// Moca: Should the trigger destroy when finished
var() float TimerLength;		// Moca: How long to pause for
var() string PauseMessage;		// Moca: What message should display while paused

var(MOCALoadLevelAction) string NewMap;					// Moca: What map to load if we're on AM_LoadLevel
var(MOCALoadLevelAction) Texture LoadingScreenImage;	// Moca: What image to use as the loading screen

var(MOCAShowDialogAction) bool bNotYetImplemented;		// Moca: The dialogue mode hasn't been added yet.

var bool Active;

var float TimeAccumulator;

event PostBeginPlay()
{
	super.PostBeginPlay();
	Log("PAUSE TIMER TRIGGER CREATED");
}


event Activate(Actor Other, Pawn Instigator)
{
	if (!Active)
	{
		Log("PAUSE TIMER ACTIVATED");
		Active = True;

		HPConsole(PlayerHarry.Player.Console).bLockMenus = True;
		HPConsole(PlayerHarry.Player.Console).PausedMessage = PauseMessage;

		PlayerHarry.SetPause(true);
	}
	else
	{
		Active = False;
		DetermineAction();
	}
}

event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);

    if (Active)
    {
        TimeAccumulator += DeltaTime;

        if (TimeAccumulator >= TimerLength)
        {
            Active = False;
			DetermineAction();
        }
    }
}

function EndTimer()
{
	PlayerHarry.SetPause(false);

	if (bDestroyWhenDone)
	{
		Destroy();
	}
}

function DetermineAction()
{
	TimeAccumulator = 0.0;

	switch(ActionToDo)
	{
		case AM_LoadLevel:		ActionLoadLevel();
		case AM_ShowDialogue:	Log("NOT YET IMPLEMENTED!!!!!!!!!!!!!!");	EndTimer();
		default:				ActionNone();
	}
}

function ActionNone()
{
	EndTimer();
}

function ActionLoadLevel()
{
	HPConsole(PlayerHarry.Player.Console).LoadingBackground = LoadingScreenImage;
	PlayerHarry.LoadLevel(NewMap);
}

defaultproperties
{
	bAlwaysTick=True

	LoadingScreenImage=Texture'HGame.LoadingScreen.FELoadingScreen'
}