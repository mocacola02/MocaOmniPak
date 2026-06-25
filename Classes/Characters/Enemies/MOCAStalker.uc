//================================================================================
// MOCAStalker.
//================================================================================
class MOCAStalker extends MOCANavigator;

var() float AngerRate;
var() float RelaxRate;
var() float MaxAnger;
var() float StareChance;
var() Range StareDuration;

var() name KillAnim;

var() Sound AttackSound;
var() Sound RetreatSound;
var() Sound KillSound;

var bool bAttacking;
var bool bSeen;
var bool bStaring;
var float CurrAnger;


event PostBeginPlay()
{
	if ( bDebugLogging )
	{
		local int i;
		local MOCAStalkerNode A;
		
		foreach AllActors(class'MOCAStalkerNode', A)
		{
			A.bHidden = False;
			i++;
		}

		DebugLog("Unhid " $ i $ " MOCAStalkerNodes since bDebugLogging = True");
	}
}

event Bump(Actor Other)
{
	if ( Other == PlayerHarry )
	{
		GotoState('stateKill');
	}
}

event Tick(float DeltaTime)
{
	if ( !IsInState('stateIdle') )
	{
		bSeen = CanHarrySeeMe(ViewDot);
		HandleSeen(bSeen, DeltaTime);

		if ( !IsHarryNear(ActivationRadius) )
		{
			GotoState('stateIdle');
		}
	}
}

function HandleSeen(bool bIsSeen, float DeltaTime)
{
	local float PrevAnger;
	PrevAnger = CurrAnger;

	if ( bIsSeen && bStaring )
	{
		CurrAnger += AngerRate * DeltaTime;	
	}
	else
	{
		CurrAnger -= RelaxRate * DeltaTime;
	}

	CurrAnger = FClamp(CurrAnger, 0.0, MaxAnger);

	if ( CurrAnger != PrevAnger )
	{
		DebugLog("CurrAnger changed to " $ CurrAnger);
	}
}

function SetStalkerNodes(bool bEnableNodes)
{
	local MOCAStalkerNode A;
	
	foreach AllActors(class'MOCAStalkerNode', A)
	{
		if ( bEnableNodes )
		{
			A.EnableNode();
		}
		else
		{
			A.DisableNode();
		}
	}
}

auto state stateIdle
{
	event BeginState()
	{
		CurrAnger = 0.0;
		LoopAnim(IdleAnimName);
	}

	event Tick(float DeltaTime);

	begin:
		StopMoving();

		while ( !IsHarryNear(ActivationRadius) || navP == None )
		{
			DebugLog("Idling");
			destP = GetValidDestinationTo(PlayerHarry.Location,,True);
			UpdateNavP();
			Sleep(1.0);
		}

		GotoState('stateStalk');
}

state stateStalk
{
	event BeginState()
	{
		if ( bAttacking )
		{
			DebugLog("Attacking");
			LoopAnim(RunAnimName);
			GroundSpeed = GroundRunSpeed;
			PlaySound(AttackSound, SLOT_Talk);
		}
		else
		{
			DebugLog("Stalking");
			LoopAnim(WalkAnimName);
			GroundSpeed = GroundWalkSpeed;
			SetStalkerNodes(True);
		}
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( bSeen && !bAttacking )
		{
			DebugLog("Retreating");
			GotoState('stateRetreat');
		}
	}

	begin:
		destP = GetValidDestinationTo(PlayerHarry.Location);
		UpdateNavP();

		SleepForTick();

		while ( navP != None && IsHarryNear(ActivationRadius) )
		{
			if ( FastViewCheck(PlayerHarry) )
			{
				DebugLog("Derailing");
				Goto('derail');
			}

			DebugLog("Pathing to Harry");
			StrafeFacing(navP.Location, PlayerHarry);

			destP = GetValidDestinationTo(PlayerHarry.Location);
			UpdateNavP();

			SleepForTick();
		}

		Goto('begin');
	
	derail:
		while ( FastViewCheck(PlayerHarry) )
		{
			DebugLog("Moving directly to Harry");
			StrafeFacing(PlayerHarry.Location, PlayerHarry);
			SleepForTick();
		}

		Goto('begin');
}

state stateRetreat
{
	event BeginState()
	{
		SetStalkerNodes(False);

		LoopAnim(RunAnimName);
		GroundSpeed = GroundRunSpeed;
		SetTimer(0.25, True);

		if ( RetreatSound != None )
		{
			PlaySound(RetreatSound, SLOT_Talk);
		}
	}

	event EndState()
	{
		SetTimer(0.0, False);
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( CurrAnger >= MaxAnger )
		{
			DebugLog("ANGERY!!!!!!!!!!!!!!!!!!!!!!!!");
			bAttacking = True;
			GotoState('stateStalk');
			return;
		}
	}

	event Timer()
	{
		if ( FRand() >= StareChance )
		{
			DebugLog("Random staring");
			GotoState('stateRetreat', 'stare');
		}
	}

	stare:
		DebugLog("Staring");
		bStaring = True;
		StopMoving();
		TurnToward(PlayerHarry);
		Sleep(RandRange(StareDuration.Min, StareDuration.Max));
		bStaring = False;

	loop:
		destP = GetFurthestNavPFromActor(PlayerHarry);
		UpdateNavP();

		while ( navP != None && IsHarryNear(ActivationRadius) )
		{
			DebugLog("Moving towards retreat");
			StrafeFacing(navP.Location, PlayerHarry);
			UpdateNavP();
			SleepForTick();
		}

		GotoState('stateCooldown');
}

state stateCooldown
{
	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( bSeen )
		{
			GotoState('stateRetreat');
		}
	}

	begin:
		DebugLog("Cooling down");
		
		while ( CurrAnger > 0.0 )
		{
			DebugLog("Still cooling down, anger is " $ CurrAnger);
			Sleep(1.0);
		}

		GotoState('stateStalk');
}

state stateKill
{
	event BeginState()
	{
		DebugLog("Damn, he ain't gonna be in Rush Hour 3");
		PlayerHarry.bKeepStationary = True;

		GroundSpeed = GroundWalkSpeed;
		PlayAnim(RunAnimName);
	}

	begin:
		StopMoving();
		StrafeFacing(Location - Vector(Rotation) * (PlayerHarry.CollisionRadius * 0.5), PlayerHarry);

		PlayAnim(KillAnim);

		if ( KillSound != None )
		{
			PlaySound(KillSound, SLOT_Interact);
		}

		Sleep(0.8);
		FadeScreen(1.0, 0.025);
		Sleep(2.0);
		ConsoleCommand("LoadGame 0");
}


defaultproperties
{
	AngerRate=1.0
	RelaxRate=1.0
	MaxAnger=5.0
	StareChance=0.075
	StareDuration=(Min=0.5,Max=1.5);
	KillAnim="Kill"
	
	AttackSound=Sound'MocaOmniResources.Creatures.bracken_angry'
	KillSound=Sound'MocaOmniResources.Creatures.bracken_kill'
	RetreatSound=Sound'MocaOmniResources.Creatures.bracken_retreat'

	ActivationRadius=163840.0
	MaxTravelDistance=163840.0

	CollisionHeight=60.0
	CollisionRadius=12.0

	DrawScale=1.2
	Mesh=SkeletalMesh'MocaOmniResources.skBracken'
	ShadowClass=None
	IdleAnimName="Idle"
	WalkAnimName="Sneak"
	RunAnimName="AttackWalk"

	GroundWalkSpeed=340.0
	GroundRunSpeed=400.0
}