//================================================================================
// MOCASkullSpawner.
//================================================================================

class MOCAPumpkinSpawner extends MOCAVisibleSpawner;

var bool DoFadeOut;

event Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (DoFadeOut)
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
        animCooldown = false;
    }

    begin:
        if (!animCooldown)
        {
			SetCollision(false,false,false);
			PlayAnim('Hit',RandRange(1.34,2.34),0.0);
			PlaySound(visibleSpawnSounds.Ending);
        }

        SpawnItem();
        animCooldown = true;
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
			DoFadeOut = True;
			Sleep(2.0);
			SetCollision(true,true,true);
            PlayAnim(spawnAnims.EndSpawning,1.34,0.0);
            PlaySound(visibleSpawnSounds.Closing);
			Sleep(0.2);
			DoFadeOut = False;
			Opacity = 1.0;
            FinishAnim();
            GotoState('stateDormant');
        }
}

defaultproperties
{
     spawnAnims=(Spawning=None,EndSpawning=Grow,Idle=None,DoneIdle=HitIdle,FinalSpawnEnd=None)
     visibleSpawnSounds=(Opening=Sound'MocaSoundPak.Spawners.skull_hit',Ending=Sound'MocaSoundPak.Spawners.skull_hitend')
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
}
