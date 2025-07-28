//================================================================================
// MOCAHunter.
//================================================================================

class MOCAHunter extends MOCAChar;


var() bool NeverSleep;                              //Moca: Should actor always be awake

var() int attemptsToFindHarry;                      //Moca: Currently not functional. How many additional times should skelly try to find a path to harry after losing sight? (Skelly will always check a single time)
var() name sleepAnim;
var() name walkAnim;
var() name idleAnim;
var int attemptsLeft;
var vector predictedLocation;
var bool correctingPath;


event PreBeginPlay()
{
    Super.PreBeginPlay();
    vHome = Location;
    HitsLeft = hitsToKill;

    if (NeverSleep)
    {
        GotoState('stateIdle');
    }
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (!ActorExistenceCheck(Class'PathNode'))
    {
        EnterErrorMode();
    }
}

function HitWall (Vector HitNormal, Actor HitWall)
{
    Super.HitWall(HitNormal,HitWall);
    if (!correctingPath)
    {
        correctingPath = True;
        GotoState('stateIdle', 'gosomewhere');
    }
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellRictusempra(spell,vHitLocation);
  if (  !IsInState('stateHitBySpell') )
  {
    GotoState('stateHitBySpell');
  }
  return True;
}

auto state stateSleep
{
}

state stateIdle
{
    event EndState()
    {
        PreviousState = GetStateName();
    }

    function Tick( float DeltaTime )
    {
        if (PlayerCanSeeMe())
        {
            if (IsFacing(PlayerHarry, 0.25))
            {
                GotoState('stateAction');
            }
        }
    }

    begin:
        attemptsLeft = attemptsToFindHarry;
        eVulnerableToSpell=default.eVulnerableToSpell;
        log("beginning idle");
        if (PreviousState == 'stateSleep')
        {
            Log("lookin at harry");
            TurnTo(lastHarryPos);
            PreviousState = 'stateIdle';
        }
        Sleep(RandRange(0.75,2.0));

        if (  !CloseToHome() )
        {
            Log("Go home");
            goto 'gohome';
        }else {
            Log("Go somewhere");
            goto 'gosomewhere';
        }


    gosomewhere:
        Log("Going somewhere");
        LoopAnim(walkAnim);
        navP = FindRandomDest();
        while (tempNavP != navP)
        {
            tempNavP = NavigationPoint(FindPathToward(navP));
            SleepForTick();
            MoveToward(tempNavP);
        }
        correctingPath = False;
        goto 'begin';
        
    gohome:
        Log("going home");
        LoopAnim(walkAnim);
        navP = NavigationPoint(FindPathTo(vHome));
        Log(string(navP));
        while (tempNavP != navP)
        {
            Log("first check for harry");
            tempNavP = NavigationPoint(FindPathToward(navP));
            SleepForTick();
            MoveToward(tempNavP);
        }
        MoveTo(vHome);
        goto 'begin';

    followharry:
        Log("Searching for harry");
        GroundSpeed = 100;
        LoopAnim(walkAnim);
        navP = NavigationPoint(FindPathTo(lastHarryPos));
        Log(string(navP));
        while (tempNavP != navP)
        {
            Log("first check for harry");
            tempNavP = NavigationPoint(FindPathToward(navP));
            SleepForTick();
            MoveToward(tempNavP);
        }
        goto 'begin';
}

state stateAction
{
}

state stateHitBySpell
{
}

state stateDead
{
}

defaultproperties
{
     attemptsToFindHarry=3
     DebugErrMessage="WARNING: Requires path nodes."
     hitsToKill=2
     ShadowClass=None
     GroundSpeed=100
     SightRadius=2500
     BaseEyeHeight=20.75
     EyeHeight=20.75
     eVulnerableToSpell=SPELL_None
     DrawScale=1.0
     CollisionHeight=65
     CollisionRadius=18
}
