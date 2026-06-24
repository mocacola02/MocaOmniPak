//================================================================================
// MOCAKnightSpawner.
//
// MOCAVisibleSpawner of the suit of armor, has HP1-style head turning.
// Logic isn't the cleanest, but it works.
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

var() bool bStopTurningAfterSpawns;
var() Range LookTime;
var() Range TurnTime;
var() eTurnMode TurnMode;

var bool bCentering;
var float WaitTime;

var name PrevDir;
var name TargetDir;

var name CurrIdleAnim;
var name TargetAnim;
var name IdleLeftAnim;
var name TurnLeftAnim;
var name LeftCenterAnim;
var name IdleRightAnim;
var name TurnRightAnim;
var name RightCenterAnim;
var name HitAnim;


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

auto state stateIdle
{
	event BeginState()
	{
		if ( CurrIdleAnim == '' )
		{
			CurrIdleAnim = IdleAnimName;
		}

		if ( !ShouldDie() )
		{
			eVulnerableToSpell = MapDefault.eVulnerableToSpell;
		}
		
		LoopAnim(CurrIdleAnim);
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

state stateDone
{
	begin:

		// Finish any animations
		FinishAnim();

		CurrIdleAnim = IdleAnimName;
		PrevDir = 'Center';
		TargetDir = 'Center';

		// If we should die
		if ( ShouldDie() && bStopTurningAfterSpawns )
		{
			// Make us uncastable
			eVulnerableToSpell = SPELL_None;
			// Loop done anim
			LoopAnim(SpawnerAnims.DoneIdle);
		}
		// Otherwise
		else
		{
			GotoState('stateIdle');
		}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bStopTurningAfterSpawns=True
	LookTime=(Min=0.5,Max=2.0)
	TurnTime=(Min=0.334,Max=0.667)

	PrevDir="Center"
	TargetDir="Center"

	IdleAnimName="Idle"
	IdleLeftAnim="IdleLeft"
	TurnLeftAnim="IdleLookLeft"
	IdleRightAnim="IdleRight"
	TurnRightAnim="IdleLookRight"
	LeftCenterAnim="Left2Center"
	RightCenterAnim="Right2Center"

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