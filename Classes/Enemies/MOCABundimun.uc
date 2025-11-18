//================================================================================
// MOCABundimun.
//================================================================================

class MOCABundimun extends MOCAChar;

var() bool bStayAboveGround; // Moca: Should it always be above ground? Def: False
var() float BumpDamage; // Moca: How much damage from bumping into its body? Def: 15.0
var() float StunDuration; // Moca: How long should it stay stunned from Rictu? Def: 5.0
var() float PukeDistance; // Moca: How far should the poison reach? Def: 10.0
var() float TriggerDistance; // Moca: How far can the bundi detect Harry? Def: 500.0
var() float pukeDamage; // Moca: How much damage should puke do? Def: 10.0
var Rotator NewRot;
var float Forward;
//var float ShadowScaleIncrement;
var bool bCanHit;
var BundimunDeath KillEmit;
var BundimunDig DigEmit;
var BundimunShrink ShrinkEmit;

var ESpellType DefVunSpell;

function SpawnKillParticles();

event PostBeginPlay()
{
    local vector DigLocation;
    local rotator DigRotation;
    Super.PostBeginPlay();

	DefVunSpell = eVulnerableToSpell;

    DigLocation = Location;
    DigLocation.Z -= (CollisionHeight * 0.5) + 1;
    DigRotation.Pitch = 16384;
    DigEmit = Spawn(Class'BundimunDig',self,,DigLocation,DigRotation);

    if (!ActorExistenceCheck(Class'MOCAharry'))
    {
        EnterErrorMode();
    }
}

event Bump (Actor Other)
{
	if ( PlayerHarry == Other && IsInState('stateSpitting'))
	{
		Log("DEALING BUMP DAMAGE TO HARRY!!!!!!!!!!!!!!!!!!");
		DoBumpDamage(Location, 'BundiBody');
	}
}

function ProcessStomp()
{
    Log('Processing stomp');
    GotoState('stateDie');
}

function DoBumpDamage (Vector vDamageLoc, name nameDamage)
{
    if (bCanHit)
    {
        PlayerHarry.TakeDamage(BumpDamage,self,vDamageLoc,vect(0.00,0.00,0.00),nameDamage);
        bCanHit = False;
		SetTimer(1.0,false,'ResetBumpHit');
    }
}

function ResetBumpHit()
{
	bCanHit = True;
}

function ProcessSpell()
{
  GotoState('stateStunned');
}

function Puke()
{
    local Vector SpawnLocation;
    local Rotator SpawnRotation;
    local MOCABundimunSpit NewActor;

    SpawnLocation = BonePos('SnoutEnd');
    SpawnRotation = Rotation;

    NewActor = Spawn(Class'MocaOmniPak.MOCABundimunSpit',self,, SpawnLocation, self.Rotation);
    NewActor.DamageToDeal = pukeDamage;
}

auto state determineState
{
    begin:
        if (bStayAboveGround)
		{
            GotoState('stateDig','rise');
        }
        else
		{
            GotoState('stateUnderGround');
        }
}

state stateUnderground
{
	event BeginState()
	{
		LoopAnim('Underground');
		Opacity = 0.0;
	}
    
	event Tick (float DeltaTime)
	{
		Global.Tick(DeltaTime);
        if (isHarryNear(triggerDistance))
        {
            GotoState('stateDig','rise');
        }
	}
}

state stateDig
{
	event BeginState()
	{
		DigEmit.bEmit = True;
		Opacity = 1.0;
	}

	event EndState()
	{
		DigEmit.bEmit = False;
	}

	event Tick (float DeltaTime)
	{
		Global.Tick(DeltaTime);
		//Shadow.Opacity = FClamp(Shadow.Opacity + ShadowScaleIncrement, 0.0, 1.0);
		//Log("Bundimun shadow size" $ string(Shadow.Opacity));
	}

	rise:
		//ShadowScaleIncrement = 0.008;
		SetCollision(true,true,true);
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_rise');
        PlayAnim('Rise');
		FinishAnim();
		GotoState('stateSpitting');

	sink:
		//ShadowScaleIncrement = -0.008;
		SetCollision(false,false,false);
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_sink');
		PlayAnim('Sink');
		FinishAnim();
		GotoState('stateUnderground');
}

state stateSpitting
{
    event BeginState()
    {
		bCanHit = True;
        AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_shoot';
		eVulnerableToSpell = DefVunSpell;
        LoopAnim('Attack');
    }

	event EndState()
	{
		AmbientSound = None;
		eVulnerableToSpell = SPELL_None;
	}

    event Tick (float DeltaTime)
    {
		if (!isHarryNear(triggerDistance) && !bStayAboveGround)
        {
            GotoState('stateDig','sink');
        }

        //SPEEN
        DesiredRotation = Rotation;
        DesiredRotation.Yaw += (5500 * DeltaTime);
        SetRotation(DesiredRotation);
        SetLocation(Location);
    }
}

state stateStunned
{
    event BeginState()
    {
		DigEmit.bEmit = False;
        bCantStandOnMe = False;
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_hit');
        AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_dazed';
        LoopAnim('Dazed');
    }

	event EndState()
	{
		bCantStandOnMe = True;
	}

    begin:
        sleep(StunDuration);
        GotoState('stateSpitting');
}

state stateDie
{
    event BeginState()
    {
		Disable('Tick');
		ShrinkEmit = Spawn(class'BundimunShrink',self,,Location,,true);
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_smash');
        PlayAnim('Bounce');
        SpawnKillParticles();
    }

	event Tick (float DeltaTime)
	{
		Global.Tick(DeltaTime);
		DrawScale -= (1.0 * DeltaTime);
	}

    function SpawnKillParticles()
    {
        local Rotator SpawnRotation;

        SpawnRotation.Pitch = 16384;
        SpawnRotation.Yaw = 0;
        SpawnRotation.Roll = 0;
        Log("spawning kill particles");
        KillEmit = Spawn(class'MocaOmniPak.BundimunDeath',self,,Location,SpawnRotation,true);
    }

    begin:
        Sleep(2.0);
        bCantStandOnMe=True;
        KillEmit.bEmit = False;
        FinishAnim();
		Goto('shrink');

	shrink:
		Enable('Tick');
		if (DrawScale <= 0.0)
		{
			Goto('kill');
		}
		else if (DrawScale < 0.25)
		{
			ShrinkEmit.bEmit = False;
		}
		SleepForTick();
		Goto('shrink');

	kill:
		ShrinkEmit.Destroy();
		KillEmit.Destroy();
		DigEmit.Destroy();
        Destroy();
}

defaultproperties
{
	ShadowScale=0.0
    bCantStandOnMe=True
    pukeDamage=7.0
    PukeDistance=75
    eVulnerableToSpell=SPELL_Rictusempra
    BumpDamage=15
    StunDuration=5
    triggerDistance=500
    Mesh=SkeletalMesh'MocaModelPak.skBundimun'
    DrawType=DT_Mesh
    DrawScale=0.6
    SoundRadius=12
    SoundVolMult=1.3
    CollisionHeight=18
    CollisionRadius=30
    DebugErrMessage="The MOCABundimun class requires MOCAharry, not the regular harry class.";
}