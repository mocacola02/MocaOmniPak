//================================================================================
// MOCAStalker.
//================================================================================

// CLEAN ME

class MOCAStalker extends MOCAChar;

var() float activationDistance;             //Moca: How close Harry needs to be to begin stalking Def: 5000
var() float attackSpeed;                    //Moca: How fast should the actor get while attacking? Def: 250
var() float stalkCooldown;                  //Moca: How long to wait before stalking after being spotted Def: 10

var(MOCAStalkerAnger) float requiredAnger;  //Moca: How angry does the actor need to be before attacking? Def: 50
var(MOCAStalkerAnger) float angerRate;      //Moca: How fast does the actor get angry? aka how much to increase anger by when spotted Def: 1
var(MOCAStalkerAnger) float relaxRate;      //Moca: How fast does the actor lose angriness? aka how much to decrease anger by when still angry Def: 1

var(MOCAStalkerAnims) name waitAnim;        //Moca: Animation to play while waiting
var(MOCAStalkerAnims) float waitRate;       //Moca: Speed of animation Def: 1.0
var(MOCAStalkerAnims) name sneakAnim;       //Moca: Animation to play while sneaking
var(MOCAStalkerAnims) float sneakRate;      //Moca: Speed of animation Def: 1.0
var(MOCAStalkerAnims) name retreatAnim;     //Moca: Animation to play while retreating
var(MOCAStalkerAnims) float retreatRate;    //Moca: Speed of animation Def: 1.0
var(MOCAStalkerAnims) name attackAnim;      //Moca: Animation to play while attacking
var(MOCAStalkerAnims) float attackRate;     //Moca: Speed of animation Def: 1.0
var(MOCAStalkerAnims) name stareAnim;       //Moca: Animation to play while staring
var(MOCAStalkerAnims) float stareRate;      //Moca: Speed of animation Def: 1.0
var(MOCAStalkerAnims) name killAnim;        //Moca: Animation to play while killing Harry
var(MOCAStalkerAnims) float killRate;       //Moca: Speed of animation Def: 1.0
var(MOCAStalkerAnims) name dieAnim;         //Moca: Animation to play while dying
var(MOCAStalkerAnims) float dieRate;        //Moca: Speed of animation Def: 1.0

var(MOCAStalkerSounds) Sound retreatSound;  //Moca: Sound to play while retreating
var(MOCAStalkerSounds) Sound attackSound;   //Moca: Sound to play while attacking
var(MOCAStalkerSounds) Sound killSound;     //Moca: Sound to play while killing Harry
var(MOCAStalkerSounds) Sound dieSound;      //Moca: Sound to play while dying
var(MOCAStalkerSounds) float noiseRadius;   //Moca: How far noise can reach Def: 1000

var bool IsStaring;

var float DefGroundSpeed;
var float angerValue;
var float minDot;

var int randNumber;

var NavigationPoint retreatPoint;

event PreBeginPlay()
{
    super.PreBeginPlay();
    DefGroundSpeed = GroundSpeed;
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    EnableTurnTo(PlayerHarry);
    if (!ActorExistenceCheck(Class'MOCAStalkerNode') || !ActorExistenceCheck(Class'MOCAharry'))
    {
        EnterErrorMode();
		return;
    }

	SetTimer(0.125, true, 'HandleAnger');
}

event Bump( Actor Other )
{
    Super.Bump(Other);
    if (Other.IsA('harry') && !IsInState('stateKill'))
    {
        GotoState('stateKill');
    }
}

event HitWall (Vector HitNormal, Actor HitWall)
{
    Super.HitWall(HitNormal,HitWall);
    if (!IsInState('stateStalkDerailed') || !IsInState('stateAttackDerailed'))
    {
        Log("BUMPED A WALL AHHHHHHHH!!!!!!!!!!!!!!!!!");
        GotoState('stateRetreat', 'retreat');
    }
}

function HandleAnger()
{
	if ( ( IsStaring && IsOtherLookingAt(PlayerHarry, minDot) ) || ( GetDistanceFromHarry() < 128.0 ) )
	{
		angerValue = FClamp(angerValue + angerRate, 0, requiredAnger);
		Log("Increasing anger to " $ string(angerValue) $ ", Harry is " $ string(GetDistanceFromHarry()) $ " units away.");
	}
	else if (angerValue > 0 && !IsOtherLookingAt(PlayerHarry, minDot))
	{
		angerValue = FClamp(angerValue - relaxRate, 0, requiredAnger);
		Log("Decreasing anger to " $ string(angerValue));
	}
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellRictusempra(spell,vHitLocation);
    if (eVulnerableToSpell == ESpellType.SPELL_Rictusempra)
    {
        hitsTaken++;
        if (hitsTaken >= hitsToKill && hitsToKill != 0)
        {
            GotoState('stateDie');
        }
    }
    return True;
}

