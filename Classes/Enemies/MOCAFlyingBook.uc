class MOCAFlyingBook extends MOCAChar;

enum WakeMode
{
	WM_Always,
	WM_Proximity,
	WM_Trigger
};

var() byte SleepChance;

var() float AttackDistance;
var() float AttackDelay;
var() float DamageAmount;
var() float StunDurationMult;
var() float HomeRange;
var() float WakeUpRange;

var() Sound FlySound;

var() WakeMode WakeUpMode;

// Not a fan of some of these bools, quick and sloppy fix for going home
var bool GoingHome;
var bool CanAttack;
var bool CanGoHome;
var bool HomeCheckCooldown;

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
	if (MocaDebugMode)
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
	HomeCheckCooldown = True;
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

		if (DistanceFromStart < 3.0 || GoingHome)
		{
			GoingHome = True;

			local float DistanceFromHome;
			DistanceFromHome = VSize(vHome - Location);

			if (DistanceFromHome < 3.0)
			{
				SetLocation(vHome);
				GoingHome = False;
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
		CanGoHome = False;
		CanAttack = False;
		HomeCheckCooldown = False;
		SetTimer(AttackDelay,false,'EnableAttacks');
		LoopAnim(WalkAnimName);
		AmbientSound = FlySound;
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
	}
	
	event EndState()
	{
		CanAttack = False;
		DestroyControllers();
		AmbientSound = None;
		SetPhysics(PHYS_Flying);
		bCollideWorld = True;
		bAlignBottom = False;
		CanGoHome = False;
		HomeCheckCooldown = False;
	}

	event Tick (float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if (isHarryNear(AttackDistance) && CanAttack)
		{
			GotoState('stateAttack');
		}

		if (CanGoHome && !HomeCheckCooldown && CloseToHome(HomeRange) && DetermineSleep() && WakeUpMode == WM_Proximity && !isHarryNear(AttackDistance))
		{
			GotoState('stateGoHome');
		}
		else if (!CloseToHome(HomeRange) && !CanGoHome)
		{
			Print("Can now go home if close");
			HomeCheckCooldown = False;
			CanGoHome = True;
		}
	}

	function EnableAttacks()
	{
		CanAttack = True;
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