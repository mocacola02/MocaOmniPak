//================================================================================
// MOCAHunter.
//================================================================================
class MOCAHunter extends MOCANavigator;

var() int 	MaxChaseAttempts;		// Moca: How many attempts to try and find Harry after losing sight of him? Def: 2
var() float CatchTime;				// Moca: How long to hold Harry in place before fading out after caught? Def: 2.0
var() Range IdleTime;				// Moca: What range of time will we idle in between patrolling? Def: Min=1.0 Max=3.0
var() Sound CaughtMusicCue;			// Moca: What music cue to play when caught? Def: None, set in child actors
var() Sound CaughtSFX;				// Moca: What sound to play when caught? Def: None, set in child actors


var(MOCAAnims) array<name> HuntIdleAnims;
var(MOCAAnims) name CatchAnim;		// Moca: What anim to play when catching Harry? Def: None, set in child actors
var(MOCAAnims) name HarryCatchAnim;	// Moca: What anim to play on Harry when caught? Def: webstuck
var(MOCAAnims) name WakeUpAnim;		// Moca: What anim to play when waking up? Def: None, set in child actors

var bool 	bDerailed;			// Moca: Are we currently derailed?
var int 	CurrChaseAttempts;	// Moca: Current number of chase attempts


//=========
// Events
//=========

event Bump(Actor Other)
{
	if ( Other == PlayerHarry && !IsInState('stateCatch') )
	{
		GotoState('stateCatch');
	}
}


//====================
// Animation Helpers
//====================

function name GetIdleAnim()
{
	local int RandIdx;
	RandIdx = Rand(HuntIdleAnims.Length);
	return HuntIdleAnims[RandIdx];
}


//================
// Catch Helpers
//================

function Reset(optional bool bGoToIdle)
{
	SetLocation(HomeLocation);

	if ( bGoToIdle )
	{
		GotoState('stateIdle');
	}
}

function TeleportHarry(Vector NewLocation, Rotator NewRotation)
{
	PlayerHarry.SetLocation(NewLocation);
	PlayerHarry.SetRotation(NewRotation);
}


//=========
// States
//=========

state() stateSleep
{
	event BeginState()
	{
		LoopAnim(IdleAnimName);
	}

	event EndState()
	{
		DebugLog("Waking up");
	}

	event Tick(float DeltaTime)
	{
		if ( ActivationRadius > 0.0 && IsHarryNear(ActivationRadius) )
		{
			GotoState('stateIdle', 'awaken');
		}
	}

	begin:
		StopMoving();
}

state() stateIdle
{
	function HandleHarrySpotted()
	{
		DebugLog("Going to chase");
		GotoState('stateChase');
	}

	begin:
		StopMoving();

		LoopAnim(GetIdleAnim());

		Sleep(GetIdleTime());

		DebugLog("Going to wander");
		GotoState('stateWander');
	
	awaken:
		PlayAnim(WakeUpAnim, [RootBone] 'Move');
		FinishAnim();

		TurnToward(PlayerHarry);

		DebugLog("Finished wake up");
		Goto('begin');
}

state stateWander
{
	event BeginState()
	{
		local Vector DestPos;

		if ( !IsCloseToHome() )
		{
			DestPos = HomeLocation;
		}
		
		GroundSpeed = GroundWalkSpeed;
		destP = GetValidDestinationTo(DestPos, True);
		DebugLog("Got wander destP: " $ destP);
		LoopAnim(WalkAnimName);
	}

	function HandleHarrySpotted()
	{
		DebugLog("Going to chase");
		GotoState('stateChase');
	}

	begin:
		UpdateNavP();

		while ( IsValidNavP() )
		{
			DebugLog("Moving to " $ navP);
			MoveToward(navP);
			UpdateNavP();
			SleepForTick();
		}

		MoveToward(destP);
		SleepForTick();

		DebugLog("Done wandering");
		GotoState('stateIdle');
}

