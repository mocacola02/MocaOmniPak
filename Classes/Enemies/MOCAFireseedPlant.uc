//================================================================================
// MOCAFireseedPlant. Not amazing but better than the pre-3.0 version
//================================================================================

class MOCAFireseedPlant extends MOCAChar;

var() bool bAlwaysAttack;

var() float AttackDistance;
var() float FireCooldown;
var() float FireLaunchSpeed;

var() Vector FireOffset;


var bool bIsAttacking;
var float CurrentCooldown;
var float RangeIntensity;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();
	CurrentCooldown = FireCooldown;
}


////////////////////
// Spawn Functions
////////////////////

function SpawnSmoke()
{
	Spawn(Class'SmokePuff');
	Spawn(Class'SmokeShoot');
}

function SpawnFire()
{
	local Rotator FireRotation;
	local MOCAFireBall NewFireBall;

	FireRotation = Rotation;
	FireRotation.Pitch += 16384;

	Spawn(Class'SmokePuff');
	NewFireBall = Spawn(Class'MOCAFireBall',Self,,Location + FireOffset,FireRotation);
	NewFireBall.LaunchSpeed = FireLaunchSpeed;

	RangeIntensity = GetDistanceFromHarry() / 200;
	NewFireBall.HomingStrength *= RangeIntensity;
}


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		if ( bAlwaysAttack )
		{
			GotoState('stateFire');
		}

		LoopAnim('Idle');
		SetTimer(0.5,True);
	}

	event Timer()
	{
		if ( GetDistanceFromHarry() < DistanceToAttack )
		{
			GotoState('stateFire');
		}
	}

	begin:
		Sleep(RandRange(2.0,16.0));
		GotoState('statePuff');
}

state statePuff
{
	begin:
		PlayAnim('gasventstart');
		Sleep(0.2);
		SpawnSmoke();
		FinishAnim();

		PlayAnim('gasventend');
		FinishAnim();

		GotoState('stateIdle');
}

state stateFire
{
	event BeginState()
	{
		bIsAttacking = True;
	}

	event EndState()
	{
		bIsAttacking = False;
		CurrentCooldown = 0.0;
	}

	event Tick(float DeltaTime)
	{
		CurrentCooldown += DeltaTime;
	}

	begin:
		if ( CurrentCooldown < FireCooldown )
		{
			SleepForTick();
			Goto('begin');
		}
		else
		{
			CurrentCooldown = 0.0;
		}

		PlayAnim('explodestart');
		FinishAnim();

		PlayAnim('explodeend');
		SpawnFire();
		FinishAnim();

		LoopAnim('Idle');

		if ( !IsHarryNear(AttackDistance) && !bAlwaysAttack )
		{
			GotoState('stateIdle');
		}

		Goto('begin');
}

defaultproperties
{
	AttackDistance=350.0
	FireCooldown=0.25
	FireLaunchSpeed=100.0

	FireOffset=(Z=70.0)

	Mesh=SkeletalMesh'MocaModelPak.skfireseedplantMesh'
}