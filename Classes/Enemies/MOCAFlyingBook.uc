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

var() WakeMode WakeUpMode;

var() byte SleepChance;
var() float HomeRange;
var() float WakeUpRange;
var() float StunDurationMult;
var() float AttackDelay;

var(MOCAFlyingBookSFX) Sound FlySound;
var(MOCAFlyingBookSFX) Sound ShootSound;

var bool bCanGoHome;
var bool bGoingHome;
var bool bHomeCooldown;

var Vector ReturnLocation;
var Vector TempLocation;

var InterpolationPoint TargetIPoint;


///////////
// Events
///////////

event Trigger(Actor Other, Pawn Instigator)
{
	if ( WakeUpMode == WM_Trigger && IsInState('stateIdle') )
	{
		GotoState('stateIdle','wakeup');
	}
	else if ( WakeUpMode == WM_Trigger && !IsInState('stateIdle') )
	{
		bCanGoHome = True;
	}
}


function PlayFlapSound()
{
	PlaySound(FlySound,SLOT_Interact);
}

function bool CanSleep()
{
	if ( !IsInState('stateFlying') )
	{
		return False;
	}

	if ( SleepChance < 255 )
	{
		local int RandSleep;
		RandSleep = Rand(255);

		return SleepChance > RandSleep;
	}
	else
	{
		return True;
	}
}

function ShootPaper()
{
	local MOCAPaperBall PaperBall;
	PaperBall = Spawn(class'MOCAPaperBall',Self,,Location,Rotation,True);
	PlaySound(ShootSound, SLOT_Talk);
	Spawn(class'Paper_Hit',Self,,Location);
}


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		eVulnerableToSpell = SPELL_None;

		if ( WakeUpMode == WM_Always )
		{
			GotoState('stateFly');
		}

		LoopAnim('Idle');
	}

	begin:
		if ( WakeUpMode == WM_Proximity && IsHarryNear(WakeUpRange) )
		{
			Goto('wakeup');
		}

		Sleep(0.25);
		Goto('begin');
	
	wakeup:
		PlayAnim('takeoff',,,,'Move');
		FinishAnim();
		ReturnLocation = Location;
		GotoState('stateFly');
}

state stateGoHome
{
	event BeginState()
	{
		LoopAnim('Idle',,2.0);
		SetPhysics(PHYS_Flying);
	}

	event Tick(float DeltaTime)
	{
		local Vector Direction;
		local float DistanceFromReturn;
		DistanceFromReturn = VSize(HomeLocation - Location);

		// When we're near the return point
		if ( DistanceFromReturn < 2.0 && bGoingHome )
		{
			local float DistanceFromHome;
			DistanceFromHome = VSize(HomeLocation - Location);

			// If we're close to home
			if ( DistanceFromHome < 2.0 )
			{
				SetLocation(HomeLocation);
				bGoingHome = False;
				GotoState('stateIdle');
			}
			else
			{
				Direction = Normal(HomeLocation - Location);
				SetLocation(Location + Direction * AirSpeed * DeltaTime);
			}
		}
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
		bCanGoHome = False;
		SetTimer(AttackDelay,False);
		LoopAnim('Fly');
		eVulnerableToSpell = Default.eVulnerableToSpell;
		FollowSplinePath(FlySplineTag, [StartPointName] TargetIPoint.Name);

		if ( LastValidState == 'stateIdle' )
		{
			bHomeCooldown = True;
		}
	}

	event EndState()
	{
		TempLocation = Location;
		AmbientSound = None;
		bCollideWorld = True;
		bAlignBottom = False;
		bCanGoHome = False;
		TargetIPoint = SplineManager.Dest;
		DestroyControllers();
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
		EnableTurnTo(PlayerHarry);
		SetLocation(TempLocation);
	}

	event EndState()
	{
		DisableTurnTo();
	}

	begin:
		eVulnerableToSpell = SPELL_None;
		PlayAnim('PrepAttack');
		FinishAnim();

		eVulnerableToSpell = Default.eVulnerableToSpell;
		PlayAnim('attack');
		FinishAnim();

		if ( IsHarryNear(AttackDistance) )
		{
			Goto('begin');
		}

		GotoState('stateFly');
}

state stateHit
{
	event BeginState()
	{
		eVulnerableToSpell = SPELL_None;
		HitsTaken++;
		EnableTurnTo(PlayerHarry);
		SetLocation(TempLocation);
	}

	event EndState()
	{
		DisableTurnTo();
	}

	begin:
		if( LastValidState == 'stateFly' )
		{
			if ( HitsTaken >= HitsToKill )
			{
				GotoState('stateDie','fromfly');
			}
			else
			{
				PlayAnim('FlyStunned',StunDurationMult,,,'Move');
			}
		}
		else if ( LastValidState == 'stateAttack' )
		{
			if ( HitsTaken >= HitsToKill )
			{
				GotoState('stateDie','fromattack');
			}
		}
		else
		{
			PlayAnim('AttackStunned',StunDurationMult,,,'Move');
		}

		FinishAnim();

		if ( IsHarryNear(AttackDistance) )
		{
			GotoState('stateAttack');
		}

		GotoState('stateFly');
}

state stateDie
{
	event BeginState()
	{
		SetLocation(TempLocation);
	}

	event HitWall(Vector HitNormal, Actor Wall)
	{
		GotoState('stateDie','die');
	}

	event Landed(Vector HitNormal)
	{
		GotoState('stateDie','die');
	}

	event Bump(Actor Other)
	{
		Super.Bump(Other);

		if ( Other.IsA('HPawn') )
		{
			if ( HPawn(Other).bCantStandOnMe )
			{
				return;
			}
		}

		GotoState('stateDie','die');
	}

	die:
		PlayAnim('FallDie');
		FinishAnim();

		LoopAnim('rest');
		Sleep(1.0);
		Destroy();
	
	fromfly:
		PlayAnim('Fly2Die',,,,'Move');
		Goto('fall');
	
	fromattack:
		PlayAnim('Attack2Die',,,,'Move');
		Goto('fall');
	
	fall:
		FinishAnim();
		SetPhysics(PHYS_Walking);
		PlayAnim('Die2Fall');
		FinishAnim();
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