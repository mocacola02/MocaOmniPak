//================================================================================
// MOCAStalker.
//================================================================================

class MOCAStalker extends MOCAChar;

var() float AngerRate;
var() float RelaxRate;
var() float RequiredAnger;
var() float ChaseSpeed;
var() float StalkCooldown;
var() float MinDot; //0.25

var() float ActiveRadius;

var(MOCAStalkerSFX) Sound RetreatSound;
var(MOCAStalkerSFX) Sound AttackSound;
var(MOCAStalkerSFX) Sound KillSound;
var(MOCAStalkerSFX) Sound DieSound;

var(MOCAStalkerAnims) name WaitAnim;
var(MOCAStalkerAnims) float WaitAnimRate;

var(MOCAStalkerAnims) name SneakAnim;
var(MOCAStalkerAnims) float SneakAnimRate;

var(MOCAStalkerAnims) name RetreatAnim;
var(MOCAStalkerAnims) float RetreatAnimRate;

var(MOCAStalkerAnims) name StareAnim;
var(MOCAStalkerAnims) float StareAnimRate;

var(MOCAStalkerAnims) name AttackAnim;
var(MOCAStalkerAnims) float AttackAnimRate;

var(MOCAStalkerAnims) name KillAnim;
var(MOCAStalkerAnims) float KillAnimRate;

var(MOCAStalkerAnims) name DieAnim;
var(MOCAStalkerAnims) float DieAnimRate;

var bool bIsStaring;

var int RandInt;
var float CurrentAnger;

var NavigationPoint RetreatNavP;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	EnableTurnTo(PlayerHarry);

	if ( !MOCAHelpers.DoesActorExist(class'MOCAStalkerNode') || !PlayerHarry.IsA('MOCAharry') )
	{
		EnterErrorMode("MOCAStalker actors (like MOCABracken) require MOCAStalkerNodes and MOCAharry. Make sure you have these implemented.");
	}
}

event Bump(Actor Other)
{
	Super.Bump(Other);

	if ( Other == PlayerHarry && !IsInState('stateKill') )
	{
		GotoState('stateKill');
	}
}

event HitWall(Vector HitNormal, Actor HitWall)
{
	Super.HitWall(HitNormal,HitWall);

	if ( ( !IsInState('stateStalkDerailed') || !IsInState('stateAttackDerailed') ) && !IsInState('stateRetreat') )
	{
		GotoState('stateRetreat','retreat');
	}
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	local bool bSeenByHarry;

	bSeenByHarry = IsOtherLookingAt(PlayerHarry,MinDot);

	if ( ( bIsStaring && bSeenByHarry ) || ( GetDistanceFromHarry() < 128.0 ) )
	{
		CurrentAnger += AngerRate * DeltaTime;
		CurrentAnger = FClamp(CurrentAnger,0.0,RequiredAnger);
	}
	else if ( AngerValue > 0.0 && !bSeenByHarry )
	{
		CurrentAnger -= RelaxRate * DeltaTime;
		CurrentAnger = FClamp(CurrentAnger,0.0,RequiredAnger);
	}

	if ( bSeenByHarry && ShouldRetreat() )
	{
		GotoState('stateRetreat','stare');
	}
}


//////////
// Magic
//////////

function ProcessSpell()
{
	HitsTaken++;

	if ( ShouldDie() )
	{
		GotoState('stateDie');
	}
}


////////////////////
// Misc. Functions
////////////////////

function bool ShouldRetreat()
{
	return !IsInState('stateRetreat') && !IsInState('stateAttack') && !IsInState('stateAttackDerailed') && !IsInState('stateKill') && !IsInState('stateDie');
}

function UpdateNodeViewDistance(float NewDistance)
{
	local MOCAStalkerNode A;
	
	foreach AllActors(class'MOCAStalkerNode', A)
	{
		A.SetRequiredDistance(NewDistance);
	}
}


///////////
// States
///////////

auto state stateWait
{
	event BeginState()
	{
		LoopAnim(WaitAnim, WaitAnimRate);
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( IsHarryNear(ActiveRadius) )
		{
			navP = NavigationPoint(FindPathToward(PlayerHarry));
			if ( navP != None )
			{
				GotoState('stateStalk','stalk');
			}
		}
	}

	begin:
		StopMoving();
}

state stateStalk
{
	event BeginState()
	{
		UpdateNodeViewDistance(SightRadius);
		LoopAnim(SneakAnim,SneakAnimRate);
	}

	stalk:
		StopMoving();

		while ( navP != None && IsHarryNear(ActiveRadius) )
		{
			if ( CanISeeHarry(MinDot,True) )
			{
				GotoState('stateStalkDerailed');
			}

			StrafeFacing(navP.Location,PlayerHarry);

			navP = NavigationPoint(FindPathToward(PlayerHarry));
			SleepForTick();
		}

		GotoState('stateWait');
}

state stateStalkDerailed
{
	stalk:
		StopMoving();

		while ( IsHarryNear(ActiveRadius) && CanISeeHarry(MinDot,True) )
		{
			StrafeFacing(PlayerHarry.Location,PlayerHarry);
			SleepForTick();
		}

		GotoState('stateStalk','stalk');
}

