//================================================================================
// MOCAKnight. One of my oldest classes finally rewritten
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

var() bool bResetHuntersOnCatch;	// Moca: Should MOCAKnightHunters be reset when caught to avoid unfair player situations when using these actors together? Def: True
var() float HoldTime;				// Moca: How long to hold Harry in place before respawning him. Def: 5.0
var() float FadeTime;				// Moca: How long to fade out after caught, should be less than HoldTime. Def: 2.0
var() Range LookTime;				// Moca: Minimum and maximum time to spend looking in a direction, random value is picked between min and max. Def: Min = 0.75 Max = 2.0
var() Range TurnSpeed;				// Moca: Minimum and maximum time to it takes to turn in a directon, random value is picked between min and max. Def: Min = 0.334 Max = 0.667
var() name HarryCaughtAnim;			// Moca: Animation to play on Harry when he gets caught. Def: webstuck
var() Color CameraFadeColor;		// Moca: Color of screen fade after caught. Def: R=0 G=0 B=0
var() eTurnMode TurnMode;			// Moca: Turn mode for knight, FYI TM_Scan means it always turns side to side without ever centering. Def: TM_Random

var bool bJustTurned;
var bool bLastWasRight;

var name TurnLeftAnim;
var name TurnRightAnim;
var name HitAnim;


//=========
// Events
//=========

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


//=================
// Harry Handling
//=================

function GoToSleep()
{
	GotoState('stateSleep');
}

function GoToAwake()
{
	GotoState('stateLook');
}

function LockHarry()
{
	PlayerHarry.bStationary = True;
	PlayerHarry.LoopAnim(HarryCaughtAnim);
}

function UnlockHarry()
{
	PlayerHarry.bStationary = False;
	PlayerHarry.LoopAnim(PlayerHarry.GetCurrIdleAnimName());
}

function ResetHunters()
{
	if ( bResetHuntersOnCatch )
	{
		local MOCAKnightHunter A;
		
		foreach AllActors(class'MOCAKnightHunter', A)
		{
			A.Reset();
		}
	}
}

function FadeScreen(float Alpha, float FadeDuration)
{
	local FadeViewController Fader;
	Fader.Init(Alpha, CameraFadeColor.R, CameraFadeColor.G, CameraFadeColor.B, FadeDuration);
}

//==========
// Helpers
//==========

function TeleportHarry();

function float GetLookTime()
{
	return RandRange(LookTime.Min, LookTime.Max);
}

function float GetTurnSpeed()
{
	return RandRange(TurnSpeed.Min, TurnSpeed.Max);
}

function name GetTurnAnim()
{
	if ( bJustTurned && TurnMode != TM_Scan )
	{
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
			return TurnLeftAnim;
		case TM_AlwaysRight:
			return TurnRightAnim;
	}

	return TurnRightAnim;
}

function name GetRandomTurnAnim()
{
	local float RandF;
	RandF = FRand();

	if ( RandF >= 0.5 )
	{
		return TurnLeftAnim;
	}

	return TurnRightAnim;
}

function name GetOrderedTurnAnim()
{
	if ( bLastWasRight )
	{
		return TurnLeftAnim;
	}

	return TurnRightAnim;
}


//=========
// States
//=========

auto state() stateSleep
{
}

state() stateLook
{
	begin:
		Sleep(GetLookTime());
		GotoState('stateTurn');
}

state stateTurn
{
	begin:
		PlayAnim(GetTurnAnim(), [TweenTime] GetTurnSpeed());
		FinishAnim();
		GotoState('stateLook');
}

state stateCatch
{
	begin:
		LockHarry();

		Sleep(HoldTime - FadeTime);
		FadeScreen(1.0, FadeTime);
		Sleep(FadeTime + 0.5);

		TeleportHarry();
		UnlockHarry();

		FadeScreen(0.0, FadeTime);

		TriggerEvent(Event, self, PlayerHarry);
		GotoState('stateLook');
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bResetHuntersOnCatch=True
	LookTime=(Min=0.75,Max=2.0)
	TurnSpeed=(Min=0.334,Max=0.667)
	HarryCaughtAnim="webstuck"
	CameraFadeColor=(R=0,G=0,B=0)

	DrawScale=1.15
}