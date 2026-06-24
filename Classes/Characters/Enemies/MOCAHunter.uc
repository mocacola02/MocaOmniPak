//================================================================================
// MOCAHunter.
//================================================================================
class MOCAHunter extends MOCAChar;

const MAX_VERIFIES = 5;

var() int 	MaxChaseAttempts;			// Moca: How many attempts to try and find Harry after losing sight of him? Def: 2
var() float WakeUpRadius;			// Moca: How close does Harry have to get to wake us up? If 0.0, proximity does not awaken us. Def: 384.0
var() float ViewDot;				// Moca: What is the minimum dot product to be considered as within our view? Def: 0.25
var() float CatchTime;				// Moca: How long to hold Harry in place before fading out after caught? Def: 2.0
var() float FadeTime;				// Moca: How long to fade out the screen before respawning? Def: 3.0
var() Range IdleTime;				// Moca: What range of time will we idle in between patrolling? Def: Min=1.0 Max=3.0
var() Sound CaughtMusicCue;			// Moca: What music cue to play when caught? Def: None, set in child actors
var() Sound CaughtSFX;				// Moca: What sound to play when caught? Def: None, set in child actors
var() Color CameraFadeColor;		// Moca: What color to use for screen fade? Def: R=0 G=0 B=0

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

event Tick(float DeltaTime)
{
	if ( CanISeeHarry(ViewDot, True) )
	{
		HandleHarrySpotted();
	}
}


//=====================
// Navigation Helpers
//=====================

function HandleHarrySpotted();

function UpdateNavP()
{
	navP = NavigationPoint(FindPathToward(destP));
	DebugLog("Updated navP: " $ navP);
}

function bool IsValidNavP()
{
	DebugLog("Is navP valid: " $ navP != destP $ " and " $ navP != None);
	return navP != destP && navP != None;
}

function NavigationPoint GetDestination(optional Vector TargetPos)
{
	if ( VSize(TargetPos) >= 0.1 )
	{
		DebugLog("Finding path to " $ TargetPos);
		return NavigationPoint(FindPathTo(TargetPos));
	}

	DebugLog("Finding random dest");
	return FindRandomDest();
}

function NavigationPoint GetValidDestination(optional Vector TargetPos)
{
	local int CurrAttempts;
	local NavigationPoint WorkingNavP;

	WorkingNavP = GetDestination(TargetPos);

	while ( (WorkingNavP == LastNavP || WorkingNavP == None) && CurrAttempts < MAX_VERIFIES )
	{
		CurrAttempts++;

		DebugLog("Attempt #" $ CurrAttempts $ ": We had a duplicate or null navP of " $ WorkingNavP);
		WorkingNavP = GetDestination(TargetPos);
	}

	DebugLog("Selected " $ WorkingNavP);
	return WorkingNavP;
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

function FadeScreen(float Alpha, float FadeT)
{
	local FadeViewController FVC;
	FVC = Spawn(Class'FadeViewController');
	FVC.Init(Alpha, CameraFadeColor.R, CameraFadeColor.G, CameraFadeColor.B, FadeT);
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
		if ( WakeUpRadius > 0.0 && IsHarryNear(WakeUpRadius) )
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
		destP = GetValidDestination(DestPos);
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
		destP = GetValidDestination(PlayerHarry.Location);
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
			destP = GetValidDestination(PlayerHarry.Location);
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
	WakeUpRadius=384.0
	ViewDot=0.25
	CatchTime=2.0
	FadeTime=3.0
	IdleTime=(Min=1.0,Max=3.0)
	CaughtMusicCue=Sound'MocaOmniResources.stealth_caught'
	CaughtSFX=Sound'MocaOmniResources.armor_clink_multi'
	CameraFadeColor=(R=0,G=0,B=0)

	HuntIdleAnims(0)="HuntIdle1"
	HuntIdleAnims(1)="HuntIdle2"
	CatchAnim="IdleHit"
	HarryCatchAnim="webstuck"
	WakeUpAnim="WakeUp"

	bTiltOnMovement=False

	eVulnerableToSpell=SPELL_None

	bAdvancedTactics=True
	SightRadius=2500.0

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