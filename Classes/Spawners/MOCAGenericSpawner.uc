//================================================================================
// MOCAGenericSpawner.
//================================================================================

//Work in progress. Optimization and cleanup needed

class MOCAGenericSpawner extends HPawn;

const MAX_SPAWNED_GOODIES= 8;
struct MaxMin
{
  var() int Max;
  var() int Min;
};
struct Sounds
{
  var() Sound Opening;
  var() Sound Closing;
  var() Sound Spawning;
  var() Sound Ending;
};

struct Animations
{
  var() name Spawning;
  var() name EndSpawning;
  var() name Idle;
  var() name DoneIdle;
  var() name FinalSpawnEnd;
};

var() Class<Actor> GoodieToSpawn[8];
var() int GoodiesNumber[8];
var() int GoodiesProbability[8]; //Moca: Chance for each goodie to spawn, listed in order of GoodieToSpawn. The higher the number, the higher the chance of spawning.
var() name EventName;
var() Animations Anims;
var() Sounds Snds;
var() MaxMin Limits;
var() name StartBone;
var() Vector StartPos;
var() Vector StartVel;
var() Class<ParticleFX> BaseParticles;
var() float BaseDelay;
var() float GoodieDelay;
var() int Lives;
var() bool bDestroable;
var() bool bMakeSpawnPersistent;
var() bool WaitForAnimToSpawn; //Moca: Should the opening animation finish before spawning goodies?
var() bool ProbabilityBasedSpawns; //Moca: Should GoodiesProbability be taken into account?
var() bool EndOnFinalSpawn; //Moca: Should it jump to the ending animation immediately on the last spawn?
var() bool NoDelayForEndOnFinal; //Moca: Should there be no delay on the final spawn if EndOnFinalSpawn = true

var() Sound HitSounds[3]; //Moca: Selection of hit sounds to use if randomHitSounds = True
var() Sound CloseSounds[3]; //Moca: Selection of close sounds to use if randomHitSounds = True
var() bool randomHitSounds; //Moca: Should hitting it use random hit & close sounds

var bool bInitialized;
var Vector BaseParticlePos;
var bool bSpawnExactNumbers;
var int HowManyObjectsToSpawn;
var int RandomNums;
var int CurrentNum;
var int CurrentNum1;
var ESpellType eVulnerableToSpellSaved;


auto state stateStart
{
begin:
  if ( Lives <= 0 )
  {
    if ( Anims.DoneIdle != 'None' )
    {
      LoopAnim(Anims.DoneIdle);
    }
  } else //{
    if ( Anims.Idle != 'None' )
    {
      LoopAnim(Anims.Idle);
    }
  //}
}

state stateEnd
{
begin:
  if ( bDestroable )
  {
    Destroy();
  }
  if ( Anims.DoneIdle != 'None' )
  {
    PlaySound(Snds.Ending,SLOT_Misc);
    PlayAnim(Anims.FinalSpawnEnd);
    FinishAnim();
    GotoState('stateEndIdle');
  }
}

state stateEndIdle
{
  begin:
      eVulnerableToSpell = SPELL_None;
      LoopAnim(Anims.DoneIdle);
}

