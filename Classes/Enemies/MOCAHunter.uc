//================================================================================
// MOCAHunter.
//================================================================================

class MOCAHunter extends MOCAChar;

var() bool bNeverSleep;
var() int MaxChaseAttempts;
var() float WakeUpDistance;
var() float HomeRadius; //200
var() float ChaseSpeed;

var(MOCAHunterAnims) name IdleAnim;
var(MOCAHunterAnims) name SleepAnim;
var(MOCAHunterAnims) name WalkAnim;
var(MOCAHunterAnims) name AwakenAnim;
var(MOCAHunterAnims) name CaughtAnim;
var(MOCAHunterAnims) name CaughtTransAnim;

var(MOCAHunterSFX) Sound CaughtSound;

var bool bCorrectingPath;

var int ChaseAttempts;

var NavigationPoint RandNavP;


event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( !ActorExistenceCheck(Class'PathNode') || !ActorExistenceCheck(Class'MOCAharry') )
	{
		EnterErrorMode("MOCAHunter actors (such as MOCAWatcherHunter) require PathNodes and MOCAharry.");
	}

	if ( bNeverSleep )
	{
		GotoState('stateIdle');
	}
}

event Bump(Actor Other)
{
	Super.Bump(Other);

	if ( !IsInState('stateAsleep') && !PlayerHarry.IsInState('stateCaught') && Other == PlayerHarry )
	{
		PlayerHarry.GetCaught();
		GotoState('stateCatch');
	}
}

event HitWall(vector HitNormal, actor HitWall)
{
	Super.HitWall(HitNormal,HitWall);

	if ( !bCorrectingPath )
	{
		bCorrectingPath = True;
		GotoState('stateIdle','gosomewhere');
	}
}

function ProcessSpell()
{
	if ( !IsInState('stateHitBySpell') )
	{
		GotoState('stateHitBySpell');
	}
}

function float GetWalkSpeed()
{
	return GroundSpeed / MapDefault.GroundSpeed;
}

auto state stateSleep
{
	begin:
		eVulnerableToSpell = SPELL_None;
		LoopAnim(SleepAnim);
		Goto('loop');
	
	loop:
		if ( IsHarryNear(WakeUpDistance) || bNeverSleep == True )
		{
			GotoState('stateIdle','awaken');
		}

		Sleep(0.5);
		Goto('loop');
}

state stateIdle
{
	event Tick(float DeltaTime)
	{
		if( CanISeeHarry(0.25,True) )
		{
			prevNavP = navP;
			GotoState('stateChase');
		}
	}

	begin:
		GroundSpeed = MapDefault.GroundSpeed;
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;

		LoopAnim(IdleAnim);

		if ( LastValidState == 'stateSleep' )
		{
			TurnTo(LastHarryLocation);
		}

		Sleep(RandRange(0.75,2.0));

		if ( !CloseToHome(MaxTravelDistance) )
		{
			Goto('gohome');
		}
		else
		{
			Goto('gosomewhere');
		}
	
	gosomewhere:
		LoopAnim(WalkAnim);
		RandNavP = FindRandomDest();
		navP = NavigationPoint(FindPathToward(RandNavP));

		while ( navP != RandNavP && navP != None )
		{
			MoveToward(navP);
			navP = NavigationPoint(FindPathToward(RandNavP));
			SleepForTick();
		}

		goto('begin');
	
	gohome:
		LoopAnim(WalkAnim);
		navP = NavigationPoint(FindPathTo(HomeLocation));

		while ( !CloseToHome(HomeRadius) && navP != None && navP != prevNavP )
		{
			MoveToward(navP);
			navP = NavigationPoint(FindPathTo(HomeLocation));
			SleepForTick();
		}

		goto('begin');
	
	awaken:
		PlayAnim(AwakenAnim,,,,'Move');
		FinishAnim();
		Goto('begin');
}

state stateChase
{
	event BeginState()
	{
		GroundSpeed = ChaseSpeed;
		LoopAnim(WalkAnim,GetWalkSpeed());
		SetTimer(1.0,True);
	}

	event EndState()
	{
		GroundSpeed = MapDefault.GroundSpeed;
	}

	event Timer()
	{
		if ( !CanISeeHarry(0.25,True) )
		{
			ChaseAttempts++;
			if ( ChaseAttempts >= MaxChaseAttempts )
			{
				GotoState('stateIdle');
			}
		}
	}

	event AlterDestination()
	{
		Super.AlterDestination();

		if ( CanISeeHarry(0.25,True) )
		{
			ChaseAttempts = 0;
		}
	}

	begin:
		navP = NavigationPoint(FindPathToward(PlayerHarry));

		while ( navP != None && ChaseAttempts < MaxChaseAttempts )
		{
			MoveToward(navP);

			if ( ChaseAttempts > Round(MaxChaseAttempts * 0.667) )
			{
				navP = NavigationPoint(FindPathTo(GetNearbyNavPInView(SightRadius)));
			}
			else
			{
				navP = NavigationPoint(FindPathToward(PlayerHarry));
			}

			SleepForTick();
		}

		GotoState('stateIdle');
}

state stateDerailed
{
	event EndState()
	{
		GroundSpeed = MapDefault.GroundSpeed;
	}

	begin:
		GroundSpeed = ChaseSpeed;

		while( CanISeeHarry(0.25,True) )
		{
			MoveToward(PlayerHarry);
			SleepForTick();
		}

		GotoState('stateChase');
}

state stateCatch
{
	begin:
		StopMoving();
		TurnToward(PlayerHarry);
		PlaySound(CaughtSound);

		if ( CaughtTransAnim != '' )
		{
			PlayAnim(CaughtTransAnim,4.0);
			FinishAnim();
		}

		LoopAnim(CaughtAnim);
		Sleep(3.0);
		SetLocation(HomeLocation);
		GotoState('stateIdle');
}

defaultproperties
{
	ChaseSpeed=230.0
	WakeUpDistance=400.0

	bTiltOnMovement=False
	HitsToKill=3

	bAdvancedTactics=True
	CollisionHeight=65.0
	CollisionRadius=15.0
	GroundSpeed=100.0
	ShadowScale=0.5
	SightRadius=2500.0
	RotationRate=(Pitch=4096,Yaw=100000,Roll=3072)
	eVulnerableToSpell=SPELL_None
}