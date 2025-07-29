//================================================================================
// MOCACharmedSkeleton. Skelly, if you will.           bAD TO THE BONE
//================================================================================
/*
------____              ________________________________---
          \_         __/    ___---------__
            \      _/      /              \_
             \    /       /                 \
              |  /       | _    _ \          \
              | |       / / \  / \ |          \
              | |       ||   ||   ||           |
              | |       | \_//\\_/ |           |
              | |       |_| (||)   |_______|   |
              | |         |  ||     | _  / /   |
               \ \        |_________|| \/ /   /
                \ \_       |_|_|_|_|/|  _/___/
                 \__>       _ _/_ _ /  |
                          .|_|_|_|_|   |
                          |           /
                          |__________/
ascii art by GJakaKL*/

class MOCACharmedSkeleton extends MOCAChar;


var() float WakeUpRadius;                           //Moca: How far can skelly be woken up from
var() bool NeverSleep;                              //Moca: Should skelly always be awake

var() int Damage;                                   //Moca: How much damage should bones do
var() float ThrowTime;                              //Moca: How long should throws take
var class<MOCASkellyBone> thrownObject;             //Moca: Object skelly should throw
var MOCASkellyBone objectToThrow;
var() bool canRevive;                               //Moca: Can skelly revive if another skelly is near
var() float reviveDist;                             //Moca: Maximum distance between skellys to allow a revive
var() int reviveChecks;                             //Moca: How many nearby skelly checks should it take to revive (checks are every 0.5 secs)
var int currentChecks;
var() float ThrowDelay;                             //Moca: Delay between throws
var() bool hasArm;                                  //Moca: Should skelly be missing its arm on spawn (only works with NeverSleep = True)
var bool isDown;
var bool isDying;
var() int attemptsToFindHarry;                      //Moca: Currently not functional. How many additional times should skelly try to find a path to harry after losing sight? (Skelly will always check a single time)
var int attemptsLeft;
var vector predictedLocation;
var bool correctingPath;
/*
struct ParticleParams
{
  var() Class<ParticleFX> Died;
  var() Class<ParticleFX> Hit;
};

var() ParticleParams Particles;

struct AccuracyParams
{
  var() float Far;
  var() float Close;
};

var() AccuracyParams Accuracy;

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
    if (!correctingPath)
    {
        correctingPath = True;
        GotoState('stateIdle', 'gosomewhere');
    }
}

function bool isHarryNear()
{
    local float Size;
    Size = VSize(PlayerHarry.Location - Location);
    PlayerHarry.ClientMessage("Distance" @ string(Size));
    if (VSize(PlayerHarry.Location - Location) < SightRadius)
    {
        Log("is close");
        return True;
    }
    Log("not close");
    return False;
}

function bool wakeUpCheck()
{
    if (VSize(PlayerHarry.Location - Location) < WakeUpRadius)
    {
        return True;
    }
    return False;
}

function GetObjectToThrow()
{
  objectToThrow = Spawn(thrownObject);
  if ( objectToThrow == None )
  {
    return;
  }
  objectToThrow.bHidden = True;
  objectToThrow.SetCollision(False,False,False);
  objectToThrow.SetOwner(self);
  objectToThrow.bRotateToDesired = False;
  objectToThrow.AttachToOwner('joint67');
  objectToThrow.Damage = Damage;
  aHolding = objectToThrow;
}

function Vector RandomPosition (Vector NewPos, float fAccuracy)
{
  local Rotator R;
  local Vector D;
  local Vector V;
  local Vector rv;
  local float spread;

  spread = (1.0 - fAccuracy) * 8192;
  D.X = NewPos.X;
  D.Y = NewPos.Y;
  D.Z = 0.0;
  R = rotator(D);
  R.Yaw += RandRange(-spread,spread);
  V = vector(R);
  rv = V * VSize(D);
  rv.Z = NewPos.Z;
  
  return rv;
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

function float determineAnim(name armSeq, name noArmSeq, optional float overrideAnimRate)
{
    if (overrideAnimRate == 0)
    {
        if (!hasArm)
        {
            overrideAnimRate = 1.2;
        }
        else
        {
            overrideAnimRate = 1.0;
        }
    }
    if (!hasArm)
    {
        LoopAnim(noArmSeq, overrideAnimRate);
        return 1.0;
    }
    else {
        LoopAnim(armSeq, overrideAnimRate);
        return 1.2;
    }
}

auto state stateSleep
{
    event EndState()
    {
        PreviousState = GetStateName();
    }
    
    begin:
        if (inErrorMode) {GotoState('stateError');}
        eVulnerableToSpell = SPELL_None;
        hasArm = True;
        LoopAnim('PileOfBones');
        goto 'loop';
    
    loop:
       sleep (0.25);
       if (wakeUpCheck())
       {
            goto 'wakeup';
       }
       goto 'loop';

    wakeup:
        lastHarryPos = PlayerHarry.Location;
        PlayAnim('Resurect', 4.0);
        FinishAnim();
        Log(string(LastSeenPos));
        GotoState('stateIdle');
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
                GotoState('stateThrow');
            }
        }
    }

    function bool canAttemptCheck()
    {
        if (attemptsLeft > 0)
        {
            attemptsLeft--;
            Log("Attempts left: " @ string(attemptsLeft));
            return True;
        }
        return False;
    }

    function DetermineSkellySpeed()
    {
        if (hasArm)
        {
            GroundSpeed = 50;
        }
        else
        {
            GroundSpeed = 75;
        }
    }

    begin:
        DetermineSkellySpeed();
        attemptsLeft = attemptsToFindHarry;
        eVulnerableToSpell=default.eVulnerableToSpell;
        log("beginning idle");
        determineAnim('idle','IdleSansArm');
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
        DetermineSkellySpeed();
        Log("Going somewhere");
        determineAnim('Walk','WalkSansArm');
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
        determineAnim('Walk','WalkSansArm');
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
        determineAnim('Walk','WalkSansArm', 2.0);
        navP = NavigationPoint(FindPathTo(lastHarryPos));
        Log(string(navP));
        while (tempNavP != navP)
        {
            Log("first check for harry");
            tempNavP = NavigationPoint(FindPathToward(navP));
            SleepForTick();
            MoveToward(tempNavP);
        }
        while (canAttemptCheck())
        {
            predictedLocation = (lastHarryPos + lastHarryDirection * 300);
            navP = NavigationPoint(FindPathTo(predictedLocation));
            Log(string(navP));
            Spawn(Class'MOCADebugSprite',,,predictedLocation);
            while (tempNavP != navP)
            {
                log("FOLLOW UP CHECK");
                tempNavP = NavigationPoint(FindPathToward(navP));
                SleepForTick();
                MoveToward(navP);
            }
        }
        goto 'begin';
}

state stateThrow
{
    function Tick (float DeltaTime)
    {
        if (PlayerCanSeeMe())
        {
            lastHarryPos = PlayerHarry.Location;
            lastHarryDirection = Normal(PlayerHarry.Velocity);
        }
    }

    function ThrowBone()
    {
        attemptsLeft = attemptsToFindHarry;
        Log("THROW A BOEN!!!!");
        objectToThrow.bHidden=False;
        vNewPos = ComputeTrajectoryByTime(objectToThrow.Location,PlayerHarry.Location,ThrowTime,-256.0);
        if ( isHarryNear() )
        {
            vNewPos = RandomPosition(vNewPos,FClamp(Accuracy.Far,0.0,1.0));
        } else {
            vNewPos = RandomPosition(vNewPos,FClamp(Accuracy.Close,0.0,1.0));
            }
        ObjectThrow(vNewPos,True,True);
    }

    event EndState()
    {
        PreviousState = GetStateName();
    }

    begin:
        StopMoving();
        EnableTurnTo(PlayerHarry);
        TurnTo(PlayerHarry.Location);
        GetObjectToThrow();
        sleep(determineAnim('throw','ThrowSansArm'));
        Log("THROW A BOEN!!!!");
        objectToThrow.bHidden=False;
        vNewPos = ComputeTrajectoryByTime(objectToThrow.Location,PlayerHarry.Location,ThrowTime,-256.0);
        if ( isHarryNear() )
        {
            vNewPos = RandomPosition(vNewPos,FClamp(Accuracy.Far,0.0,1.0));
        } else {
            vNewPos = RandomPosition(vNewPos,FClamp(Accuracy.Close,0.0,1.0));
            }
        ObjectThrow(vNewPos,True,True);
        FinishAnim();
        if(PlayerCanSeeMe())
        {
            goto 'begin';
        }
        DestroyTurnToPermanentController();
        GotoState('stateIdle', 'followharry');
}

state stateHitBySpell
{
    event EndState()
    {
        PreviousState = GetStateName();
    }

    begin:
        DestroyTurnToPermanentController();
        StopMoving();
        eVulnerableToSpell = SPELL_None;
        Spawn(Particles.Hit,,,Location,rot(0,0,0));
        if ( aHolding != None )
        {
            aHolding.Destroy();
        }
        if (HitsLeft > 0)
        {
            goto 'hurt';
        }
        else {
            goto 'die';
        }
    
    hurt:
        if (HitsLeft == hitsToKill)
        {
            hasArm = False;
            GroundSpeed = 75.0;
            PlayAnim('LoseArm', 2.0);
            Sleep(1.0);
        }
        HitsLeft--;
        eVulnerableToSpell = Default.eVulnerableToSpell;
        GotoState('stateIdle');

    die:
        isDown = True;
        SetCollision(false, false, false);
        PlayAnim('Defeated');
        FinishAnim();
        GotoState('stateDead');
}

state stateDead
{
    event EndState()
    {
        PreviousState = GetStateName();
    }

    function bool CloseToSkelly()
    {
        local Actor ClosestSkelly;
        local MOCACharmedSkeleton A;
        local float CurrDist;

        foreach AllActors( class'MOCACharmedSkeleton', A )
        {
            CurrDist = VSize(A.Location - Location);

            if (CurrDist < reviveDist && !A.isDown)
            {
                return True;
            }
        }

        return False;
    }

    function PrepareToDie()
    {
        Opacity = Opacity - 0.01;
        if (Opacity <= 0)
        {
            Destroy();
        }
    }

    function Tick(float DeltaTime)
    {
        if (isDying)
        {
            PrepareToDie();
        }
    }

    begin:
        if (canRevive)
        {
            goto 'loop';
        } else {
            goto 'finalDie';
        }

    loop:
        sleep (0.5);
        Log('checking if can revive');
        if (CloseToSkelly())
        {
            currentChecks++;
            if (currentChecks >= reviveChecks)
            {
                goto 'revive';
            }
        }
        else
        {
            currentChecks--;
            if (Abs(currentChecks) == reviveChecks)
            {
                goto 'finalDie';
            }
        }
        goto 'loop';

    revive:
        isDown = True;
        hasArm = True;
        GroundSpeed = 50.0;
        PlayAnim('DefeatToResurrect', 3.0);
        FinishAnim();
        SetCollision(true, true, true);
        GotoState('stateIdle');

    finalDie:
        log("guess i'll die");
        sleep(4.0);
        isDying = True;
}
 */
defaultproperties
{
     WakeUpRadius=250
     travelFromHome=100
     Damage=10
     ThrowTime=1
     thrownObject=Class'MocaOmniPak.MOCASkellyBone'
     reviveDist=512
     reviveChecks=3
     ThrowDelay=2
     hasArm=True
     attemptsToFindHarry=3
     Accuracy=(Far=0.7,Close=0.9)
     DebugErrMessage="WARNING: Charmed Skeletons require path nodes to be placed in the level so they can move around. Please add path nodes to areas with skeletons in them. See the Slytherin Common Room map for an example of path nodes in use."
     hitsToKill=2
     ShadowClass=None
     GroundSpeed=50
     SightRadius=2500
     BaseEyeHeight=20.75
     EyeHeight=20.75
     AnimSequence=PileOfBones
     eVulnerableToSpell=SPELL_Rictusempra
     Mesh=SkeletalMesh'MocaModelPak.skCharmedSkeleton'
     DrawScale=0.6
     CollisionHeight=65
}
