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

var() Range HoldTime;
var() Range LookTime;
var() eTurnMode TurnMode;
var bool bJustTurned;


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
	loop:
		Sleep(RandRange(LookTime.Min, LookTime.Max));
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	SpawnerAnims=(Spawning=IdleHit,EndSpawning=None,Idle=Idle,DoneIdle=Idle,FinalSpawnEnd=IdleHit)
	SpawnerSounds=(Opening=Sound'MocaOmniResources.armor_clink_multi)
	GlobalSpawnOffset=(X=0,Y=0,Z=8)
	Mesh=SkeletalMesh'MocaOmniResources.skKnight'
	AmbientGlow=32
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
	bAlignBottomAlways=True
}