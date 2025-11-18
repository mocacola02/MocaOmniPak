class MOCAFlyingBook extends MOCAChar;

// TODO: Clean up

enum WakeMode
{
	WM_Always,
	WM_Proximity,
	WM_Trigger
};

var() byte SleepChance;			// Moca: How likely is the book to go back to its resting point when close to home? Higher = more likely. Only works if WM_Proximity. Def: 128

var() name FlySplineTag;
var() float AttackDistance;		// Moca: At what distance will the book start attacking? Def: 192.0
var() float AttackDelay;		// Moca: How long in seconds will the book wait before enabling attacking after it begins flying? Def: 5.0
var() float DamageAmount;		// Moca: How much damage will Harry take when hit? Def: 5.0
var() float StunDurationMult;	// Moca: How long will the book be stunned when hit? This works as a multiplier, 2.0 means twice as fast, 3.0 thrice as fast, etc. Def: 1.0
var() float HomeRange;			// Moca: How far from the book's starting point will the book detect its home? Used for going back to home. Def: 256.0
var() float WakeUpRange;		// Moca: How far can the book detect Harry to wake up? Only works if WM_Proximity. Def: 384.0

var() Sound FlySound;			// Moca: What sound to use as the flying sound? Def: Sound'HPSounds.Critters_sfx.PIX_wingflap_loop'
var() Sound ShootSound;

var() WakeMode WakeUpMode;		// Moca: What activates the book? WM_Always means always flying, WM_Proximity means Harry must get close enough based on WakeUpRange, WM_Trigger means it must be triggered. Def: WM_Proximity

// Not a fan of some of these bools, quick and sloppy fix for going home
var bool bGoingHome;
var bool bCanAttack;
var bool bCanGoHome;
var bool bHomeCheckCooldown;

var string PrevState;

var Vector ReturnLocation;
var Vector TempLocation;

var InterpolationPoint TargetIPoint;

var ESpellType DefVunSpell;

event PostBeginPlay()
{
	super.PostBeginPlay();
	DefVunSpell = eVulnerableToSpell;
}

event Trigger(Actor Other, Pawn Instigator)
{
    if (WakeUpMode == WM_Trigger && IsInState('stateIdle'))
    {
        GotoState('stateIdle', 'wakeup');
    }
	else if(WakeUpMode == WM_Trigger && !IsInState('stateIdle'))
	{
		bCanGoHome = True;
	}
}

function EnableAttacks();
function ShootPaper();

function ProcessSpell()
{
	if(!IsInState('stateIdle'))
	{
		GotoState('stateHit');
	}	
}

function SaveStartLocation()
{
	ReturnLocation = Location;
	Print(string(self) $ "'s start location saved as: " $ string(ReturnLocation));
}

exec function StopBook()
{
	SplineSpeed = 0;
}

function PlayFlapSound()
{
	PlaySound(FlySound,SLOT_None);
}

function bool CheckAttack()
{
	local float HarryDist;
	HarryDist = GetDistanceFromHarry();
	Print("Book's distance from Harry: " $ string(HarryDist));

	return (GetDistanceFromHarry() < AttackDistance);
}

function bool DetermineSleep()
{
	bHomeCheckCooldown = True;
	if (SleepChance < 255)
	{
		local int RandSleep;
		RandSleep = Rand(255);

		Print("We're checking to go home: " $ string(RandSleep) $ " Vs. " $ string(SleepChance));

		if (SleepChance >= RandSleep)
		{
			Print("Going home!");
			return true;
		}
	}
	else
	{
		Print("Going home!");
		return true;
	}
	
	Print("Not going home yet!");
	bCanGoHome = False;
	return false;
}

auto state stateIdle
{
	event BeginState()
	{
		eVulnerableToSpell = SPELL_None;
		
		if(WakeUpMode == WM_Always)
		{
			GotoState('stateFly');
		}
	}

	begin:
		bCanAttack = False;
		LoopAnim(IdleAnimName);

		if (isHarryNear(WakeUpRange) && WakeUpMode == WM_Proximity)
		{
			Goto('wakeup');
		}

		sleep(0.25);
		Goto('begin');

	wakeup:
		Print("Waking up");
		PlayAnim('takeoff',,,,'Move');
		FinishAnim();
		GotoState('stateFly');
}

state stateGoHome
{
	event BeginState()
	{
		bCanAttack = False;
		Print("Going home");
		LoopAnim(IdleAnimName,,2.0);
		SetPhysics(PHYS_Flying);
	}

	event Tick (float DeltaTime)
	{
		local vector Dir;
		local float DistanceFromStart;
		DistanceFromStart = VSize(ReturnLocation - Location);

		if (DistanceFromStart < 3.0 || bGoingHome)
		{
			bGoingHome = True;

			local float DistanceFromHome;
			DistanceFromHome = VSize(vHome - Location);

			if (DistanceFromHome < 3.0)
			{
				SetLocation(vHome);
				bGoingHome = False;
				GotoState('stateIdle');
			}
			else
			{
				Dir = Normal(vHome - Location);

				SetLocation(Location + Dir * AirSpeed * DeltaTime);
			}			
		}
		else
		{
			Dir = Normal(ReturnLocation - Location);

			SetLocation(Location + Dir * AirSpeed * DeltaTime);
		}		
	}
}

