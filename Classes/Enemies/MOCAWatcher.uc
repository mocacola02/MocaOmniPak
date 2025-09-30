//================================================================================
// Watcher.
//================================================================================

// TODO: Rewrite this, pretty old class at this point

class MOCAWatcher extends MOCAChar;

var bool bLastWasRight;
var bool bFirstLook;
var MOCAStealthTrigger stealthTrigger;
var int randLook;
var bool bIsAwake;

var() float timeToLook;         // Moca: How long to look in a direction. Ignored if bRandomTimeToLook is true. Def: 1.0
var() bool bRandomTimeToLook;    // Moca: Whether or not to randomize TTL. Def: True
var() float minTime;            // Moca: Minimum time to look when determining a random TTL value. Def: 1.5
var() float maxTime;            // Moca: Maximum time to look when determining a random TTL value. Def: 4.5
var() bool bAsleepOnSpawn;       // Moca: Should the watcher be inactive on spawn (requires a trigger to be enabled). Def: false

event PreBeginPlay()
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
      GotoState('stateIdle');
    }
}

event Bump( Actor Other )
  {
    Log("Touched by" $ Other);
    if (!IsInState('asleep') && !PlayerHarry.IsInState('caught') && Other.IsA('MOCAharry'))
    {
      PlayerHarry.GotoState('caught');
      GotoState('catch');
    }
  }

event Tick(float DeltaTime)
{
    Super.Tick(DeltaTime);
    local Vector LocationForTrigger;
    LocationForTrigger = BonePos('TriggerPoint');
    stealthTrigger.SetLocation(LocationForTrigger);
}

function determineTTL (bool lookBack)
  {
	if (bRandomTimeToLook)
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

event Trigger (Actor Other, Pawn EventInstigator)
{
	if (bIsAwake)
	{
		bAsleepOnSpawn = False;
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
		if (stealthTrigger != None)
		{
			stealthTrigger.Destroy();
		}
		if (!bAsleepOnSpawn)
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
		if (stealthTrigger == None)
		{
			stealthTrigger = Spawn(Class'MOCAStealthTrigger',self);
			stealthTrigger.bAttachedToKnight = True;
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
		bLastWasRight = False;
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
    bLastWasRight = True;
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
  bFirstLook=True
  timeToLook=1.0
  bRandomTimeToLook=True
  DrawScale=1.2
  CollisionHeight=58
  minTime=1.5
  maxTime=4.5
  ShadowScale=0.5
  DebugErrMessage="The MOCAWatcher class requires MOCAharry, not the regular harry class.";
}