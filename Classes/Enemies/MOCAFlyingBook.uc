//================================================================================
// MOCAFlyingBook.
//================================================================================
class MOCAFlyingBook extends MOCAChar;

enum WakeMode
{
	WM_Always,
	WM_Proximity,
	WM_Trigger
};

var() WakeMode WakeUpMode;		// Moca: What type of wake up mode to use? Def: WM_Proximity

var() byte SleepChance;			// Moca: How likely is the book likely to sleep when near home? Higher = More likely Def: 128
var() float HomeRange;			// Moca: How far do we considered our home area to be (from start location)? Def: 256.0
var() float WakeUpRange;		// Moca: How far can we be woken up from? Def: 384.0
var() float StunDurationMult;	// Moca: Rate of stun animation. Def: 1.0
var() float AttackDelay;		// Moca: How long of a delay between attacks? Def: 5.0

var() Sound FlySound;			// Moca: Sound to loop when flying? Def: Sound'MocaSoundPak.book_flap_Multi'
var() Sound ShootSound;			// Moca: Sound to play when shooting at Harry? Def: Sound'MocaSoundPak.book_flap_Multi'

var bool bCanGoHome;	// Can we go home
var bool bGoingHome;	// Are we going home
var bool bHomeCooldown;	// Are we in home cooldown (aka can't go back yet)

var Vector ReturnLocation;	// Return location before going to home location
var Vector TempLocation;	// Temporary location storage

var InterpolationPoint TargetIPoint;	// Target interpolation point


///////////
// Events
///////////

event Trigger(Actor Other, Pawn Instigator)
{
	// If we are WM_Trigger and are idle, wake up
	if ( WakeUpMode == WM_Trigger && IsInState('stateIdle') )
	{
		GotoState('stateIdle','wakeup');
	}
	// Otherwise, if we're WM_Trigger, set that we can go home
	else if ( WakeUpMode == WM_Trigger )
	{
		bCanGoHome = True;
	}
}


///////////////////
// Main Functions
///////////////////

function ShootPaper()
{
	local MOCAPaperBall PaperBall;
	// Spawn paper ball
	PaperBall = Spawn(class'MOCAPaperBall',Self,,Location,Rotation,True);
	// Play shoot sound
	PlaySound(ShootSound, SLOT_Talk);
	// Spawn paper particles
	Spawn(class'Paper_Hit',Self,,Location);
}


/////////////////////
// Helper Functions
/////////////////////

function PlayFlapSound()
{
	// Play flap sound. Duh
	PlaySound(FlySound,SLOT_Interact);
}

function bool CanSleep()
{
	// If we're not flying, we can't sleep
	if ( !IsInState('stateFlying') )
	{
		return False;
	}

	// Our sleep chance is less than 255 (aka not a 100% chance)
	if ( SleepChance < 255 )
	{
		// Get random int
		local int RandSleep;
		RandSleep = Rand(255);

		// Return true if our sleep chance is higher than the random int, otherwise false
		return SleepChance > RandSleep;
	}
	// Otherwise, we can always sleep
	else
	{
		return True;
	}
}


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		// Make us uncastable
		eVulnerableToSpell = SPELL_None;

		// If we should always fly, then fly
		if ( WakeUpMode == WM_Always )
		{
			GotoState('stateFly');
		}

		// Loop idle anim
		LoopAnim('Idle');
	}

	begin:
		// If proximity based and Harry is near, wake up
		if ( WakeUpMode == WM_Proximity && IsHarryNear(WakeUpRange) )
		{
			Goto('wakeup');
		}

		// Wait a quarter of a second then check again
		Sleep(0.25);
		Goto('begin');
	
	wakeup:
		// Play anim takeoff with Anim Move
		PlayAnim('takeoff',,,,'Move');
		FinishAnim();
		// Set return location to pre-fly location
		ReturnLocation = Location;
		// Go to fly
		GotoState('stateFly');
}

