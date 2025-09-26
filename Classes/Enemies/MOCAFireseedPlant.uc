class MOCAFireseedPlant extends MOCAChar;

// This actor needs to be rewritten.

var() float DistanceToAttack; //Moca: Required distance to attack Harry, Def: 500
var() float FireballLaunchSpeed; //Moca: How high should fireballs be shot, Def: 700
//var() float RangeMult;		// Moca: Multiplier for range. Def: 1.0
var() float FireCooldown; //Moca: Required time between firing, may cause issues if too low, Def: 2
var() bool alwaysAttack; //Moca: Should plants always spit fire, def: false
var() vector fireballOffset; //Moca: Spawn location offset for spawning fireballs, def: 0,0,0
var float cooldown;
var float RangeIntensity;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    cooldown = FireCooldown;
}

event Tick (float DeltaTime)
{
	if (isHarryNear(DistanceToAttack))
	{
		RangeIntensity = GetDistanceFromHarry() / 200;

		if (MocaDebugMode)
		{
			Log("Range intensity: " $ string(RangeIntensity));
		}	
	}
}

function SpawnSmoke()
{
    Spawn(Class'SmokePuff');
    Spawn(Class'SmokeShoot');
}

function SpawnFire()
{
	local Rotator SpawnRot;
	local MOCAFireBall SpawnedFireball;
	SpawnRot = Rotation;
	SpawnRot.Pitch += 16384;

    Spawn(Class'SmokePuff');
    SpawnedFireball = Spawn(Class'MOCAFireBall',self,,Location + fireballOffset,SpawnRot);
	SpawnedFireball.LaunchSpeed = FireballLaunchSpeed;
	//SpawnedFireball.HomingStrength *= RangeMult;
	SpawnedFireball.HomingStrength *= RangeIntensity;
}

auto state stateIdle
{
    event BeginState()
    {
        if(alwaysAttack)
        {
            gotostate('stateFireLoop');
        }
        LoopAnim('Idle');
        SetTimer(0.5,true);
    }

    event Timer()
    {
        if (GetDistanceFromHarry() < DistanceToAttack)
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
    event Timer()
    {
        Log(string(cooldown));
        if (cooldown < 0)
        {
            cooldown = FireCooldown;
            GotoState('stateIdle');
        }

        cooldown = cooldown - 0.1;
    }

    begin:
        PlayAnim('explodestart');
        FinishAnim();
        PlayAnim('explodeend');
        SpawnFire();
        SetTimer(0.1,true);
        FinishAnim();
        LoopAnim('Idle');
}

state stateFireLoop
{
    begin:
        PlayAnim('explodestart');
        FinishAnim();
        PlayAnim('explodeend');
        SpawnFire();
        SetTimer(0.1,true);
        FinishAnim();
        LoopAnim('Idle');
        Sleep(RandRange(0.01,1.0));
        goto 'begin';
}

defaultproperties
{
     DistanceToAttack=350
     FireballLaunchSpeed=100
     FireCooldown=0.25
     fireballOffset=(Z=70)
     Mesh=SkeletalMesh'MocaModelPak.skfireseedplantMesh'
	 //RangeMult=1.0
}
