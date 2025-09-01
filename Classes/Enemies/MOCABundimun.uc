//================================================================================
// MOCABundimun.
//================================================================================

class MOCABundimun extends MOCAChar;

var() bool StayAboveGround; //Moca: Should it always be above ground?
var() int BumpDamage; //Moca: How much damage from bumping into its body?
var() int StunDuration; //Moca: How long should it stay stunned from Rictu?
var() float PukeDistance; //Moca: How far should the poison reach?
var() float TriggerDistance; //Moca: How far can the bundi detect Harry?
var() float pukeDamage; //Moca: How much damage should puke do?
var Rotator NewRot;
var bool isStunned;
var float Forward;
var bool CanHit;
var bool isDying;
var BundimunDeath KillEmit;
var BundimunDig DigEmit;

event PostBeginPlay()
{
    local vector DigLocation;
    local rotator DigRotation;
    Super.PostBeginPlay();

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
  if ( PlayerHarry == Other && IsInState('onground'))
  {
    DoBumpDamage(Location, 'BundiBody');
  }
}

function ResetHit()
{
    CanHit = True;
}

function ProcessStomp()
{
    Log('Processing stomp');
    if (isStunned == True && isDying == False)
    {
        isDying = True;
        GotoState('squished');
    }
}

function DoBumpDamage (Vector vDamageLoc, name nameDamage)
{
    Log(string(CanHit));
    if (CanHit)
    {
        PlayerHarry.TakeDamage(BumpDamage,self,vDamageLoc,vect(0.00,0.00,0.00),nameDamage);
        CanHit = False;
    }
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  GotoState('stunned');
  return True;
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
        if (StayAboveGround) {
            GotoState('onground');
        }
        else {
            GotoState('underground');
        }
}

state underground
{
    begin:
        LoopAnim('Underground');
    loop:
        if (isHarryNear(triggerDistance))
        {
            GotoState('toabove');
        }
        else
        {
            sleep(1.0);
            goto ('loop');
        }
}

// do these really need to be separate states
state tounder
{
    begin:
        DigEmit.bEmit = True;
        AmbientSound = None;
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_sink');
        PlayAnim('Sink');
        FinishAnim();
        SetCollision(false, false, false);
        DigEmit.bEmit = False;
        GotoState('underground');
}


state toabove
{
    begin:
        DigEmit.bEmit = True;
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_rise');
        SetCollision(true, true, true);
        PlayAnim('Rise');
        FinishAnim();
        DigEmit.bEmit = False;
        GotoState('onground');
}

state onground
{
    event BeginState()
    {
        AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_shoot';
        isStunned = False;
        LoopAnim('Attack');
    }

    function Tick (float DeltaTime)
    {
        //SPEEN
        DesiredRotation = Rotation;
        DesiredRotation.Yaw += (5500 * DeltaTime);
        SetRotation(DesiredRotation);
        SetLocation(Location);
    }

    begin:
        if (!isHarryNear(triggerDistance) && !StayAboveGround)
        {
            GotoState('tounder');
        }
        else
        {
            //Puke();
            ResetHit();
            Sleep(1.25);
            goto ('begin');
        }
}

state stunned
{
    event BeginState()
    {
        bCantStandOnMe=False;
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_hit');
        AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_dazed';
        isStunned = True;
        LoopAnim('Dazed');
    }

    begin:
        sleep(StunDuration);
        GotoState('onground');
}

state squished
{
    event BeginState()
    {
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_smash');
        PlayAnim('Bounce');
        SpawnKillParticles();
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
        KillEmit.Destroy();
        Destroy();
}

defaultproperties
{
    bCantStandOnMe=True
    pukeDamage=10
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