//================================================================================
// MOCAFireseedPlant. Not amazing but better than the pre-3.0 version
//================================================================================
class MOCAFireseedPlant extends MOCAChar;

var() bool bAlwaysAttack;		// Moca: Should the plant always spit fire? Def: False

var() float AttackDistance;		// Moca: How far can we attack from? Def: 350.0
var() float FireCooldown;		// Moca: How long in between fire shots? Def: 0.25
var() float FireLaunchSpeed;	// Moca: What speed to launch fireballs at? Def: 100.0

var() Vector FireOffset;		// Moca: Location offset to spawn fireball at. Def: X=0 Y=0 Z=70


var bool bIsAttacking;		// Are we attacking right now
var float CurrentCooldown;	// Current cooldown time
var float RangeIntensity;	// How far of our range to extend to


////////////////////
// Main Functions
////////////////////

function SpawnSmoke()
{
	// Spawn smoke actors
	Spawn(Class'SmokePuff');
	Spawn(Class'SmokeShoot');
}

function SpawnFire()
{
	local Rotator FireRotation;
	local MOCAFireBall NewFireBall;
	// Set rotation to self rotation
	FireRotation = Rotation;
	// Rotate 90 degrees
	FireRotation.Pitch += 16384;

	// Spawn smoke puff emitter
	Spawn(Class'SmokePuff');
	// Spawn new fireball
	NewFireBall = Spawn(Class'MOCAFireBall',Self,,Location + FireOffset,FireRotation);
	// Set fireball speed
	NewFireBall.LaunchSpeed = FireLaunchSpeed;

	// Get range intensity based on distance from Harry
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
		// If always attack, go to fire state
		if ( bAlwaysAttack )
		{
			GotoState('stateFire');
		}

		// Loop idle anim
		LoopAnim('Idle');
		// Check if Harry is near each half second
		SetTimer(0.5,True);
	}

	event Timer()
	{
		// If Harry is near, go to fire state
		if ( GetDistanceFromHarry() < AttackDistance )
		{
			GotoState('stateFire');
		}
	}

	begin:
		// Every so often, puff out smoke
		Sleep(RandRange(2.0,16.0));
		GotoState('statePuff');
}

state statePuff
{
	begin:
		// Play vent anim
		PlayAnim('gasventstart');
		Sleep(0.2);
		// Spawn smoke & finish anim
		SpawnSmoke();
		FinishAnim();

		// Play vent end anim & finish it
		PlayAnim('gasventend');
		FinishAnim();

		// Go back to idle
		GotoState('stateIdle');
}

state stateFire
{
	event BeginState()
	{
		// Set that we are attacking
		bIsAttacking = True;
	}

	event EndState()
	{
		// Set that we are no longer attacking
		bIsAttacking = False;
		// Reset cooldown
		CurrentCooldown = 0.0;
	}

	event Tick(float DeltaTime)
	{
		// Increment cooldown time
		CurrentCooldown += DeltaTime;
	}

	begin:
		// If we're not cooled down yet, sleep for a tick and then check again
		if ( CurrentCooldown < FireCooldown )
		{
			SleepForTick();
			Goto('begin');
		}
		// Otherwise, make sure cooldown = 0
		else
		{
			CurrentCooldown = 0.0;
		}

		// Play explode anim
		PlayAnim('explodestart');
		FinishAnim();

		// Play end explode anim & spawn fire
		PlayAnim('explodeend');
		SpawnFire();
		FinishAnim();

		// Loop idle anim
		LoopAnim('Idle');

		// If Harry isn't near and we don't always attack, go back to idle
		if ( !IsHarryNear(AttackDistance) && !bAlwaysAttack )
		{
			GotoState('stateIdle');
		}

		// Otherwise, loop back to beginning
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