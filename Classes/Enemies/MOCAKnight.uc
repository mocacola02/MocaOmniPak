//================================================================================
// MOCAKnight. One of my oldest classes finally rewritten. Still not amazing but better
//================================================================================
class MOCAKnight extends MOCAChar;

enum eTurnMode
{
	TM_Random,
	TM_InOrder,
	TM_AlwaysLeft,
	TM_AlwaysRight,
	TM_Scan
};

var() bool bStartAwake;				// Moca: Should knight be awake on spawn? Def: False
var() bool bResetHuntersOnCatch;	// Moca: Should MOCAKnightHunters be reset when caught to avoid unfair player situations when using these actors together? Def: True
var() float HoldTime;				// Moca: How long to hold Harry in place before respawning him. Def: 5.0
var() float FadeTime;				// Moca: How long to fade out after caught. Def: 1.0
var() Range LookTime;				// Moca: Minimum and maximum time to spend looking in a direction, random value is picked between min and max. Def: Min = 0.75 Max = 2.0
var() Range TurnSpeed;				// Moca: Minimum and maximum time to it takes to turn in a directon, random value is picked between min and max. Def: Min = 0.334 Max = 0.667
var() name CaughtAnim;				// Moca: Animation to play on self when Harry gets caught. Def: Shake
var() name HarryCaughtAnim;			// Moca: Animation to play on Harry when he gets caught. Def: webstuck
var() Color CameraFadeColor;		// Moca: Color of screen fade after caught. Def: R=0 G=0 B=0
var() eTurnMode TurnMode;			// Moca: Turn mode for knight, FYI TM_Scan means it always turns side to side without ever centering. Def: TM_Random

var bool bJustTurned;
var bool bLastWasRight;

var float TurnTime;

var name TurnLeftAnim;
var name TurnRightAnim;
var name HitAnim;

var MOCAKnightBeam EyeBeam;
var MOCAStealthTrigger StealthTrigger;


//=========
// Events
//=========

event PostBeginPlay()
{
	LoopAnim(IdleAnimName);

	if ( bStartAwake )
	{
		GoToAwake();
	}
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	super.Trigger(Other, EventInstigator);

	if ( !IsInState('stateSleep') )
	{
		GoToSleep();
	}
	else
	{
		GoToAwake();
	}
}

event Bump(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		if ( StealthTrigger != None && !IsInState('stateCatch') )
		{
			DebugLog("I bumped Harry, catching him!");
			StealthTrigger.GoToCatch();
			GoToCatch();
		}
	}
}


//=================
// State Handling
//=================

function GoToSleep()
{
	GotoState('stateSleep');

	DestroyActors();
}

function GoToAwake()
{
	DestroyActors();

	EyeBeam = Spawn(Class'MOCAKnightBeam');
	AttachToBone(EyeBeam, 'Head');

	
	StealthTrigger = Spawn(Class'MOCAStealthTrigger');
	StealthTrigger.Setup(bResetHuntersOnCatch, HoldTime, FadeTime, HarryCaughtAnim, Event, CameraFadeColor, self);

	GotoState('stateLook');
}

function GoToCatch()
{
	GotoState('stateCatch');
}

function DestroyActors()
{
	if ( StealthTrigger != None )
	{
		StealthTrigger.Destroy();
		StealthTrigger = None;
	}

	if ( EyeBeam != None )
	{
		EyeBeam.Destroy();
		EyeBeam = None;
	}
}

//==========
// Helpers
//==========

function float GetLookTime()
{
	return RandRange(LookTime.Min, LookTime.Max);
}

function float GetTurnSpeed()
{
	return RandRange(TurnSpeed.Min, TurnSpeed.Max);
}

function float GetTweenTime(float TurnValue)
{
	return TurnValue * TurnValue;
}

function name GetTurnAnim()
{
	DebugLog("Mode is " $ TurnMode);

	if ( bJustTurned && TurnMode != TM_Scan )
	{
		DebugLog("Turning to center");
		bJustTurned = False;
		return IdleAnimName;
	}

	bJustTurned = True;

	switch(TurnMode)
	{
		case TM_Random:
			return GetRandomTurnAnim();
		case TM_Scan:
		case TM_InOrder:
			return GetOrderedTurnAnim();
		case TM_AlwaysLeft:
			DebugLog("Looking left");
			return TurnLeftAnim;
		case TM_AlwaysRight:
			DebugLog("Looking right");
			return TurnRightAnim;
	}

	DebugLog("Looking right");
	return TurnRightAnim;
}

function name GetRandomTurnAnim()
{
	local float RandF;
	RandF = FRand();

	if ( RandF >= 0.5 )
	{
		DebugLog("Looking left");
		return TurnLeftAnim;
	}

	DebugLog("Looking right");
	return TurnRightAnim;
}

function name GetOrderedTurnAnim()
{
	if ( bLastWasRight )
	{
		bLastWasRight = False;
		DebugLog("Looking left");
		return TurnLeftAnim;
	}

	bLastWasRight = True;
	DebugLog("Looking right");
	return TurnRightAnim;
}


//=========
// States
//=========

auto state stateSleep
{
}

state stateLook
{
	begin:
		DebugLog("Waiting to turn again");
		Sleep(GetLookTime());
		GotoState('stateTurn');
}

state stateTurn
{
	begin:
		TurnTime = GetTurnSpeed();
		TweenAnim(GetTurnAnim(), GetTweenTime(TurnTime));
		DebugLog("TweenTime = " $ GetTweenTime(TurnTime));
		DebugLog("Waiting for " $ TurnTime);
		Sleep(TurnTime);
		
		GotoState('stateLook');
}

state stateCatch
{
	begin:
		LoopAnim(CaughtAnim);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bResetHuntersOnCatch=True
	HoldTime=5.0
	FadeTime=1.0
	LookTime=(Min=1.667,Max=3.334)
	TurnSpeed=(Min=1.667,Max=3.334)
	CaughtAnim="Shake"
	HarryCaughtAnim="webstuck"
	CameraFadeColor=(R=0,G=0,B=0)

	IdleAnimName="Idle"
	TurnLeftAnim="IdleLeft"
	TurnRightAnim="IdleRight"
	CaughtAnim="IdleHit"
	HitAnim="IdleHit"

	bDebugLogging=True

	CollisionHeight=54

	DrawScale=1.15
	Mesh=SkeletalMesh'MocaOmniResources.skKnight'
}