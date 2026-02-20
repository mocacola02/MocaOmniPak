//================================================================================
// MOCAVisibleSpawner.
//================================================================================
class MOCAVisibleSpawner extends MOCASpawner;

struct SpawnSounds
{
	var() Sound Opening;
	var() Sound Closing;
	var() Sound Ending;
};

struct SpawnAnimations
{
	var() name Spawning;
	var() name EndSpawning;
	var() name Idle;
	var() name DoneIdle;
	var() name FinalSpawnEnd;
};

var() SpawnAnimations SpawnerAnims;
var() SpawnSounds SpawnerSounds;


var bool bAnimCooldown;


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		Super.BeginState();
		LoopAnim(SpawnerAnims.Idle);
	}
}

state stateSpawn
{
	event EndState()
	{
		Super.EndState();
		bAnimCooldown = False;
	}

	begin:
		if ( !bAnimCooldown )
		{
			if ( ShouldDie() )
			{
				PlayAnim(SpawnerAnims.FinalSpawnEnd);
				PlaySound(SpawnerSounds.Ending);
			}
			else
			{
				PlayAnim(SpawnerAnims.Spawning);
				PlaySound(SpawnerSounds.Opening);
			}
		}

		SpawnItem();
		bAnimCooldown = True;
		Sleep(GetSpawnDelay());

		if ( CurrentSpawnCount >= FinalMaxSpawnCount )
		{
			GotoState('stateDone');
		}

		Goto('begin');
}

state stateDone
{
	begin:
		FinishAnim();

		if ( ShouldDie() )
		{
			eVulnerableToSpell=SPELL_None;
			LoopAnim(SpawnerAnims.DoneIdle);
		}
		else
		{
			PlayAnim(SpawnerAnims.EndSpawning);
			PlaySound(SpawnerSounds.Closing);
			FinishAnim();
			GotoState('stateIdle');
		}
}


defaultproperties
{
	DrawType=DT_Mesh
	bHidden=False
	bBlockPlayers=True
	bBlockCamera=True
}