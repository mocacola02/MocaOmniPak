//================================================================================
// MOCABundimun.
//================================================================================

class MOCABundimun extends MOCAChar;

var() bool StayAboveGround; //Moca: Should it always be above ground?
var() int BumpDamage; //Moca: How much damage from bumping into its body?
var() int StunDuration; //Moca: How long should it stay stunned from Rictu?
var() float PukeDistance; //Moca: How far should the poison reach?
var() float TriggerDistance; //Moca: How far can the bundi detect Harry?
var Rotator NewRot;
var bool isStunned;
var float Forward;
var bool CanHit;
var bool isDying;
var BundimunDeath KillEmit;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (!ActorExistenceCheck(Class'MOCAharry'))
    {
        EnterErrorMode();
    }
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

function ResetHit()
{
    CanHit = True;
}

event Bump (Actor Other)
{
  if ( PlayerHarry == Other && IsInState('onground'))
  {
    DoBumpDamage(Location, 'BundiBody');
  }
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  local bool bReturn;

  Super.HandleSpellRictusempra(spell,vHitLocation);
  GotoState('stunned');
  return True;
}

function Puke()
{
    local Vector SpawnLocation;
    local Rotator SpawnRotation;
    local Vector ForwardVector;
    local Actor NewActor;

    // Get the current location and rotation of the actor
    SpawnLocation = Location;
    SpawnRotation = Rotation;

    // Compute the forward direction vector from the rotation
    ForwardVector = vector(SpawnRotation);

    // Calculate the spawn location 100 units in front of the actor
    SpawnLocation += ForwardVector * PukeDistance;

    // Spawn the actor at the calculated location
    NewActor = Spawn(Class'MocaOmniPak.BundimunSpray',Owner,, SpawnLocation, self.Rotation);
}

function bool DetermineHPDistance()
{
    return Abs(VSize(Location - PlayerHarry.Location)) < triggerDistance;
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
        if (DetermineHPDistance())
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
        AmbientSound = None;
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_sink');
        PlayAnim('Sink');
        FinishAnim();
        SetCollision(false, false, false);
        GotoState('underground');
}


state toabove
{
    begin:
        PlaySound(Sound'MocaSoundPak.Creatures.bundimun_rise');
        SetCollision(true, true, true);
        PlayAnim('Rise');
        FinishAnim();
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
        if (!DetermineHPDistance() && !StayAboveGround)
        {
            GotoState('tounder');
        }
        else
        {
            Puke();
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
        PlayAnim('Bounce',,,,'Move');
        SpawnKillParticles();
    }

    function SpawnKillParticles()
    {
        local Rotator SpawnRotation;

        SpawnRotation.Pitch = 16407;
        SpawnRotation.Yaw = 0;
        SpawnRotation.Roll = 0;
        KillEmit = Spawn(class'MocaOmniPak.BundimunDeath',Owner,,Location,SpawnRotation);
    }

    begin:
        Sleep(2.0);
        bCantStandOnMe=True;
        KillEmit.Destroy();
        FinishAnim();
        Destroy();
}

defaultproperties
{
    bCantStandOnMe=True
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
    CollisionHeight=20
    CollisionRadius=20
    DebugErrMessage="The MOCABundimun class requires MOCAharry, not the regular harry class.";
}