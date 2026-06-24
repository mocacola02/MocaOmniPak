//================================================================================
// MOCAKnight.
//
// Turns its head to "scan" for Harry, similar to the HP3 6th gen knights.
// If you want a prop version of this, see MOCAKnightSpawner.
//================================================================================
class MOCAKnight extends MOCAChar;

//= Export Vars =//
enum eTurnMode
{
	TM_Random,
	TM_InOrder,
	TM_AlwaysLeft,
	TM_AlwaysRight,
	TM_Scan
};

var() Range 	LookTime;	// Moca: Minimum and maximum time to spend looking in a direction, random value is picked between min and max. Def: Min = 0.75 Max = 2.0
var() Range 	TurnTime;	// Moca: Minimum and maximum time to it takes to turn in a directon, random value is picked between min and max. Def: Min = 0.334 Max = 0.667
var() eTurnMode TurnMode;	// Moca: Turn mode for knight, FYI TM_Scan means it always turns side to side without ever centering. Def: TM_Random

//= Stealth Vars =//
var(MOCAStealth) bool 	bStartAwake;				// Moca: Should knight be awake on spawn? Def: True
var(MOCAStealth) bool 	bResetHuntersOnCatch;		// Moca: Should MOCAKnightHunters be reset when caught to avoid unfair player situations when using these actors together? Def: True
var(MOCAStealth) float 	HoldTime;					// Moca: How long to hold Harry in place before respawning him. Def: 2.0
var(MOCAStealth) float 	FadeTime;					// Moca: How long to fade out after caught. Def: 3.0
var(MOCAStealth) name 	CaughtAnim;					// Moca: Animation to play on self when Harry gets caught. Def: Shake
var(MOCAStealth) name 	HarryCaughtAnim;			// Moca: Animation to play on Harry when he gets caught. Def: webstuck
var(MOCAStealth) Color 	CameraFadeColor;			// Moca: Color of screen fade after caught. Def: R=0 G=0 B=0

//= Head Turn Vars =//
var bool 	bCentering;
var float 	WaitTime;

var name 	AttachBone;

var name 	PrevDir;
var name 	TargetDir;

var name 	CurrIdleAnim;
var name 	TargetAnim;
var name 	IdleLeftAnim;
var name 	TurnLeftAnim;
var name 	LeftCenterAnim;
var name 	IdleRightAnim;
var name 	TurnRightAnim;
var name 	RightCenterAnim;
var name 	HitAnim;

//= Actor Ref Vars =//
var MOCAKnightBeam 		EyeBeam;
var MOCAStealthTrigger 	StealthTrigger;


//=========
// Events
//=========

event Trigger(Actor Other, Pawn EventInstigator)
{
	super.Trigger(Other, EventInstigator);

	if ( !IsInState('stateSleep') )
	{
		GotoState('stateSleep');
	}
	else
	{
		GotoState('stateIdle');
	}
}

event Bump(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		if ( StealthTrigger != None && !IsInState('stateCatch') )
		{
			DebugLog("I bumped Harry, catching him!");

			StealthTrigger.GotoState('stateCatch');
			GotoState('stateCatch');
		}
	}
}


//================
// Spawn Helpers
//================

function CreateStealthActors()
{
	if ( EyeBeam == None )
	{
		EyeBeam = Spawn(Class'MOCAKnightBeam', self);

		if ( AttachBone != '' )
		{
			AttachToBone(EyeBeam, AttachBone);
		}
	}

	if ( StealthTrigger == None )
	{
		StealthTrigger = Spawn(Class'MOCAStealthTrigger', self);
		StealthTrigger.Setup(bResetHuntersOnCatch, HoldTime, FadeTime, HarryCaughtAnim, Event, CameraFadeColor, self);
	}

	DebugLog("StealthTrigger: " $ StealthTrigger $ " | EyeBeam: " $ EyeBeam);
}

function DestroyStealthActors()
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


//======================
// Animation Selection
//======================

function name GetTurnAnimation()
{
	local name TempDir;
	TempDir = GetTurnDirection();
	PrevDir = TargetDir;
	TargetDir = TempDir;

	bCentering = False;

	if ( TargetDir == 'Left' )
	{
		return TurnLeftAnim;
	}
	else if ( TargetDir == 'Right' )
	{
		return TurnRightAnim;
	}
	else
	{
		bCentering = True;
		if ( PrevDir == 'Left' )
		{
			return LeftCenterAnim;
		}
		else
		{
			return RightCenterAnim;
		}
	}
}

