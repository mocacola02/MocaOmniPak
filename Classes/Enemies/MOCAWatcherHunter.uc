//================================================================================
// MOCAWatcherHunter.
//================================================================================

class MOCAWatcherHunter extends MOCAHunter;

var() float chaseSpeed; //How fast to chase after harry Def: 230

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
                lastHarryPos = PlayerHarry.Location;
                return true;
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

        if (  !CloseToHome() )
        {
            Log("Go home");
            goto 'gohome';
        }else {
            Log("Go somewhere");
            goto 'gosomewhere';
        }


    gosomewhere:
        GroundSpeed = Default.GroundSpeed;
        Log("Going somewhere");
        LoopAnim(walkAnim);
        navP = FindRandomDest();
        MoveToward(navP);
        correctingPath = False;
        goto 'begin';
        
    gohome:
        Log("going home");
        LoopAnim(walkAnim);
        navP = NavigationPoint(FindPathTo(vHome));
        MoveToward(navP);
        goto 'begin';

    followharry:
        Log("Searching for harry");
        GroundSpeed = chaseSpeed;
        LoopAnim(walkAnim, GetWalkSpeed());
        navP = NavigationPoint(FindPathTo(lastHarryPos));
        MoveToward(navP);
        goto 'begin';
    
    awaken:
        PlayAnim('StepDown');
        FinishAnim();
        Goto('begin');
}

state stateChase
{
    begin:
        GroundSpeed = chaseSpeed;
        LoopAnim(walkAnim, GetWalkSpeed());
        navP = NavigationPoint(FindPathToward(PlayerHarry));
        Log(string(navP));
        MoveToward(navP);
        Log("DONE MOVING?????????/");
        if (GetDistanceFromHarry() < 50 || navP == None)
        {
            goto('derail');
        }
        if(SeesHarry())
        {
            goto('begin');
        }

        GotoState('stateIdle', 'followharry');

    derail:
        Log("DERAILING!!!!!!!!!!!!!!!!!!!!!!!!!");
        LoopAnim(walkAnim,GetWalkSpeed());
        MoveTo(PlayerHarry.Location);
        if (SeesHarry())
        {
            goto('derail');
        }
        GotoState('stateIdle', 'followharry');
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
    sleep(2.0);
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
    attemptsToFindHarry=3
    DebugErrMessage="WARNING: Requires path nodes."
    hitsToKill=2
    GroundSpeed=100
    chaseSpeed=230
    SightRadius=2500
    BaseEyeHeight=20.75
    EyeHeight=20.75
    eVulnerableToSpell=SPELL_None
    DrawScale=1.2
    CollisionHeight=58
    Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
    ShadowScale=0.5
}
