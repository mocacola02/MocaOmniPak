class MOCAFireseedPlant extends MOCAChar;

var() float DistanceToAttack; //Moca: Required distance to attack Harry, Def: 500
var() float FireballDistMin; //Moca: Minimum distance for shot fireballs to travel, Def: 50
var() float FireballDistMax; //Moca: Maximum distance for shot fireballs to travel, Def: 100
var() float FireballLaunchHeight; //Moca: How high should fireballs be shot, Def: 700
var() float FireCooldown; //Moca: Required time between firing, may cause issues if too low, Def: 2
var() bool alwaysAttack; //Moca: Should plants always spit fire, def: false
var() vector fireballOffset; //Moca: Spawn location offset for spawning fireballs, def: 0,0,00
var float cooldown;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    cooldown = FireCooldown;
}

function SpawnSmoke()
{
    Spawn(Class'SmokePuff');
    Spawn(Class'SmokeShoot');
}

function SpawnFire()
{
    Spawn(Class'SmokePuff');
    Spawn(Class'MOCAFireBall',self,,Location + fireballOffset,Rotation);
}

auto state stateIdle
{
    function BeginState()
    {
        if(alwaysAttack)
        {
            gotostate('stateFireLoop');
        }
        LoopAnim('Idle');
        SetTimer(0.5,true);
    }

    function Timer()
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
    function Timer()
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
     FireballDistMin=50
     FireballDistMax=100
     FireballLaunchHeight=700
     FireCooldown=2
     fireballOffset=(Z=70)
     Mesh=SkeletalMesh'MocaModelPak.skfireseedplantMesh'
}