function name GetTurnDirection()
{
	switch(TurnMode)
	{
		case TM_Random:
			return GetRandomTurnAnim();
		case TM_Scan:
		case TM_InOrder:
			return GetOrderedDirection();
		case TM_AlwaysLeft:
			return GetCenterOrOther('Left');;
	}

	return GetCenterOrOther('Right');
}

function name GetCenterOrOther(name OtherDir)
{
	if ( TargetDir != 'Center' )
	{
		return 'Center';
	}

	return OtherDir;
}

function name GetRandomTurnAnim()
{
	local float RandF;
	RandF = FRand();

	if ( TargetDir != 'Center' )
	{
		return 'Center';
	}
	else if ( RandF > 0.5 )
	{
		return 'Left';
	}
	else
	{
		return 'Right';
	}
}

function name GetOrderedDirection()
{
	if ( TargetDir != 'Center' )
	{
		return 'Center';
	}
	else if ( PrevDir == 'Right' )
	{
		return 'Left';
	}
	else
	{
		return 'Right';
	}
}


//===============
// Time Helpers
//===============

function float GetLookTime()
{
	return RandRange(LookTime.Min, LookTime.Max);
}

function float GetTurnTime()
{
	local float TurnRate;
	TurnRate = 1.0 / RandRange(TurnTime.Min, TurnTime.Max);
	DebugLog("TurnRate: " $ TurnRate);
	return TurnRate;
}


//=========
// States
//=========

auto state stateSleep
{
	event BeginState()
	{
		DestroyStealthActors();

		LoopAnim(IdleAnimName);
		
		eVulnerableToSpell = SPELL_None;
	}

	begin:
		if ( bStartAwake )
		{
			bStartAwake = False;
			GotoState('stateIdle');
		}
}

state stateIdle
{
	event BeginState()
	{
		CreateStealthActors();

		eVulnerableToSpell = MapDefault.eVulnerableToSpell;

		if ( CurrIdleAnim == '' )
		{
			CurrIdleAnim = IdleAnimName;
		}

		LoopAnim(CurrIdleAnim);

		DebugLog("Finished entering stateIdle");
	}

	begin:
		WaitTime = GetLookTime();
		DebugLog("Sleeping for " $ WaitTime $ " seconds");

		Sleep(WaitTime);

		DebugLog("Going to turn");
		GotoState('stateTurn');
}

state stateTurn
{
	begin:
		TargetAnim = GetTurnAnimation();

		DebugLog("TargetDir: " $ TargetDir $ " | PrevDir: " $ PrevDir $ " | TargetAnim: " $ TargetAnim);
		DebugLog("Now playing " $ TargetAnim);

		PlayAnim(TargetAnim, GetTurnTime());
		FinishAnim();

		if ( TurnMode == TM_Scan && bCentering )
		{
			Goto('begin');
		}
		if ( TargetDir == 'Left' )
		{
			CurrIdleAnim = IdleLeftAnim;
		}
		else if ( TargetDir == 'Right' )
		{
			CurrIdleAnim = IdleRightAnim;
		}
		else
		{
			CurrIdleAnim = IdleAnimName;
		}

		GotoState('stateIdle');
}

state stateCatch
{
	event BeginState()
	{
		LoopAnim(CaughtAnim);
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bStartAwake=True
	bResetHuntersOnCatch=True
	HoldTime=2.0
	FadeTime=3.0
	CaughtAnim="IdleHit"
	HarryCaughtAnim="webstuck"
	CameraFadeColor=(R=0,G=0,B=0)

	LookTime=(Min=1.667,Max=3.334)
	TurnTime=(Min=0.667,Max=1.334)

	AttachBone="Head"

	PrevDir="Center"
	TargetDir="Center"

	IdleAnimName="Idle"
	IdleLeftAnim="IdleLeft"
	TurnLeftAnim="IdleLookLeft"
	IdleRightAnim="IdleRight"
	TurnRightAnim="IdleLookRight"
	LeftCenterAnim="Left2Center"
	RightCenterAnim="Right2Center"
	HitAnim="IdleHit"

	bAlignBottomAlways=True
	CollisionRadius=21
	CollisionHeight=54
	CollideType=CT_OrientedCylinder

	AmbientGlow=32
	DrawScale=1.15
	Mesh=SkeletalMesh'MocaOmniResources.skKnight'
}