function ChangeNodeView(float newDistance)
{
    local MOCAStalkerNode A;
    
    foreach AllActors(class'MOCAStalkerNode', A)
    {
        if (A.IsA('MOCAStalkerNode'))
        {
            A.setViewDistance(newDistance);
        }
    }
}

event Tick (float DeltaTime)
{
    Super.Tick(DeltaTime);
    //FaceActor(PlayerHarry);
    if (IsOtherLookingAt(PlayerHarry, minDot) &&
        !IsInState('stateRetreat') &&
        !IsInState('stateAttack') &&
        !IsInState('stateAttackDerailed') &&
        !IsInState('stateKill') &&
        !IsInState('stateDie') )
    {
        Log("I WAS SEEN IN TICK!!!!!!!!!!!!!!!!");
        Log("Previous state: " $ string(GetStateName()));
        GotoState('stateRetreat', 'stare');
    }
}

auto state stateWait
{
    event BeginState()
    {
        Super.BeginState();
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        Log("WAITING!!!!!!!!!");
        LoopAnim(waitAnim, waitRate);
    }

    event Tick (float DeltaTime)
    {
        navP = NavigationPoint(FindPathToward(PlayerHarry));
        if (isHarryNear(activationDistance) && navP != None)
        {
            GotoState('stateStalk','stalk');
        }
    }
}

state stateStalk
{
    event BeginState()
    {
        Super.BeginState();
        Log("STALKING!!!!!!!!");
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        LoopAnim(sneakAnim, sneakRate);
    }

    stalk:
        Log("BEGIN STALK!!!!!!!!!!!!");
        Log("Is Harry Looking at me? " $ string(!IsOtherLookingAt(PlayerHarry,minDot)));
        Log("Is navP = none? " $ string(navP));
        Log("Is Harry near? " $ string(isHarryNear(activationDistance)));
        while( navP != None && isHarryNear(activationDistance) )
        {
            Log("ENTER STALK LOOP");
            if (SeesHarry())
            {
                Log("I SEE HARRY DIRECTLY, DERAIL!!!!!!");
                GotoState('stateStalkDerailed', 'stalk');
            }
            
            navP = NavigationPoint(FindPathToward(PlayerHarry));

            if (navP == None)
            {
                Log("NO STALK NAVP");
                break;
            }

            StrafeFacing(navP.Location,PlayerHarry);
            Log("EXITING LOOP");
            SleepForTick();
        }

        GotoState('stateWait');
}

state stateStalkDerailed
{
    stalk:
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        Log("BEGIN STALK DERAIL!!!!!!!!!!!!");
        Log("Is Harry Facing? " $ string(!IsOtherLookingAt(PlayerHarry,minDot)));
        Log("Is navP = none? " $ string(navP));
        Log("Is Harry near? " $ string(isHarryNear(activationDistance)));
        while( isHarryNear(activationDistance) && SeesHarry())
        {
            StrafeFacing(PlayerHarry.Location,PlayerHarry);
            SleepForTick();
        }
        Gotostate('stateStalk', 'stalk');
}

state stateRetreat
{
    event BeginState()
    {
        Super.BeginState();
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        ChangeNodeView(500);
        GroundSpeed = attackSpeed;
        Log("RETREATING!!!!!!!!!");
        PlaySound(retreatSound, SLOT_None, 1.0,,noiseRadius);
        Log("DETERMINING NEW RETREAT POINT!!!!!!!!!!!!!!!!!!!!!!!");
        retreatPoint = GetFurthestNavPoint(self);
        navP = NavigationPoint(FindPathToward(retreatPoint));
        Log("Going to " $ string(retreatPoint) $ " by starting to go to " $ string(navP));
        SetTimer(0.25, true);
    }

    event EndState()
    {
        IsStaring = False;
        GroundSpeed = DefGroundSpeed;
    }
    
    event Timer()
    {
        local int randStop;
        randStop = rand(32);
        if (randStop == 0)
        {
            Gotostate('stateRetreat', 'stare');
        }
    }

    retreat:
        LoopAnim(retreatAnim, retreatRate);
        Log("Is navP != None? " $ string(navP != None));
        Log("Is navP != retreatPoint? " $ string(navP != retreatPoint));
        while(navP != None)
        {
            Log("ENTERING RETREAT LOOP!");
            navP = NavigationPoint(FindPathToward(retreatPoint));
            Log("Next navP: " $ string(navP) $ " to get to retreat point " $ string(retreatPoint));
            if (navP == retreatPoint)
            {
                if (IsOtherLookingAt(PlayerHarry, minDot))
                {
                    Log("We reached our retreat but Harry is still watching, ATTACK!!!!!!!!");
                    Gotostate('stateAttack');
                }
                else
                {
                    break;
                }
            }
            if (navP != None)
            {
                StrafeFacing(navP.Location,PlayerHarry);
            }
            else
            {
                Log("Nowhere to retreat to, ATTACK!!!!!!!!");
                GotoState('stateAttack');
            }
            SleepForTick();
        }

        Log("Retreated, time to cool down");
        GotoState('stateCooldown');

    stare:
        Log("STARING!!!!!!!!!!!!");
		IsStaring = True;
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        LoopAnim(stareAnim, stareRate);

        randNumber = rand(24);
		if (angerValue >= requiredAnger)
		{
			GotoState('stateAttack');
		}
        else if (randNumber == 0)
        {
			IsStaring = False;
            Goto('retreat');
        }
        else
        {
            sleep(0.05);
            Goto('stare');
        }
}

