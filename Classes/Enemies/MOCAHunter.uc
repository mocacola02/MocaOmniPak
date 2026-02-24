//================================================================================
// MOCAHunter.
//================================================================================
class MOCAHunter extends MOCAChar;

var() bool bNeverSleep;		// Should we never sleep? Def: False
var() int MaxChaseAttempts;	// Make attempts to find Harry after losing him in a chase. Def: 3
var() float WakeUpDistance;	// Distance we can be woken up from. Def: 400.0
var() float ChaseSpeed;		// Speed during a chase. Def: 230.0

var bool bCorrectingPath;	// Are we correcting our path
var int ChaseAttempts;		// Current chase attempts

var name IdleAnim;			// Idle animation
var name SleepAnim;			// Sleep animation
var name WalkAnim;			// Walk animation
var name AwakenAnim;		// Awaken animation
var name CaughtAnim;		// Caught animation
var name CaughtTransAnim;	// Caught transition animation

var Sound CaughtSound;			// Sound when catching Harry
var NavigationPoint RandNavP;	// Random navigation point


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If there are no path nodes or MOCAharry, yell at mapper
	if ( !DoesActorExist(Class'PathNode') || !DoesActorExist(Class'MOCAharry') )
	{
		PushError("MOCAHunter actors (such as MOCAWatcherHunter) require PathNodes and MOCAharry.");
	}
}

event Bump(Actor Other)
{
	Super.Bump(Other);

	// If we aren't asleep & 
	if ( !IsInState('stateAsleep') && !PlayerHarry.IsInState('stateCaught') && Other.IsA('MOCAharry') )
	{
		MOCAharry(PlayerHarry).GetCaught(Self,Event);
		GotoState('stateCatch');
	}
}

event HitWall(vector HitNormal, actor HitWall)
{
	Super.HitWall(HitNormal,HitWall);

	// If not correcting path, make it so we are and try to find a place to correct to
	if ( !bCorrectingPath )
	{
		bCorrectingPath = True;
		GotoState('stateIdle','gosomewhere');
	}
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	// If asleep, wake up
	if ( IsInState('stateAsleep') )
	{
		GotoState('stateIdle','awaken');
	}
	// If not asleep, go home
	else
	{
		GotoState('stateIdle','gohome');
	}
}

///////////////////
// Functions
///////////////////

function ProcessSpell()
{
	// If we aren't getting hit by a spell, get hit by one
	if ( !IsInState('stateHitBySpell') )
	{
		GotoState('stateHitBySpell');
	}
}

function float GetWalkSpeed()
{
	// Get speed rate from current speed over default speed
	return GroundSpeed / MapDefault.GroundSpeed;
}


///////////
// States
///////////

auto state stateSleep
{
	begin:
		// Be uncastable while sleeping
		eVulnerableToSpell = SPELL_None;
		// Loop sleep anim
		LoopAnim(SleepAnim);
	
	loop:
		// If Harry is near or we never sleep, wake up
		if ( IsHarryNear(WakeUpDistance) || bNeverSleep == True )
		{
			GotoState('stateIdle','awaken');
		}

		// Otherwise, wait half a second and check again
		Sleep(0.5);
		Goto('loop');
}