state stateHitBySpell
{
begin:
  // eVulnerableToSpell = 0;
  eVulnerableToSpell = SPELL_None;
  if ( Lives > 0 )
  {
    Lives--;
  }
  //FinishAnim();
  if ( Anims.Spawning != 'None' )
  {
    if (randomHitSounds)
    {
      DetermineHitSFX();
    }
    if ( Snds.Opening != None )
    {
      PlaySound(Snds.Opening,SLOT_None);
    }
    PlayAnim(Anims.Spawning);
    Sleep(BaseDelay);
    if (WaitForAnimToSpawn)
    {
        FinishAnim();
    }
  }
  if ( BaseParticles != None )
  {
    FindBaseParticlePos();
    Spawn(BaseParticles,,,[SpawnLocation]BaseParticlePos);
  }
  if ( Limits.Min >= Limits.Max )
  {
    RandomNums = Limits.Min;
  } else {
    RandomNums = RandRange(Limits.Min,Limits.Max);
	}
	if (  !bSpawnExactNumbers )
    {
      // CurrentNum = 0;
      // if ( CurrentNum < RandomNums )
	  for(CurrentNum = 0; CurrentNum < RandomNums; CurrentNum++)
      {
        Sleep(GoodieDelay);
        if (ProbabilityBasedSpawns)
        {
            SpawnWeightedObject(-1);
        }
        else
        {
            SpawnObject(-1);
        }
        
        // CurrentNum++;
      }
    } 
    else {
      // CurrentNum = 0;
      // if ( CurrentNum < 8 )
	  for(CurrentNum = 0; CurrentNum < MAX_SPAWNED_GOODIES; CurrentNum++)
      {
        // CurrentNum1 = 0;
        // if ( CurrentNum1 < GoodiesNumber[CurrentNum] )
		for(CurrentNum1 = 0; CurrentNum1 < GoodiesNumber[CurrentNum]; CurrentNum1++)
        {
          Sleep(GoodieDelay);
          if (ProbabilityBasedSpawns)
          {
            SpawnWeightedObject(CurrentNum);
          }
          else
          {
            SpawnObject(CurrentNum);
          }
          // CurrentNum1++;
        }
        // CurrentNum++;
      }
    }
  if ( Snds.Spawning != None )
  {
    PlaySound(Snds.Spawning,SLOT_Misc);
  }
  if ( Lives > 0 )
  {
    if ( Anims.EndSpawning != 'None' )
    {
      if ( Snds.Closing != None )
      {
        PlaySound(Snds.Closing,SLOT_None);
      }
      PlayAnim(Anims.EndSpawning);
    }
    FinishAnim();
    eVulnerableToSpell = eVulnerableToSpellSaved;
    GotoState('stateStart');
  } else {
    // eVulnerableToSpell = 0;
	eVulnerableToSpell = SPELL_None;
    if ( EventName != 'None' )
    {
      TriggerEvent(EventName,None,None);
    }
    GotoState('stateEnd');
  }
}


state stateEndSpawn
{
begin:
  BaseDelay = 0;
  if (NoDelayForEndOnFinal)
  {
    GoodieDelay = 0;
  }
  // eVulnerableToSpell = 0;
  eVulnerableToSpell = SPELL_None;

  if ( Anims.FinalSpawnEnd != 'None' )
  {
    if ( Snds.Opening != None )
    {
      PlaySound(Snds.Opening,SLOT_None);
    }
    PlayAnim(Anims.FinalSpawnEnd);
    Sleep(BaseDelay);
    if (WaitForAnimToSpawn)
    {
        FinishAnim();
    }
  }
  if ( BaseParticles != None )
  {
    FindBaseParticlePos();
    Spawn(BaseParticles,,,[SpawnLocation]BaseParticlePos);
  }
  if ( Limits.Min >= Limits.Max )
  {
    RandomNums = Limits.Min;
  } else {
    RandomNums = RandRange(Limits.Min,Limits.Max);
	}
	if (  !bSpawnExactNumbers )
    {
      // CurrentNum = 0;
      // if ( CurrentNum < RandomNums )
	  for(CurrentNum = 0; CurrentNum < RandomNums; CurrentNum++)
      {
        Sleep(GoodieDelay);
        if (ProbabilityBasedSpawns)
        {
            SpawnWeightedObject(-1);
        }
        else
        {
            SpawnObject(-1);
        }
        
        // CurrentNum++;
      }
    } 
    else {
      // CurrentNum = 0;
      // if ( CurrentNum < 8 )
	  for(CurrentNum = 0; CurrentNum < MAX_SPAWNED_GOODIES; CurrentNum++)
      {
        // CurrentNum1 = 0;
        // if ( CurrentNum1 < GoodiesNumber[CurrentNum] )
		for(CurrentNum1 = 0; CurrentNum1 < GoodiesNumber[CurrentNum]; CurrentNum1++)
        {
          Sleep(GoodieDelay);
          if (ProbabilityBasedSpawns)
          {
            SpawnWeightedObject(CurrentNum);
          }
          else
          {
            SpawnObject(CurrentNum);
          }
          // CurrentNum1++;
        }
        // CurrentNum++;
      }
    }
  if ( Snds.Spawning != None )
  {
    PlaySound(Snds.Ending,SLOT_Misc);
  }
  if ( Lives > 0 )
  {
    FinishAnim();
    eVulnerableToSpell = eVulnerableToSpellSaved;
    GotoState('stateEndIdle');
  } else {
    // eVulnerableToSpell = 0;
	eVulnerableToSpell = SPELL_None;
    if ( EventName != 'None' )
    {
      TriggerEvent(EventName,None,None);
    }
    GotoState('stateEndIdle');
  }
}