state stateAttack
{
    event BeginState()
    {
        Super.BeginState();
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        Log("ATTACKING!!!!!!!!!!!!!!");
        GroundSpeed = attackSpeed;
        LoopAnim(attackAnim, attackRate);
    }

    event EndState()
    {
        Super.EndState();
        GroundSpeed = DefGroundSpeed;
    }

    event AlterDestination()
    {
        Super.AlterDestination();
        
    }

    begin:
        while(angerValue > 0)
        {
            if (SeesHarry())
            {
                GotoState('stateAttackDerailed');
            }
            navP = NavigationPoint(FindPathToward(PlayerHarry));
            if (navP == None)
            {
                break;
            }

            StrafeFacing(navP.Location,PlayerHarry);
            SleepForTick();
        }

        GotoState('stateRetreat', 'retreat');
}

state stateAttackDerailed
{
    event BeginState()
    {
        Super.BeginState();
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        Log("ATTACK DERAILING!!!!!!!!!!!!!");
        PlaySound(attackSound, SLOT_None, 1.0,,noiseRadius);
        LoopAnim(attackAnim, attackRate);
        GroundSpeed = attackSpeed;
    }

    event EndState()
    {
        Super.EndState();
        GroundSpeed = DefGroundSpeed;
    }

    begin:
        while (SeesHarry() && angerValue > 0)
        {
            StrafeFacing(PlayerHarry.Location,PlayerHarry);
            SleepForTick();
        }

        if (angerValue <= 0)
        {
            GotoState('stateRetreat', 'retreat');
        }

		SleepForTick();
        GotoState('stateAttack');
}

state stateKill
{
    begin:
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        PlayerHarry.bKeepStationary = true;
        StrafeTo(Location - Vector(Rotation) * 20, PlayerHarry.Location);
        PlayAnim(killAnim, killRate);
        PlaySound(killSound, SLOT_None, 1.0,,noiseRadius);
        sleep(0.8);
        ScreenFade(1.0,0.02);
        sleep(2.0);
        PlayerHarry.ConsoleCommand("LoadGame 0");
}

state stateDie
{
    begin:
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        TurnTo(PlayerHarry.Location);
        PlayAnim(dieAnim, dieRate);
        PlaySound(dieSound, SLOT_None, 1.0,,noiseRadius);
        FinishAnim();
        sleep(0.2);
        Destroy();
}

state stateCooldown
{
    begin:
        //angerRate++;
        Acceleration = vect(0.00,0.00,0.00);
        Velocity = vect(0.00,0.00,0.00);
        sleep(stalkCooldown);
        ChangeNodeView(0);
        gotostate('stateWait');
}

defaultproperties
{
    BaseEyeHeight=20.75
    RotationRate=(Pitch=4096,Yaw=50000,Roll=3072)
    EyeHeight=20.75
    ShadowClass=None
    PeripheralVision=0.85
    SightRadius=512.0
    CollisionHeight=65
    stalkCooldown=10
    requiredAnger=25
    activationDistance=5000
    bAdvancedTactics=true
    noiseRadius=1000
    GroundSpeed=180
    attackSpeed=250
    minDot=0.25
    maxTravelDistance=9999999
    angerRate=1
    relaxRate=0.0625
    affectAmbience=True
    waitRate=1.0
    sneakRate=1.0
    retreatRate=1.0
    attackRate=1.0
    stareRate=1.0
    killRate=1.0
    dieRate=1.0
}