state stateGoHome
{
	event BeginState()
	{
		// Loop idle anim
		LoopAnim('Idle',,2.0);
		// Set physics to flying
		SetPhysics(PHYS_Flying);
	}

	event Tick(float DeltaTime)
	{
		local Vector Direction;
		local float DistanceFromReturn;
		// Get distance from return location
		DistanceFromReturn = VSize(ReturnLocation - Location);

		// When we're near the return point
		if ( DistanceFromReturn < 2.0 && bGoingHome )
		{
			local float DistanceFromHome;
			// Get distance from home location
			DistanceFromHome = VSize(HomeLocation - Location);

			// If we're close to home
			if ( DistanceFromHome < 2.0 )
			{
				// Set location to home location
				SetLocation(HomeLocation);
				// We're no longer going home
				bGoingHome = False;
				// Go to idle
				GotoState('stateIdle');
			}
			// Otherwise, keep moving towards home
			else
			{
				Direction = Normal(HomeLocation - Location);
				SetLocation(Location + Direction * AirSpeed * DeltaTime);
			}
		}
		// Otherwise, move to return location
		else
		{
			Direction = Normal(ReturnLocation - Location);
			SetLocation(Location + Direction * AirSpeed * DeltaTime);
		}
	}
}

state stateFly
{
	event BeginState()
	{
		// We can't go home right now
		bCanGoHome = False;
		// Set timer for attack delay
		SetTimer(AttackDelay,False);
		// Loop fly animation
		LoopAnim('Fly');
		// Make us castable
		eVulnerableToSpell = Default.eVulnerableToSpell;
		// Set us to follow spline
		FollowSplinePath(FlySplineTag, [StartPointName] TargetIPoint.Name);

		// If our previous state was idle, enable home cooldown
		if ( LastValidState == 'stateIdle' )
		{
			bHomeCooldown = True;
		}
	}

	event EndState()
	{
		// Temp location is our current location
		TempLocation = Location;
		// Disable ambient audio
		AmbientSound = None;
		// Enable world collision
		bCollideWorld = True;
		// Don't align bottom
		bAlignBottom = False;
		// We can't go home
		bCanGoHome = False;
		// Our target is the spline destination
		TargetIPoint = SplineManager.Dest;
		// Destroy flyto controllers
		DestroyControllers();
		// Set physics to flying
		SetPhysics(PHYS_Flying);
	}

	event Tick(float DeltaTime)
	{
		// If Harry is near, attack
		if ( IsHarryNear(AttackDistance) )
		{
			bHomeCooldown = False;
			GotoState('stateAttack');
		}

		// If we're out of the home range, disable cooldown
		if ( bHomeCooldown && HomeRange < VSize(HomeLocation - Location) )
		{
			bHomeCooldown = False;
		}

		// If we're close to home and we can sleep and we're proximity based and Harry isn't near
		if ( !bHomeCooldown && IsCloseToHome(HomeRange) && CanSleep() && WakeUpMode == WM_Proximity && !IsHarryNear(AttackDistance) )
		{
			GotoState('stateGoHome');
		}
	}
}

state stateAttack
{
	event BeginState()
	{
		// Turn to Harry and stay at temp location
		EnableTurnTo(PlayerHarry);
		SetLocation(TempLocation);
	}

	event EndState()
	{
		// Disable turn to
		DisableTurnTo();
	}

	begin:
		// When book is closed, can't be hit!
		eVulnerableToSpell = SPELL_None;
		// Play prep attack anim (book closes)
		PlayAnim('PrepAttack');
		FinishAnim();

		// Be castable again as we reopen
		eVulnerableToSpell = Default.eVulnerableToSpell;
		// Play attack anim (book opens), we shoot based off of anim notify
		PlayAnim('attack');
		FinishAnim();

		// Delay next attack
		Sleep(AttackDelay);

		// If Harry is still near, shoot again
		if ( IsHarryNear(AttackDistance) )
		{
			Goto('begin');
		}

		// Otherwise, keep flying
		GotoState('stateFly');
}