state stateFly
{
	event BeginState()
	{
		bCanGoHome = False;
		bHomeCheckCooldown = False;
		SetTimer(AttackDelay,false,'EnableAttacks');
		LoopAnim(WalkAnimName);
		eVulnerableToSpell = DefVunSpell;
		FollowSplinePath(FlySplineTag, [StartPointName] TargetIPoint.Name);
	}
	
	event EndState()
	{
		Super.EndState();
		TempLocation = Location;
		bCanAttack = False;
		AmbientSound = None;
		bCollideWorld = True;
		bAlignBottom = False;
		bCanGoHome = False;
		bHomeCheckCooldown = False;
		TargetIPoint = SplineManager.Dest;
		DestroyControllers();
		SetPhysics(PHYS_Flying);
	}

	event Tick (float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if (isHarryNear(AttackDistance) && bCanAttack)
		{
			GotoState('stateAttack');
		}

		if (bCanGoHome && !bHomeCheckCooldown && CloseToHome(HomeRange) && DetermineSleep() && WakeUpMode == WM_Proximity && !isHarryNear(AttackDistance))
		{
			GotoState('stateGoHome');
		}
		else if (!CloseToHome(HomeRange) && !bCanGoHome)
		{
			Print("Can now go home if close");
			bHomeCheckCooldown = False;
			bCanGoHome = True;
		}
	}

	function EnableAttacks()
	{
		bCanAttack = True;
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
		Super.EndState();
		DisableTurnTo();
	}

	function ShootPaper()
	{
		local MOCAPaperBall PaperBall;

		eVulnerableToSpell = DefVunSpell;
		PaperBall = Spawn(class'MOCAPaperBall',self,,Location,Rotation,true);
		PlaySound(ShootSound, SLOT_Misc);
		Spawn(class'Paper_Hit',self,,Location);
	}

	begin:
		PlayAnim('PrepAttack');
		FinishAnim();
		PlayAnim('attack');
		FinishAnim();

		if (CheckAttack())
		{
			Goto('begin');
		}

		GotoState('stateFly');
}

state stateHit
{
	event BeginState()
	{
		bCanAttack = True;
		eVulnerableToSpell = SPELL_None;
		hitsTaken++;
		EnableTurnTo(PlayerHarry);
		SetLocation(TempLocation);
	}

	event EndState()
	{
		Super.EndState();
		DisableTurnTo();
	}

	begin:
		Print("Previous state: " $ PreviousState);
		Print("Hits taken " $ string(hitsTaken) $ " out of " $ string(hitsToKill));
		if(PreviousState == 'stateFly')
		{
			if (hitsTaken >= hitsToKill)
			{
				GotoState('stateDie', 'fromfly');
			}
			else
			{
				PlayAnim('FlyStunned',StunDurationMult,,,'Move');
			}
		}
		else if(PreviousState == 'stateAttack')
		{
			if (hitsTaken >= hitsToKill)
			{
				GotoState('stateDie', 'fromattack');
			}
		}
		else
		{
			PlayAnim('AttackStunned',StunDurationMult,,,'Move');
		}

		FinishAnim();

		if (CheckAttack())
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

	event HitWall(vector vHitNormal, Actor Wall)
	{
		Print("BOOK HIT WALL, TIME TO DIE!!!!!!!!!!!!!!!!!!");
		GotoState('stateDie','die');
	}

	event Landed(vector HitNormal)
	{
		Print("BOOK LANDED, TIME TO DIE!!!!!!!!!!!!!!!!!!");
		GotoState('stateDie','die');
	}

	event Bump(Actor Other)
	{
		super.Bump(Other);
		if (Other.IsA('HPawn'))
		{
			if (HPawn(Other).bCantStandOnMe)
			{
				return;
			}
		}

		Print("BOOK BUMPED, TIME TO DIE!!!!!!!!!!!!!!!!");
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
	AnimSequence=Idle
	IdleAnimName=Idle
    WalkAnimName=Fly
	DrawScale=2
	Physics=PHYS_Flying

	eVulnerableToSpell=SPELL_Rictusempra
	
    Mesh=SkeletalMesh'MocaModelPak.skFlyingBookMesh'

	TransientSoundRadius=1024

    CollisionRadius=16.00
    CollisionHeight=24.00

	bAlignBottom=False
    bBlockActors=False

    RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	hitsToKill=3

	SleepChance=128
	AttackDistance=384
	AttackDelay=5.0
    DamageAmount=2.00
	StunDurationMult=1.0
	HomeRange=256
	FlySound=Sound'MocaSoundPak.book_flap_Multi'
	ShootSound=Sound'MocaSoundPak.book_flap_Multi'
	WakeUpMode=WM_Proximity
	WakeUpRange=384.0
}