function PostBeginPlay()
{
  local int I;

  Super.PostBeginPlay();
  if (  !bInitialized )
  {
    eVulnerableToSpellSaved = eVulnerableToSpell;
    bInitialized = True;
  }
  HowManyObjectsToSpawn = 0;

  for(I = 0; I < MAX_SPAWNED_GOODIES; I++)
  {
    if ( GoodieToSpawn[I] == None )
    {
	  break;
    }
  }
  HowManyObjectsToSpawn = I;
  if ( Lives <= 0 )
  {
    HowManyObjectsToSpawn = 0;
  }
  bSpawnExactNumbers = False;

  for(I = 0; I < MAX_SPAWNED_GOODIES; I++)
  {
    if ( GoodiesNumber[I] != 0 )
    {
      bSpawnExactNumbers = True;
    }
  }
  if ( HowManyObjectsToSpawn <= 0 )
  {
	eVulnerableToSpell = SPELL_None;
  }
}

function FindBaseParticlePos()
{
  local Vector Dir;
  local int bNum;

  Dir = StartPos;
  Dir = Dir >> Rotation;
  if ( StartBone != 'None' )
  {
    bNum = BoneNumber(StartBone);
    if ( bNum >= 0 )
    {
      Dir = BonePos(StartBone);
      Dir = Dir - Location;
    }
  }
  BaseParticlePos = Dir + Location;
}

function SpawnObject (int Index)
{
  local Vector Dir;
  local Vector Vel;
  local Actor newSpawn;
  local int bNum;
  local Vector V;
  local Vector N;
  local float Length;
  local float angle;

  Log('Spawning NONWeighted Items');

  if ( HowManyObjectsToSpawn <= 0 )
  {
    return;
  }
  N = vector(Rotation);
  N.Z = 0.0;
  // if ( True )
  while(True)
  {
    angle = RandRange(0.0,6.28319979);
    V.X = Cos(angle);
    V.Y = Sin(angle);
    V.Z = 0.0;
    if ( (N.X == 0.0) && (N.Y == 0.0) )
    {
      // goto JL00CA;
	  break;
    }
    if ( (V Dot N) / VSize2D(N) > 0.69999999 )
    {
      // goto JL00CA;
	  break;
    }
    // goto JL0029;
  }
  Length = RandRange(50.0,100.0);
  Vel.X = Length * Cos(angle);
  Vel.Y = Length * Sin(angle);
  Vel.Z = 100.0 + FRand() * 100;
  Dir = StartPos;
  Dir = Dir >> Rotation;
  if ( StartBone != 'None' )
  {
    bNum = BoneNumber(StartBone);
    if ( bNum >= 0 )
    {
      Dir = BonePos(StartBone);
      Dir = Dir - Location;
    }
  }
  Dir = Dir + Location;
  if ( Index < 0 )
  {
    newSpawn = Spawn(GoodieToSpawn[Rand(HowManyObjectsToSpawn)],,,[SpawnLocation]Dir);
  } else {
    newSpawn = Spawn(GoodieToSpawn[Index],,,[SpawnLocation]Dir);
  }
  if ( (StartVel.X == 0) && (StartVel.Y == 0) && (StartVel.Z == 0) )
  {
    newSpawn.Velocity = Vel;
  } else {
    newSpawn.Velocity = StartVel;
  }
  newSpawn.SetPhysics(PHYS_Falling);
  switch (Rand(3))
  {
    case 0:
    Spawn(Class'Spawn_flash_1',,,[SpawnLocation]Dir);
    break;
    case 1:
    Spawn(Class'Spawn_flash_2',,,[SpawnLocation]Dir);
    break;
    case 2:
    Spawn(Class'Spawn_flash_3',,,[SpawnLocation]Dir);
    break;
    default:
  }
  switch (Rand(3))
  {
    case 0:
    PlaySound(Sound'spawn_bean01');
    break;
    case 1:
    PlaySound(Sound'spawn_bean02');
    break;
    case 2:
    PlaySound(Sound'spawn_bean03');
    break;
    default:
  }
  newSpawn.bPersistent = bMakeSpawnPersistent;
}

