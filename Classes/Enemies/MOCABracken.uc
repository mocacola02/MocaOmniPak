//=============================================================================
// MOCABracken
//=============================================================================

class MOCABracken extends MOCAChar;

var() bool startActive; // Should Bracken be active on BeginPlay
var() int cooldown; // How long in seconds should the Bracken wait until stalking again
var() int maxAnger; // Maximum anger level before attacking
var() int angerIncrement; // Anger points to increase on each stare check
var() float minDot; // Minimum dot product for detecting if player is looking

var NavigationPoint retreatNavP;

var int angerCounter; // Tracks current anger level
var int cooldownCounter; // Tracks remaining cooldown time

var Sound sfxAnger;
var Sound sfxKill;
var Sound sfxStun;
var Sound sfxRetreat;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    EnableTurnTo(PlayerHarry);
    cooldownCounter = cooldown;
}

auto state stateIdle
{
    function BeginState()
    {
        Log("starting idle");
        if (!ActorExistenceCheck(class'BrackenPathNode'))
        {
            GotoState('stateError');
        }
    }
    begin:
        if (startActive)
        {
            Log("leaving idle to stalk");
            GotoState('stateStalking');
        }
}

state stateStalking
{
    function BeginState()
    {
        Log("Begin Stalk");
        LoopAnim('Sneak',2.0);
        SetTimer(0.1, true);
    }
    
    function EndState()
    {
        Log("End Stalk");
    }

    function Timer()
    {
        if (IsOtherLookingAt(PlayerHarry,minDot))
        {
            GotoState('stateStare');
        }
        if (navP.Extracost > 0)
        {
            if(!FindBestPathToward(PlayerHarry,false))
            {
                GotoState('stateWaiting');
            }
        }
    }

    function PickDestination()
    {
        Log("Pathing to harry");
        navP = NavigationPoint(FindPathTo(PlayerHarry.Location)); //Find path to him
        if (navP == None)
        {
            Log("cant path harry, random");
            navP = FindRandomDest(); //Otherwise roam
        }
    }
    begin:
        goto 'loop';

    loop:
        Log("Stalk Looped");
        PickDestination();
        if (!isValidNavP())
        {
            Log("Invalid navP");
            navP = FindRandomDest();
        }
        Log("tempNavP: " @ string(tempNavP) @ "  navP: " @ string(navP));
        while (tempNavP != navP)
        {
            Log("Last tempNavP: " @ string(tempNavP));
            tempNavP = NavigationPoint(FindPathToward(navP));
            Log("Next tempNavP: " @ string(navP));
            SleepForTick();
            StrafeFacing(tempNavP.Location,PlayerHarry);
            StoreNavP(navP);
        }
        goto 'loop';
}

state stateWaiting
{
    function BeginState()
    {
        Log("Begin Waiting");
        StopMoving();
        LoopAnim('Idle',2.0);
        SetTimer(0.5,true);
    }
    
    function EndState()
    {
        Log("End Waiting");
    }

    function Timer()
    {
        if (IsOtherLookingAt(PlayerHarry,minDot))
        {
            GotoState('stateStare');
        }
    }

    begin:
        while (!FindBestPathToward(PlayerHarry,false))
        {
            Log("Waiting for path.");
            Sleep(1.0);
        }
        GotoState('stateStalking');
}

state stateRetreat
{
    function BeginState()
    {
        Log("Begin Retreat");
        GroundSpeed = GroundSpeed * 1.5;
        SetTimer(1.0,true);
        ClearPaths();
        LoopAnim('BackOff',2.5);
    }
    
    function EndState()
    {
        Log("End Retreat");
        GroundSpeed = Default.GroundSpeed;
    }

    function Timer()
    {
        if (IsOtherLookingAt(PlayerHarry,minDot))
        {
            cooldownCounter = cooldown;
            Log("reset cooldown.");
            GotoState('stateRetreat','begin');
        }
        else
        {
            if (cooldownCounter > 0)
            {
                cooldownCounter--;
            }
            else
            {
                Log("Cooldown done.");
                cooldownCounter = cooldown;
                GotoState('stateStalking');
            }
        }
    }

    begin:
        while (cooldownCounter > 0)
        {
            retreatNavP =(GetFurthestNavPoint(PlayerHarry));
            if (!isValidNavP())
            {
                Log("Invalid navP");
                retreatNavP = NavigationPoint(FindPathTo(vHome,,True));
            }

            while (tempNavP != retreatNavP)
            {
                Log("prev tempNavP: " @ string(tempNavP) @ "  navP: " @ string(retreatNavP));
                tempNavP = NavigationPoint(FindPathTo(retreatNavP.Location));
                if (tempNavP == prevNavP)
                {
                    tempNavP = FindRandomDest();
                }
                Log("current tempNavP: " @ string(tempNavP) @ "  navP: " @ string(retreatNavP));
                SleepForTick();
                StrafeFacing(tempNavP.Location,PlayerHarry);
                StoreNavP(retreatNavP);
            }
            Log("Done moving to retreat point.");
            break;
        }
        goto 'waiting';

    waiting:
        StopMoving();
        LoopAnim('Idle',2.0);
        while (cooldownCounter > 0)
        {
            Log("Waiting for cooldown. " @ string(cooldownCounter));
            sleep(1.0);
        }
}

state stateStare
{
    function BeginState()
    {
        Log("Begin Stare");
        PlaySound(sfxRetreat);
        StopMoving();
        SetTimer(0.25,true);
        LoopAnim('Idle',2.0);
    }
    
    function EndState()
    {
        Log("End Stare");
    }

    function Timer()
    {
        if(IsOtherLookingAt(PlayerHarry,minDot))
        {
            angerCounter = angerCounter + angerIncrement;
            if (angerCounter > maxAnger)
            {
                GotoState('stateChase');
            }
        }
    }

    begin:
        Sleep(RandRange(0.25,1.25));
        GotoState('stateRetreat');
}

state stateChase
{
    function BeginState()
    {
        Log("Begin Chase");
        StopMoving();
        PlaySound(sfxAnger);
        LoopAnim('AttackWalk',2.5);
    }
    
    function EndState()
    {
        Log("End Chase");
    }
}

state stateKill
{

}

defaultproperties
{
    Mesh=SkeletalMesh'MocaModelPak.skBracken'
    bAdvancedTactics=True
    hitsToKill=99
    GroundSpeed=280.0
    SightRadius=512.0
    CollisionHeight=65
    DrawScale=1.2
    ShadowClass=None
    PeripheralVision=0.85
    BaseEyeHeight=20.75
    RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
    EyeHeight=20.75
    DebugErrMessage="WARNING: Brackens require BrackenPathNodes to be placed in the level. While PathNodes will work, they do not have all the proper features for the Bracken. Please add BrackenPathNodes and rebuild your level, or if you require non-Bracken path nodes for it for whatever reason then set bypassErrorMode = True";
    maxAnger=30
    angerIncrement=1
    cooldown=20
    minDot=0.25
    sfxAnger=Sound'MocaSoundPak.Creatures.br_Anger'
    sfxKill=Sound'MocaSoundPak.Creatures.br_Kill'
    sfxStun=Sound'MocaSoundPak.Creatures.br_Stun'
    sfxRetreat=Sound'MocaSoundPak.Creatures.br_Retreat'
    maxTravelDistance=9999999
    affectAmbience=True
    bSpecialPawn=True
    bForcePathSupport=True
}
