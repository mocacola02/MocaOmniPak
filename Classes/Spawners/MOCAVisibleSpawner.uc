class MOCAVisibleSpawner extends MOCASpawner;

struct Sounds
{
  var() Sound Opening;
  var() Sound Closing;
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

var(MOCASpawnGlobal) bool bResetGlobalOffsetWhenDone;

var(MOCAVisibleSpawnAnimations) Animations spawnAnims;
var(MOCAVisibleSounds) Sounds visibleSpawnSounds;

var bool bAnimCooldown;

auto state stateDormant
{
    event BeginState()
    {
        numOfSpawns = 0;
        eVulnerableToSpell = defaultSpell;
    }

    event EndState()
    {
        maxLives--;
        eVulnerableToSpell = SPELL_None;
    }

    begin:
        LoopAnim(spawnAnims.Idle);
}


state stateSpawn
{
    event EndState()
    {
        bAnimCooldown = false;
    }

    begin:
        if (!bAnimCooldown)
        {
            if (maxLives <= 0)
            {
				if (bResetGlobalOffsetWhenDone)
				{
					GlobalSpawnOffset = vect(0,0,0);
				}

                PlayAnim(spawnAnims.FinalSpawnEnd);
                PlaySound(visibleSpawnSounds.Ending);
            }
            else
            {
                PlayAnim(spawnAnims.Spawning); 
                PlaySound(visibleSpawnSounds.Opening);
            }
        }

        SpawnItem();
        bAnimCooldown = true;
        sleep(listOfSpawns[currentSpawnIndex].spawnDelay);

        if (numOfSpawns > maxSpawns)
        {
            GotoState('stateDone');
        }

        goto('begin');
}

state stateDone
{
    begin:
        FinishAnim();
        if (maxLives <= 0)
        {
            //PlayAnim(spawnAnims.FinalSpawnEnd);
            //FinishAnim();
            LoopAnim(spawnAnims.DoneIdle);
        }
        else
        {
            PlayAnim(spawnAnims.EndSpawning);
            PlaySound(visibleSpawnSounds.Closing);
            FinishAnim();
            GotoState('stateDormant');
        }
}

defaultproperties
{
    listOfSpawns(0)=(actorToSpawn=Class'Jellybean',spawnChance=255,spawnDelay=0.1,spawnSound=Sound'spawn_bean01',spawnParticle=Class'Spawn_flash_1',velocityMult=1.0)
    minAmountToSpawn=4
    maxAmountToSpawn=12
    DrawType=DT_Mesh
    bHidden=false
}