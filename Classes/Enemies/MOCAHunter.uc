//================================================================================
// MOCAHunter.
//================================================================================

class MOCAHunter extends MOCAChar;

var() bool neverSleep;                          //Should the actor never sleep? Def: False
var() float chaseSpeed;                         //How fast to chase after harry Def: 230
var() float wakeUpDistance;                     //The distance at which Harry will wake up the actor Def: 400
var() int attemptsToFindHarry;                  //How many seconds should the actor attempt to find Harry after losing him? Def: 10
var(MOCAHunterAnims) name awakenAnim;           //Name of the wake up animation
var(MOCAHunterAnims) name caughtAnim;           //Name of the catch animation
var(MOCAHunterAnims) name caughtTransAnim;      //Name of the transition to catch animation (skipped if blank)
var(MOCAHunterAnims) name idleAnim;             //Name of the idle animation
var(MOCAHunterAnims) name sleepAnim;            //Name of the sleeping animation
var(MOCAHunterAnims) name walkAnim;             //Name of the walking animation
var() Sound caughtSound;                        //Sound to play when catching Harry

var bool correctingPath;
var int attemptsMade;
var NavigationPoint randNavP;


event PreBeginPlay()
{
	Super.PreBeginPlay();
    vHome = Location;
    //HitsLeft = hitsToKill;

    if (NeverSleep)
    {
        GotoState('stateIdle');
    }
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (!ActorExistenceCheck(Class'PathNode') || !ActorExistenceCheck(Class'MOCAharry'))
    {
        EnterErrorMode();
    }
}

event HitWall (Vector HitNormal, Actor HitWall)
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

function float GetWalkSpeed()
{
    return GroundSpeed / default.GroundSpeed;
}

event Bump( Actor Other )
{
    Super.Bump(Other);
    Log("Touched by" $ Other);
    if (!IsInState('asleep') && !PlayerHarry.IsInState('caught') && (Other.IsA('MOCAharry')))
    {
        PlayerHarry.GotoState('caught');
        GotoState('stateCatch');
    }
}

auto state stateSleep
{
    event EndState()
    {
        PreviousState = GetStateName();
    }
    
    begin:
        eVulnerableToSpell = SPELL_None;
        LoopAnim(sleepAnim);
        goto('loop');
    
    loop:
        if(isHarryNear(wakeUpDistance) || neverSleep == true)
        {
            GotoState('stateIdle', 'awaken');
        }
        sleep(0.5);
        goto('loop');
}

state stateIdle
{
    event EndState()
    {
        PreviousState = GetStateName();
    }

    event Tick( float DeltaTime )
    {
        if(SeesHarry())
        {
            prevNavP = navP;
            GotoState('stateChase');
        }
    }

    begin:
        GroundSpeed = Default.GroundSpeed;
        eVulnerableToSpell=default.eVulnerableToSpell;
        log("beginning idle");
        LoopAnim(idleAnim);
        if (inErrorMode)
        {
            GotoState('stateError');
        }
        if (PreviousState == 'stateSleep')
        {
            Log("lookin at harry");
            TurnTo(lastHarryPos);
            PreviousState = 'stateIdle';
        }
        Sleep(RandRange(0.75,2.0));

        if (  !CloseToHome(maxTravelDistance) )
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
        randNavP = FindRandomDest();
        navP = NavigationPoint(FindPathToward(randNavP));
        while (navP != randNavP && navP != None)
        {
            MoveToward(navP);
            navP = NavigationPoint(FindPathToward(randNavP));
            SleepForTick();
        }
        goto 'begin';
        
    gohome:
        Log("going home");
        LoopAnim(walkAnim);
        while(!CloseToHome(200))
        {
            navP = NavigationPoint(FindPathTo(vHome));
            if (navP != None)
            {
                MoveToward(navP);
                SleepForTick();
            }
            else
            {
                break;
            }
        }
        goto 'begin';
    
    awaken:
        PlayAnim(awakenAnim,,,,[RootBone] 'Move');
        FinishAnim();
        Goto('begin');
}

state stateChase
{
    event BeginState()
    {
        GroundSpeed = chaseSpeed;
        LoopAnim(walkAnim, GetWalkSpeed());
        SetTimer(1.0,true);
    }

    event EndState()
    {
        GroundSpeed = Default.GroundSpeed;
    }

    event Timer()
    {
        if(!SeesHarry())
        {
            attemptsMade++;
            Log("Attempts made: " $ string(attemptsMade) $ " out of " $ string(attemptsToFindHarry));
            if (attemptsMade >= attemptsToFindHarry)
            {
                GotoState('stateIdle');
            }
        }
    }

    event AlterDestination()
    {
        Super.AlterDestination();
        if (SeesHarry())
        {
            attemptsMade = 0;
            GotoState('stateDerailed');
        }
    }

    begin:
        while(true)
        {
            if (attemptsMade > round(attemptsToFindHarry / 1.63))
            {
                Log("Guessing where player went");
                navP = NavigationPoint(FindPathTo(GetNearbyNavPointInView()));
            }
            else
            {
                Log("Following where playing went");
                navP = NavigationPoint(FindPathToward(PlayerHarry));
            }
            if (navP != None)
            {
                MoveToward(navP);
            }
            else
            {
                GotoState('stateIdle');
            }
            
            SleepForTick();
        }       
}

state stateDerailed
{
    event EndState()
    {
        GroundSpeed = Default.GroundSpeed;
    }

    begin:
        GroundSpeed = chaseSpeed;
        while (SeesHarry())
        {
            MoveToward(PlayerHarry);
            SleepForTick();
        }

        GotoState('stateChase');
}

state stateCatch
{
  begin:
    Acceleration = vect(0.00,0.00,0.00);
    Velocity = vect(0.00,0.00,0.00);
    TurnTo(PlayerHarry.Location);
    Log("CAUGHT HARRY!!!!!!!!!!!!!!!!!");
    PlaySound(caughtSound);
    if (caughtTransAnim != '')
    {
        PlayAnim(caughtTransAnim, 4.0);
        FinishAnim();
    }
    LoopAnim(caughtAnim);
    sleep(3.0);
    SetLocation(vHome);
    GotoState('stateIdle');
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
    attemptsToFindHarry=10
    BaseEyeHeight=20.75
    bAdvancedTactics=True
    chaseSpeed=230
    CollisionHeight=65
    CollisionRadius=15
    DebugErrMessage="WARNING: Requires path nodes and MOCAharry."
    DrawScale=1.0
    eVulnerableToSpell=SPELL_None
    EyeHeight=20.75
    GroundSpeed=100
    hitsToKill=3
    RotationRate=(Pitch=4096,Yaw=100000,Roll=3072)
    ShadowScale=0.5
    SightRadius=2500
    tiltOnMovement=False
    maxTravelDistance=1000
    wakeUpDistance=400
}
