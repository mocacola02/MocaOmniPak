//================================================================================
// Watcher.
//================================================================================

class MOCAWatcher extends MOCAChar;

var bool lastWasRight;
var bool firstLook;
//var harry PlayerHarry;
var MOCAStealthTrigger stealthTrig1;
var MOCAStealthTrigger stealthTrig2;
//var MOCABeam stealthLight;
var int randLook;
var bool isAwake;

var() float timeToLook;
var() bool randomTimeToLook;
var() float minTime;
var() float maxTime;
var() int randLookProbability;
var() bool asleepOnSpawn;



function PreBeginPlay()
{
  Super.PreBeginPlay();
  PlayerHarry = Harry(Level.PlayerHarryActor);
  GotoState('stateIdle');
  //stealthLight = Spawn(Class'MOCABeam',self);
}

event PostBeginPlay()
{
    Super.PostBeginPlay();
    if (!ActorExistenceCheck(Class'MOCAharry'))
    {
        EnterErrorMode();
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

simulated event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    local Vector LocationForTrigger1;
    local Vector LocationForTrigger2;
    LocationForTrigger1 = BonePos('TriggerPoint2');
    LocationForTrigger2 = BonePos('TriggerPoint');
    stealthTrig1.SetLocation(LocationForTrigger1);
    stealthTrig2.SetLocation(LocationForTrigger2);
    //stealthLight.SetLocation(LocationForTrigger);
}

function determineTTL (bool lookBack)
  {
    if (randomTimeToLook)
    {
      /*if (!lookback)
      {
        minTime = minTime - 0.5;
      }*/
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
    if (stealthTrig1 != None)
    {
      stealthTrig1.Destroy();
      //stealthLight.TurnDynamicLightOff();
    }
    if (stealthTrig2 != None)
    {
      stealthTrig2.Destroy();
    }
    if (!asleepOnSpawn)
    {
      GotoState('stateIdle');
    }
    MultiSkins[1] = Texture'MocaTexturePak.Misc.transparent';
    LoopAnim('idle');
}

state stateIdle
{
  begin:
    if (stealthTrig1 == None)
    {
      stealthTrig1 = Spawn(Class'MOCAStealthTrigger',self);
      //stealthLight.TurnDynamicLightOn();
      stealthTrig1.attachedToKnight = True;
    }
    if (stealthTrig2 == None)
    {
      stealthTrig2 = Spawn(Class'MOCAStealthTrigger',self);
      stealthTrig2.attachedToKnight = True;
    }
    //Log("Idling");
    determineTTL(False);
    randLook = RandRange(0, randLookProbability);
    //Log(randLook);
    sleep(timeToLook);
    if (firstLook)
    {
      //Log("Determining first look");
      lastWasRight = bool(RandRange(0, 1));
      firstLook = False;
    }
    if (lastWasRight && randLook == 0) // 25% chance to switch direction again
    {
      //Log("try right");
      GotoState('lookRight');
    }
    else if (!lastWasRight && randLook == 0) // 25% chance to switch direction again
    {
      //Log("try left");
      GotoState('lookLeft');
    }
    else if (!lastWasRight) {
      //Log("try right");
      GotoState('lookRight');
    }
    else {
      //Log("try left");
      GotoState('lookLeft');
    }
}


state lookLeft
{
  begin:
    lastWasRight = False;
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    //Log("Left");
    determineTTL(True);
    PlayAnim('idle2lookleft');
    FinishAnim();
    LoopAnim('lookleft');
    sleep(timeToLook);
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    PlayAnim('lookleft2idle');
    FinishAnim();
    GotoState('stateIdle'); // Transition back to idle state
}

state lookRight
{
  begin:
    lastWasRight = True;
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    //Log("Right");
    determineTTL(True);
    PlayAnim('idle2lookright');
    FinishAnim();
    LoopAnim('lookright');
    sleep(timeToLook);
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move', SLOT_Misc, 1.0, false, 1024);
    PlayAnim('lookright2idle');
    FinishAnim();
    GotoState('stateIdle'); // Transition back to idle state
}

state catch
{
  begin:
    LoopAnim('wobble');
    PlaySound(MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks');
    sleep(2.0);
    GotoState('stateIdle');
}

defaultproperties
{
  Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
  firstLook=True
  timeToLook=1.0
  timeToLook=1.0
  randomTimeToLook=True
  DrawScale=1.2
  CollisionHeight=58
  randLookProbability=3
  minTime=1.5
  maxTime=4.5
  ShadowScale=0.5
  DebugErrMessage="The MOCAWatcher class requires MOCAharry, not the regular harry class.";
}