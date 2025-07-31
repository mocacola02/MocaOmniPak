//================================================================================
// Watcher.
//================================================================================

class MOCAWatcher extends MOCAChar;

var bool lastWasRight;
var bool firstLook;
var MOCAStealthTrigger stealthTrig1;
var int randLook;
var bool isAwake;

var() float timeToLook;         //How long to look in a direction. Ignored if randomTimeToLook is true. Def: 1.0
var() bool randomTimeToLook;    //Whether or not to randomize TTL. Def: True
var() float minTime;            //Minimum time to look when determining a random TTL value. Def: 1.5
var() float maxTime;            //Maximum time to look when determining a random TTL value. Def: 4.5
var() bool asleepOnSpawn;       //Should the watcher be inactive on spawn (requires a trigger to be enabled). Def: false



function PreBeginPlay()
{
  Super.PreBeginPlay();
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (!ActorExistenceCheck(Class'MOCAharry'))
    {
      EnterErrorMode();
    }
    else
    {
      PlayerHarry = Harry(Level.PlayerHarryActor);
      GotoState('stateIdle');
    }
}

event Bump( Actor Other )
  {
    Log("Touched by" $ Other);
    if (!IsInState('asleep') && !PlayerHarry.IsInState('caught') && (Other.IsA('MOCAharry') || Other.IsA('harry')))
    {
      PlayerHarry.GotoState('caught');
      GotoState('catch');
    }
  }

function Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    local Vector LocationForTrigger1;
    LocationForTrigger1 = BonePos('TriggerPoint');
    stealthTrig1.SetLocation(LocationForTrigger1);
}

function determineTTL (bool lookBack)
  {
    if (randomTimeToLook)
    {
      timeToLook = RandRange(minTime, maxTime);
    }
  }

function playSqueak ()
{
  local float squeakPitch;
  squeakPitch = RandRange(0.75, 1.25);
  PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024, squeakPitch);
}

function Trigger (Actor Other, Pawn EventInstigator)
  {
    if (isAwake)
    {
      asleepOnSpawn = False;
      PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks');
      GotoState('asleep');
    }
    else
    {
      MultiSkins[1] = Texture'MocaTexturePak.Skins.beam';
      PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks');
      GotoState('stateIdle');
    }
  }

auto state asleep 
{
  begin:
  Log("KNIGHT IS SLEEPING!!!!!!!!!!!");
    if (stealthTrig1 != None)
    {
      stealthTrig1.Destroy();
    }
    if (!asleepOnSpawn)
    {
      GotoState('stateIdle');
    }
    MultiSkins[1] = Texture'MocaTexturePak.Misc.transparent';
    LoopAnim('Idle');
}

state stateIdle
{
  begin:
    Log("KNIGHT IS IDLE!!!!!!!!!!!!!!!!!");
    if (stealthTrig1 == None)
    {
      stealthTrig1 = Spawn(Class'MOCAStealthTrigger',self);
      stealthTrig1.attachedToKnight = True;
    }
    determineTTL(False);
    randLook = RandRange(0, 1);
    sleep(timeToLook);
    if (randLook == 0)
    {
      GotoState('lookLeft');
    }
    else
    {
      GotoState('lookRight');
    }
}


state lookLeft
{
  begin:
    lastWasRight = False;
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    Log("Left");
    determineTTL(True);
    PlayAnim('Idle2Left');
    FinishAnim();
    LoopAnim('IdleLeft');
    sleep(timeToLook);
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    PlayAnim('Left2Idle');
    FinishAnim();
    GotoState('stateIdle'); // Transition back to idle state
}

state lookRight
{
  begin:
    lastWasRight = True;
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    Log("Right");
    determineTTL(True);
    PlayAnim('Idle2Right');
    FinishAnim();
    LoopAnim('IdleRight');
    sleep(timeToLook);
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    PlayAnim('Right2Idle');
    FinishAnim();
    GotoState('stateIdle'); // Transition back to idle state
}

state catch
{
  begin:
    Log("CAUGHT HARRY!!!!!!!!!!!!!!!!!");
    LoopAnim('StandHit');
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks');
    sleep(2.0);
    GotoState('stateIdle');
}

defaultproperties
{
  Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
  firstLook=True
  timeToLook=1.0
  randomTimeToLook=True
  DrawScale=1.2
  CollisionHeight=58
  minTime=1.5
  maxTime=4.5
  ShadowScale=0.5
  DebugErrMessage="The MOCAWatcher class requires MOCAharry, not the regular harry class.";
}