state stateChase
{
	event BeginState()
	{
		GroundSpeed = GroundRunSpeed;
		LoopAnim(RunAnimName);
	}

	event EndState()
	{
		DebugLog("Ending chase");
		CurrChaseAttempts = 0;
	}

	event Tick(float DeltaTime)
	{
		local bool bPrevDerailed;
		bPrevDerailed = bDerailed;
		bDerailed = CanISeeHarry(ViewDot, True);

		if ( bDerailed && !bPrevDerailed )
		{
			DebugLog("Derailing");
			GotoState('stateChase', 'chase');
		}
	}

	search:
		destP = GetValidDestinationTo(PlayerHarry.Location, True);
		UpdateNavP();

		while ( IsValidNavP() && !bDerailed )
		{
			DebugLog("Searching to " $ navP);
			MoveToward(navP);
			UpdateNavP();
			SleepForTick();
		}

		MoveToward(destP);
		SleepForTick();

		if ( CurrChaseAttempts <= MaxChaseAttempts )
		{
			CurrChaseAttempts++;
			DebugLog("Trying again, attempt #" $ CurrChaseAttempts);
			destP = GetValidDestinationTo(PlayerHarry.Location, True);
			Goto('search');
		}
		else
		{
			GotoState('stateIdle');
		}
	
	chase:
		CurrChaseAttempts = 0;

		while ( bDerailed )
		{
			DebugLog("Moving directly to Harry");
			MoveToward(PlayerHarry);
			SleepForTick();
		}

		Goto('search');
}

state stateCatch
{
	event BeginState()
	{
		LoopAnim(CatchAnim);

		if ( CaughtMusicCue != None )
		{
			PlaySound(CaughtMusicCue, SLOT_Misc, [Disable3D] True);
		}

		if ( CaughtSFX != None )
		{
			PlaySound(CaughtSFX, SLOT_Interact);
		}

		PlayerHarry.bKeepStationary = True;
		PlayerHarry.LoopAnim(HarryCatchAnim);
	}

	begin:
		DebugLog("Caught Harry");
		StopMoving();
		PlayerHarry.StopMoving();

		Sleep(CatchTime);
		FadeScreen(1.0, FadeTime);
		Sleep(FadeTime + 0.25);

		Reset();

		if ( PlayerHarry.IsA('MOCAharry') )
		{
			TeleportHarry(MOCAharry(PlayerHarry).RespawnLocation, MOCAharry(PlayerHarry).RespawnRotation);
		}
		else
		{
			TeleportHarry(PlayerHarry.ChessTargetLocation, PlayerHarry.Rotation);
		}

		PlayerHarry.bKeepStationary = False;
		PlayerHarry.LoopAnim(PlayerHarry.GetCurrIdleAnimName());
		
		FadeScreen(0.0, FadeTime);
		GotoState('stateIdle');
}


//===============
// Time Helpers
//===============

function float GetIdleTime()
{
	return RandRange(IdleTime.Min, IdleTime.Max);
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	MaxChaseAttempts=2
	CatchTime=2.0
	IdleTime=(Min=1.0,Max=3.0)
	CaughtMusicCue=Sound'MocaOmniResources.stealth_caught'
	CaughtSFX=Sound'MocaOmniResources.armor_clink_multi'

	HuntIdleAnims(0)="HuntIdle1"
	HuntIdleAnims(1)="HuntIdle2"
	CatchAnim="IdleHit"
	HarryCatchAnim="webstuck"
	WakeUpAnim="WakeUp"

	eVulnerableToSpell=SPELL_None

	bAlignBottomAlways=True
	CollisionRadius=21
	CollisionHeight=54
	CollideType=CT_OrientedCylinder
	
	AmbientGlow=32
	DrawScale=1.15
	Mesh=SkeletalMesh'MocaOmniResources.skKnight'
	ShadowScale=0.5
	IdleAnimName="Idle"
	WalkAnimName="HuntWalk"
	RunAnimName="HuntWalk"
	
	GroundSpeed=100.0
	RotationRate=(Pitch=4096,Yaw=100000,Roll=3072)

	InitialState="stateSleep"
}