function SpawnWeightedObject(int Index)
{
    local Vector Dir;
    local Vector Vel;
    local Actor newSpawn;
    local int bNum;
    local Vector V;
    local Vector N;
    local float Length;
    local float angle;
    local int i;
    local int SpawnChance;
    local int TotalWeight;
    local int RandomWeight;

    Log('Spawning Weighted Items');

    if (HowManyObjectsToSpawn <= 0)
    {
        return;
    }

    N = vector(Rotation);
    N.Z = 0.0;

    while(True)
    {
        angle = RandRange(0.0, 6.28319979);
        V.X = Cos(angle);
        V.Y = Sin(angle);
        V.Z = 0.0;
        if ((N.X == 0.0) && (N.Y == 0.0))
        {
            break;
        }
        if ((V Dot N) / VSize2D(N) > 0.69999999)
        {
            break;
        }
    }

    Length = RandRange(50.0, 100.0);
    Vel.X = Length * Cos(angle);
    Vel.Y = Length * Sin(angle);
    Vel.Z = 100.0 + FRand() * 100;
    Dir = StartPos;
    Dir = Dir >> Rotation;

    if (StartBone != 'None')
    {
        bNum = BoneNumber(StartBone);
        if (bNum >= 0)
        {
            Dir = BonePos(StartBone);
            Dir = Dir - Location;
        }
    }

    Dir = Dir + Location;

    // Calculate the total weight
    TotalWeight = 0;
    for (i = 0; i < 8; i++)
    {
        TotalWeight += GoodiesProbability[i];
    }

    // Generate a random number up to the total weight
    RandomWeight = Rand(TotalWeight);

    // Determine which item to spawn based on probability
    SpawnChance = 0;
    for (i = 0; i < 8; i++)
    {
        SpawnChance += GoodiesProbability[i];
        if (RandomWeight < SpawnChance)
        {
            Index = i;
            break;
        }
    }

    newSpawn = Spawn(GoodieToSpawn[Index],,,[SpawnLocation]Dir);

    if ((StartVel.X == 0) && (StartVel.Y == 0) && (StartVel.Z == 0))
    {
        newSpawn.Velocity = Vel;
    }
    else
    {
        newSpawn.Velocity = StartVel;
    }

    newSpawn.SetPhysics(PHYS_Falling);

    switch (Rand(3))
    {
        case 0:
            Spawn(Class'Spawn_flash_1',,,[SpawnLocation]Dir);
            break;
        case 1:
            Spawn(Class'Spawn_flash_2',,,[SpawnLocation]Dir);
            break;
        case 2:
            Spawn(Class'Spawn_flash_3',,,[SpawnLocation]Dir);
            break;
        default:
    }

    switch (Rand(3))
    {
        case 0:
            PlaySound(Sound'spawn_bean01');
            break;
        case 1:
            PlaySound(Sound'spawn_bean02');
            break;
        case 2:
            PlaySound(Sound'spawn_bean03');
            break;
        default:
    }

    newSpawn.bPersistent = bMakeSpawnPersistent;
}


function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellFlipendo(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellAlohomora(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellDiffindo (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellDiffindo(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellEcto (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellEcto(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellLumos (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellLumos(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellRictusempra(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellSkurge (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellSkurge(spell,vHitLocation);
  CheckProperState();
  return True;
}

function bool HandleSpellSpongify (optional baseSpell spell, optional Vector vHitLocation)
{
  Super.HandleSpellSpongify(spell,vHitLocation);
  CheckProperState();
  return True;
}


function CheckProperState ()
{
  if (Lives == 1 && EndOnFinalSpawn)
  {
    GotoState('stateEndSpawn');
  } 
  else
  {
    GotoState('stateHitBySpell');
  }
}

function DetermineHitSFX()
{
    local int randNum;

    randNum = Rand(ArrayCount(HitSounds));

    Snds.Opening = HitSounds[randNum];
    Snds.Ending = CloseSounds[randNum];
}

defaultproperties
{
     Anims=(Spawning=Open,EndSpawning=Close,Idle=Start,DoneIdle=End)
     Limits=(Max=6,Min=2)
     StartPos=(Z=40)
     Lives=1
     bMakeSpawnPersistent=True
     Physics=PHYS_Falling
     eVulnerableToSpell=SPELL_Flipendo
     bPersistent=True
     Mesh=SkeletalMesh'HPModels.skcigarboxMesh'
     CollideType=CT_Shape
     bBlockPlayers=False
}
