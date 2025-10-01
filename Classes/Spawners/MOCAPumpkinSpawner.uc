//================================================================================
// MOCASkullSpawner.
//================================================================================

class MOCAPumpkinSpawner extends MOCAVisibleSpawner;

var() float RegrowSpeed;
var bool bDoFadeOut;

event Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (bDoFadeOut)
	{
		Opacity = FClamp(Opacity - (1.0 * DeltaTime), 0.0, 1.0);
	}
}

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
			SetCollision(false,false,false);
			PlayAnim('Hit',RandRange(1.34,2.34),0.0);
			PlaySound(visibleSpawnSounds.Ending);
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
			bDoFadeOut = True;
			Sleep(2.0);
			SetCollision(true,true,true);
            PlayAnim(spawnAnims.EndSpawning,RegrowSpeed,0.0);
            PlaySound(visibleSpawnSounds.Closing);
			Sleep(0.2);
			bDoFadeOut = False;
			Opacity = 1.0;
            FinishAnim();
			StopSound(visibleSpawnSounds.Closing);
            GotoState('stateDormant');
        }
}

defaultproperties
{
	spawnAnims=(Spawning=None,EndSpawning=Grow,Idle=None,DoneIdle=HitIdle,FinalSpawnEnd=None)
	visibleSpawnSounds=(Opening=Sound'MocaSoundPak.pumpkin_explode',Closing=Sound'MocaSoundPak.pumpkin_spawn',Ending=Sound'MocaSoundPak.pumpkin_explode')
	Physics=PHYS_None
	Mesh=SkeletalMesh'MocaModelPak.skPumpkinSpawner'
	DrawScale=1.3
	AmbientGlow=32
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
	bBlockPlayers=True
	bAlignBottomAlways=True
	bBlockCamera=True
	PrePivot=(X=0,Y=0,Z=-96)
	listOfSpawns(0)=(actorToSpawn=Class'Jellybean',spawnChance=255,spawnDelay=0.025,spawnSound=Sound'spawn_bean01',spawnParticle=Class'Spawn_flash_1',velocityMult=1.0)
	bUseGlobalSpawnSettings=True
	GlobalSpawnAngle=(X=360,Y=360,Z=0)
	RegrowSpeed=1.0
}