state stateRetreat
{
	event BeginState()
	{
		UpdateNodeViewDistance(GetDistanceFromHarry() - 32.0);
		GroundSpeed = ChaseSpeed;
		PlaySound(RetreatSound,SLOT_Talk,1.0,,TransientSoundRadius);
		RetreatNavP = GetFurthestNavPoint(PlayerHarry);
		navP = NavigationPoint(FindPathToward(RetreatNavP));
	}

	event EndState()
	{
		bIsStaring = False;
		GroundSpeed = MapDefault.GroundSpeed;
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		RandInt = Rand(32);
		if ( RandInt == 0 )
		{
			GotoState('stateRetreat','stare');
		}
	}

	retreat:
		LoopAnim(RetreatAnim,RetreatAnimRate);

		while ( navP != None && navP != RetreatNavP )
		{
			StrafeFacing(navP.Location,PlayerHarry);

			navP = NavigationPoint(FindPathToward(RetreatNavP));

			SleepForTick();
		}

		if ( IsOtherLookingAt(PlayerHarry,MinDot) )
		{
			GotoState('stateAttack');
		}

		GotoState('stateCooldown');
	
	stare:
		bIsStaring = True;
		StopMoving();
		LoopAnim(StareAnim,StareAnimRate);

		RandInt = Rand(24);

		if ( CurrentAnger >= RequiredAnger )
		{
			GotoState('stateAttack');
		}
		else if ( RandInt == 0 )
		{
			bIsStaring = False;
			Goto('retreat');
		}
		else
		{
			SleepForTick();
			Goto('stare');
		}
}

state stateAttack
{
	event BeginState()
	{
		UpdateNodeViewDistance(SightRadius);
		GroundSpeed = ChaseSpeed;
		PlaySound(AttackSound,SLOT_Talk,1.0,,TransientSoundRadius);
		LoopAnim(AttackAnim,AttackAnimRate);
	}

	event EndState()
	{
		GroundSpeed = MapDefault.GroundSpeed;
	}

	begin:
		StopMoving();

		while ( CurrentAnger > 0.0 && navP != None )
		{
			if ( CanISeeHarry(MinDot,True) )
			{
				GotoState('stateAttackDerailed');
			}

			StrafeFacing(navP.Location,PlayerHarry);

			navP = NavigationPoint(FindPathToward(PlayerHarry));

			SleepForTick();
		}

		GotoState('stateRetreat','retreat');
}

state stateAttackDerailed
{
	event BeginState()
	{
		GroundSpeed = ChaseSpeed;
		PlaySound(AttackSound,SLOT_Talk,1.0,,TransientSoundRadius);
		LoopAnim(AttackAnim,AttackAnimRate);
	}

	event EndState()
	{
		GroundSpeed = MapDefault.GroundSpeed;
	}

	begin:
		while ( CanISeeHarry(MinDot,True) && CurrentAnger > 0.0 )
		{
			StrafeFacing(PlayerHarry.Location,PlayerHarry);
			SleepForTick();
		}

		if ( CurrentAnger <= 0.0 )
		{
			GotoState('stateRetreat','retreat');
		}

		SleepForTick();
		GotoState('stateAttack');
}

state stateKill
{
	begin:
		StopMoving();

		PlayerHarry.bKeepStationary = True;

		StrafeTo(Location - Vector(Rotation) * (PlayerHarry.CollisionRadius / 2), PlayerHarry.Location);

		PlayAnim(KillAnim,KillAnimRate);
		PlaySound(KillSound,SLOT_Interact,1.0,,TransientSoundRadius);

		Sleep(0.8);
		MOCAharry(PlayerHarry).ScreenFade(1.0,0.02);
		Sleep(2.0);
		ConsoleCommand("LoadGame 0");
}

state stateDie
{
	begin:
		StopMoving();
		TurnToward(PlayerHarry);
		PlayAnim(DieAnim,DieAnimRate);
		PlaySound(DieSound,SLOT_Talk,1.0,,TransientSoundRadius);
		FinishAnim();
		Sleep(0.2);
		Destroy();
}

state stateCooldown
{
	begin:
		StopMoving();
		Sleep(StalkCooldown);
		UpdateNodeViewDistance(0.0);
		GotoState('stateWait');
}


defaultproperties
{
	AngerRate=3.0
	RelaxRate=1.5
	RequiredAnger=25.0
	ChaseSpeed=400.0
	StalkCooldown=10.0
	MinDot=0.25
	ActiveRadius=163840.0

	ShadowClass=None
	SightRadius=512.0
	CollisionHeight=65.0
	bAdvancedTactics=True
	GroundSpeed=340.0
	MaxTravelDistance=163840.0
	WaitAnimRate=1.0
	SneakAnimRate=1.0
	RetreatAnimRate=1.0
	StareAnimRate=1.0
	AttackAnimRate=1.0
	KillAnimRate=1.0
	DieAnimRate=1.0
}