state stateHit
{
	event BeginState()
	{
		// Make us uncastable
		eVulnerableToSpell = SPELL_None;
		// Increase hits taken
		HitsTaken++;
		// Turn to Harry
		EnableTurnTo(PlayerHarry);
		// Stay at temp location
		SetLocation(TempLocation);
	}

	event EndState()
	{
		// Disable turn to
		DisableTurnTo();
	}

	begin:
		// If last state was fly
		if( LastValidState == 'stateFly' )
		{
			// If we should die, then die from fly
			if ( HitsTaken >= HitsToKill )
			{
				GotoState('stateDie','fromfly');
			}
			// Otherwise, fly stun
			else
			{
				PlayAnim('FlyStunned',StunDurationMult,,,'Move');
			}
		}
		// If last state was attack
		else if ( LastValidState == 'stateAttack' )
		{
			// If we should die, then die from attack
			if ( HitsTaken >= HitsToKill )
			{
				GotoState('stateDie','fromattack');
			}
		}
		// Otherwise, attack stunned
		else
		{
			PlayAnim('AttackStunned',StunDurationMult,,,'Move');
		}

		// Finish anim
		FinishAnim();

		// If harry is near, attack again
		if ( IsHarryNear(AttackDistance) )
		{
			GotoState('stateAttack');
		}

		// Otherwise, go to fly
		GotoState('stateFly');
}

state stateDie
{
	event BeginState()
	{
		// Stay at temp location
		SetLocation(TempLocation);
	}

	event HitWall(Vector HitNormal, Actor Wall)
	{
		// If hit wall, finally die
		GotoState('stateDie','die');
	}

	event Landed(Vector HitNormal)
	{
		// If landed, finally die
		GotoState('stateDie','die');
	}

	event Bump(Actor Other)
	{
		Super.Bump(Other);

		// If other is a HPawn
		if ( Other.IsA('HPawn') )
		{
			// If we can't stand on HPawn, ignore it
			if ( HPawn(Other).bCantStandOnMe )
			{
				return;
			}
		}

		// Otherwise, finally die
		GotoState('stateDie','die');
	}

	die:
		// Play fall death anim
		PlayAnim('FallDie');
		FinishAnim();

		// Loop rest anim for 1 second then destroy
		LoopAnim('rest');
		Sleep(1.0);
		Destroy();
	
	fromfly:
		// Go from fly to die anim, then fall
		PlayAnim('Fly2Die',,,,'Move');
		Goto('fall');
	
	fromattack:
		// Go from attack to die anim, then fall
		PlayAnim('Attack2Die',,,,'Move');
		Goto('fall');
	
	fall:
		// Finish anim
		FinishAnim();
		// Go to walking so we fall
		SetPhysics(PHYS_Walking);
		// Go to fall anim
		PlayAnim('Die2Fall');
		FinishAnim();
		// Loop fall
		LoopAnim('fall');
}

defaultproperties
{
	AirSpeed=160.0
	DrawScale=2.0
	Physics=PHYS_Flying

	eVulnerableToSpell=SPELL_Rictusempra

	Mesh=SkeletalMesh'MocaModelPak.skFlyingBookMesh'

	TransientSoundRadius=1024.0

	CollisionRadius=16.0
	CollisionHeight=24.0

	bAlignBottom=False
	bBlockActors=False

	RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	HitsToKill=3

	SleepChance=128
	AttackDistance=384.0
	AttackDelay=5.0
	StunDurationMult=1.0
	HomeRange=256.0
	FlySound=Sound'MocaSoundPak.book_flap_Multi'
	ShootSound=Sound'MocaSoundPak.book_flap_Multi'
	WakeUpMode=WM_Proximity
	WakeUpRange=384.0
}