state stateIdle
{
	event Tick(float DeltaTime)
	{
		// If we see Harry, store current destination as previous and chase Harry
		if( CanISeeHarry(0.25,True) )
		{
			LastNavP = navP;
			GotoState('stateChase');
		}
	}

	begin:
		// Make sure we're walking at normal speed
		GroundSpeed = MapDefault.GroundSpeed;
		// Make us castable
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;

		// Loop idle anim
		LoopAnim(IdleAnim);

		// If we were previously asleep, turn to Harry's location (aka our stimulus)
		if ( LastValidState == 'stateSleep' )
		{
			TurnTo(LastHarryLocation);
		}

		// Wait for a small bit
		Sleep(RandRange(0.75,2.0));

		// If we're far from home, go home
		if ( !CloseToHome() )
		{
			Goto('gohome');
		}
		// Otherwise, wander somewhere
		else
		{
			Goto('gosomewhere');
		}
	
	gosomewhere:
		// Loop walk anim
		LoopAnim(WalkAnim);
		// Get random destination
		RandNavP = FindRandomDest();
		// Find path to our random destination
		navP = NavigationPoint(FindPathToward(RandNavP));

		// While we have a valid navP
		while ( navP != RandNavP && navP != None )
		{
			// Move toward navP
			MoveToward(navP);
			// Find next path to destination
			navP = NavigationPoint(FindPathToward(RandNavP));
			// Sleep for a tick
			SleepForTick();
		}

		// Once there, go back to idle start
		goto('begin');
	
	gohome:
		// Loop walk anim
		LoopAnim(WalkAnim);
		// Find path to home location
		navP = NavigationPoint(FindPathTo(HomeLocation));

		// While we're not in the inner radius of our home and we have a valid navP
		while ( !CloseToHome(MaxTravelDistance * 0.5) && navP != None && navP != LastNavP )
		{
			// Move toward navP
			MoveToward(navP);
			// Find next path to destination
			navP = NavigationPoint(FindPathTo(HomeLocation));
			// Sleep for a tick
			SleepForTick();
		}

		// Once there, go back to idle start
		goto('begin');
	
	awaken:
		// Play wake up anim with Anim Move
		PlayAnim(AwakenAnim,,,,'Move');
		// Finish anim
		FinishAnim();
		// Go to idle start
		Goto('begin');
}

state stateChase
{
	event BeginState()
	{
		// Change speed to chase speed
		GroundSpeed = ChaseSpeed;
		// Loop walk anim but adjust for our new speed
		LoopAnim(WalkAnim,GetWalkSpeed());
		// Set "can see harry" timer
		SetTimer(1.0,True);
	}

	event EndState()
	{
		// Reset our speed
		GroundSpeed = MapDefault.GroundSpeed;
	}

	event Timer()
	{
		// If we can't see harry
		if ( !CanISeeHarry(0.25,True) )
		{
			// Increase chase attempt
			ChaseAttempts++;
			// If exceeded max attempts, go to idle
			if ( ChaseAttempts >= MaxChaseAttempts )
			{
				GotoState('stateIdle');
			}
		}
	}

	event AlterDestination()
	{
		Super.AlterDestination();

		// If we see Harry, reset chase attempts and derail
		if ( CanISeeHarry(0.25,True) )
		{
			ChaseAttempts = 0;
			GotoState('stateDerailed');
		}
	}

	begin:
		// Get path to Harry
		navP = NavigationPoint(FindPathToward(PlayerHarry));

		// While valid navP and we haven't run out of chase attempts
		while ( navP != None && ChaseAttempts < MaxChaseAttempts )
		{
			// Move toward navP
			MoveToward(navP);

			// If we're running out of chase attempts, guess which navP Harry *might* have gone to
			if ( ChaseAttempts > Round(MaxChaseAttempts * 0.667) )
			{
				navP = NavigationPoint(FindPathToward(GetNearbyNavPInView(SightRadius)));
			}
			// Otherwise, follow Harry's trail
			else
			{
				navP = NavigationPoint(FindPathToward(PlayerHarry));
			}

			// Sleep for a tick
			SleepForTick();
		}

		// Go to idle
		GotoState('stateIdle');
}

state stateDerailed
{
	begin:
		// Make sure we're at chase speed
		GroundSpeed = ChaseSpeed;

		// While we see Harry, move towards him directly
		while( CanISeeHarry(0.25,True) )
		{
			MoveToward(PlayerHarry);
			SleepForTick();
		}

		// Otherwise, go back to path-based chase
		GotoState('stateChase');
}

state stateCatch
{
	begin:
		// Stop moving
		StopMoving();
		// Turn toward harry
		TurnToward(PlayerHarry);
		// Play caught sound
		PlaySound(CaughtSound);

		// Play caught transition anim
		if ( CaughtTransAnim != '' )
		{
			PlayAnim(CaughtTransAnim,4.0);
			FinishAnim();
		}

		// Loop caught anim
		LoopAnim(CaughtAnim);
		Sleep(3.0);
		// Go home and idle
		SetLocation(HomeLocation);
		GotoState('stateIdle');
}

defaultproperties
{
	MaxChaseAttempts=3
	ChaseSpeed=230.0
	WakeUpDistance=400.0

	bTiltOnMovement=False
	MaxTravelDistance=1024.0
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