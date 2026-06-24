//================================================================================
// MOCAKnightSpawner.
//================================================================================
class MOCAKnightSpawner extends MOCAVisibleSpawner;

enum eTurnMode
{
	TM_Random,
	TM_InOrder,
	TM_AlwaysLeft,
	TM_AlwaysRight,
	TM_Scan
};

var() Range LookTime;
var() Range TurnTime;
var() eTurnMode TurnMode;

var bool bJustTurned;
var bool bLastWasRight;

var float WaitTime;
var float CurTweenTime;
var float TargetTweenTime;

var name CurrentAnim;
var name TurnLeftAnim;
var name TurnRightAnim;
var name HitAnim;


//=========
// Events
//=========

event PostBeginPlay()
{
	Super.PostBeginPlay();
	CurrentAnim = IdleAnimName;
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
		bLastWasRight = False;
		return TurnLeftAnim;
	}

	bLastWasRight = True;
	return TurnRightAnim;
}


//=========
// States
//=========

auto state stateIdle
{
	event BeginState()
	{
		Super.BeginState();
		PlayAnim(CurrentAnim,, 0.0);
	}

	begin:
		WaitTime = RandRange(LookTime.Min, LookTime.Max);
		DebugLog("Waiting for " $ WaitTime);
		Sleep(WaitTime);
		DebugLog("Going to stateTurn");
		GotoState('stateTurn');
}

state stateTurn
{
	event BeginState()
	{
		// Get anim
		CurrentAnim = GetTurnAnim();
		
		// Setup tween
		CurTweenTime = 0.0;
		TweenAlpha = 0.0;
		TargetTweenTime = RandRange(TurnTime.Min, TurnTime.Max);

		// Play anim
		PlayAnim(CurrentAnim);

		// Clear tween rate
		TweenRate = 0.0;
	}

	event Tick(float DeltaTime)
	{
		// Increment current tween time
		CurTweenTime += DeltaTime;

		// Calculate alpha
		TweenAlpha = CurTweenTime / TargetTweenTime;

		DebugLog("TweenAlpha: " $ TweenAlpha);

		// If alpha exceeds 1.0 limit, exit state
		if ( TweenAlpha >= 1.0 )
		{
			DebugLog("Finished Tween");
			GotoState('stateIdle');
		}
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bDebugLogging=True

	LookTime=(Min=1.667,Max=3.334)
	TurnTime=(Min=9.667,Max=10.334)

	IdleAnimName="Idle"
	TurnLeftAnim="IdleLeft"
	TurnRightAnim="IdleRight"

	SpawnerAnims=(Spawning=IdleHit,EndSpawning=None,Idle=Idle,DoneIdle=Idle,FinalSpawnEnd=IdleHit)
	SpawnerSounds=(Opening=Sound'MocaOmniResources.armor_clink_multi)
	GlobalSpawnOffset=(X=0,Y=0,Z=8)

	bAlignBottomAlways=True
	CollisionRadius=21
	CollisionHeight=54
	CollideType=CT_OrientedCylinder

	AmbientGlow=32
	DrawScale=1.15
	Mesh=SkeletalMesh'MocaOmniResources.skKnight'
}