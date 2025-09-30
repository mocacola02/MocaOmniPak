class MOCAFlyingBook extends MOCAChar;

enum WakeMode
{
	WM_Always,
	WM_Proximity,
	WM_Trigger
};

var() byte SleepChance;			// Moca: How likely is the book to go back to its resting point when close to home? Higher = more likely. Only works if WM_Proximity. Def: 128

var() float AttackDistance;		// Moca: At what distance will the book start attacking? Def: 192.0
var() float AttackDelay;		// Moca: How long in seconds will the book wait before enabling attacking after it begins flying? Def: 5.0
var() float DamageAmount;		// Moca: How much damage will Harry take when hit? Def: 5.0
var() float StunDurationMult;	// Moca: How long will the book be stunned when hit? This works as a multiplier, 2.0 means twice as fast, 3.0 thrice as fast, etc. Def: 1.0
var() float HomeRange;			// Moca: How far from the book's starting point will the book detect its home? Used for going back to home. Def: 256.0
var() float WakeUpRange;		// Moca: How far can the book detect Harry to wake up? Only works if WM_Proximity. Def: 384.0

var() Sound FlySound;			// Moca: What sound to use as the flying sound? Def: Sound'HPSounds.Critters_sfx.PIX_wingflap_loop'

var() WakeMode WakeUpMode;		// Moca: What activates the book? WM_Always means always flying, WM_Proximity means Harry must get close enough based on WakeUpRange, WM_Trigger means it must be triggered. Def: WM_Proximity

// Not a fan of some of these bools, quick and sloppy fix for going home
var bool bGoingHome;
var bool bCanAttack;
var bool bCanGoHome;
var bool bHomeCheckCooldown;

var Vector ReturnLocation;

event PostBeginPlay()
{
	super.PostBeginPlay();

	if (WakeUpMode == WM_Always)
	{
		GotoState('stateFly');
	}
}

function EnableAttacks();
function ShootPaper();

function ProcessSpell()
{
	GotoState('stateHit');
}

function SaveStartLocation()
{
	ReturnLocation = Location;
	if (bMocaDebugMode)
	{
		Log(string(self) $ "'s start location saved as: " $ string(ReturnLocation));
	}
}

function bool CheckAttack()
{
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
	begin:
		LoopAnim(IdleAnimName);

		if (isHarryNear(WakeUpRange))
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
		bCanAttack = False;
		bHomeCheckCooldown = False;
		SetTimer(AttackDelay,false,'EnableAttacks');
		LoopAnim(WalkAnimName);
		AmbientSound = FlySound;
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
	}
	
	event EndState()
	{
		bCanAttack = False;
		DestroyControllers();
		AmbientSound = None;
		SetPhysics(PHYS_Flying);
		bCollideWorld = True;
		bAlignBottom = False;
		bCanGoHome = False;
		bHomeCheckCooldown = False;
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
	
	begin:
		FollowSplinePath(Tag);
}

state stateAttack
{
	event BeginState()
	{
		EnableTurnTo(PlayerHarry);
	}

	event EndState()
	{
		DisableTurnTo();
	}

	function ShootPaper()
	{
		local MOCAPaperBall PaperBall;

		PaperBall = Spawn(class'MOCAPaperBall',self,,Location,Rotation,true);
		Spawn(class'Paper_Hit',self,,Location);
	}

	begin:
		PlayAnim('PrepAttack');
		FinishAnim();
		PlayAnim('attack');
		ShootPaper();

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
		DestroyControllers();
		eVulnerableToSpell = SPELL_None;
		hitsTaken++;
		EnableTurnTo(PlayerHarry);
	}

	event EndState()
	{
		DisableTurnTo();
	}

	begin:
		if(PreviousState == 'stateFly')
		{
			if (hitsTaken >= hitsToKill)
			{

			}
			PlayAnim('FlyStunned',StunDurationMult,,,'Move');
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

    SoundRadius=75

    CollisionRadius=8.00
    CollisionHeight=16.00

	bAlignBottom=False
    bBlockActors=False

    RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	hitsToKill=3

	SleepChance=128
	AttackDistance=192
	AttackDelay=5.0
    DamageAmount=2.00
	StunDurationMult=1.0
	HomeRange=256
	FlySound=Sound'HPSounds.Critters_sfx.PIX_wingflap_loop'
	WakeUpMode=WM_Proximity
	WakeUpRange=384.0
}