//================================================================================
// MOCAWatcherHunter.
//================================================================================

class MOCAWatcherHunter extends MOCAHunter;

var() float chaseSpeed; //How fast to chase after harry Def: 230
var NavigationPoint randNavP;

event Bump( Actor Other )
  {
    Super.Bump(Other);
    Log("Touched by" $ Other);
    if (!IsInState('asleep') && !PlayerHarry.IsInState('caught') && (Other.IsA('MOCAharry') || Other.IsA('harry')))
    {
      PlayerHarry.GotoState('caught');
      GotoState('stateCatch');
    }
  }

function float GetWalkSpeed()
{
    return GroundSpeed / Default.GroundSpeed;
}

function bool SeesHarry()
{
    if (PlayerCanSeeMe())
        {
            if (IsFacing(PlayerHarry, 0.25))
            {
                if (Abs(PlayerHarry.Location.Z - Location.Z) <= 50)
                {
                    lastHarryPos = PlayerHarry.Location;
                    return true;
                }
            }
        }
    return false;
}

auto state stateSleep
{
    event EndState()
    {
        PreviousState = GetStateName();
    }
    begin:
        eVulnerableToSpell = SPELL_None;
        LoopAnim('Idle');
        goto('loop');
    
    loop:
        if(isHarryNear())
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

    function Tick( float DeltaTime )
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
        if (PreviousState == 'stateSleep')
        {
            Log("lookin at harry");
            TurnTo(lastHarryPos);
            PreviousState = 'stateIdle';
        }
        Sleep(RandRange(0.75,2.0));

        if (  !CloseToHome(travelFromHome) )
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
            }
            else
            {
                break;
            }
        }
        goto 'begin';
    
    awaken:
        PlayAnim('StepDown');
        FinishAnim();
        Goto('begin');
}

state stateChase
{
    function BeginState()
    {
        GroundSpeed = chaseSpeed;
        LoopAnim(walkAnim, GetWalkSpeed());
        SetTimer(1.0,true);
    }

    function EndState()
    {
        GroundSpeed = Default.GroundSpeed;
    }

    function Timer()
    {
        if(!SeesHarry())
        {
            attemptsMade++;
            Log("Attempts made: " $ string(attemptsMade) $ " out of " $ string(attemptsToFindHarry));
            if (attemptsMade > attemptsToFindHarry)
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
                navP = NavigationPoint(FindPathTo(GetNearbyNavPointInView()));
            }
            else
            {
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
    function EndState()
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
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks');
    PlayAnim('StandIdle2Caught', 2.0);
    FinishAnim();
    LoopAnim('StandCaught');
    sleep(3.0);
    SetLocation(vHome);
    GotoState('stateIdle');
}

state stateAction
{
    event EndState()
    {
        PreviousState = GetStateName();
    }
}

state stateHitBySpell
{
    event EndState()
    {
        PreviousState = GetStateName();
    }
}

state stateDead
{
    event EndState()
    {
        PreviousState = GetStateName();
    }
}

defaultproperties
{
    sleepAnim=Idle
    walkAnim=StandWalk
    idleAnim=StandIdle
    attemptsToFindHarry=10
    DebugErrMessage="WARNING: Requires path nodes."
    hitsToKill=3
    GroundSpeed=100
    chaseSpeed=230
    SightRadius=500
    BaseEyeHeight=20.75
    EyeHeight=20.75
    eVulnerableToSpell=SPELL_None
    DrawScale=1.2
    CollisionHeight=58
    Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
    ShadowScale=0.5
    bAdvancedTactics=True
    travelFromHome=1000
    MultiSkins(1)=Texture'MocaTexturePak.Misc.transparent'
    tiltOnMovement=False
    RotationRate=(Pitch=4096,Yaw=100000,Roll=3072)
}
