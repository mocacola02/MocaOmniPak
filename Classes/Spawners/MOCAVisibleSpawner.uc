//================================================================================
// MOCAVisibleSpawner.
//================================================================================
class MOCAVisibleSpawner extends MOCASpawner;

struct SpawnSounds
{
	var() Sound Opening;	// Sound to play when opening	(starting spawn)
	var() Sound Closing;	// Sound to play when closing (ending spawn)
	var() Sound Ending;		// Sound to play on last spawn
};

struct SpawnAnimations
{
	var() name Spawning;	// Animation to play on spawn
	var() name EndSpawning;	// Animation to play when ending spawn
	var() name Idle;		// Animation to play when idle
	var() name DoneIdle;	// Animation to play when done
	var() name FinalSpawnEnd;// Animation to play on final spawn
};

var SpawnAnimations SpawnerAnims;	// Spawner animations
var SpawnSounds SpawnerSounds;		// Spawner sounds

var bool bAnimCooldown;	// Are we on animation cooldown


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		Super.BeginState();
		// Loop idle anim
		LoopAnim(SpawnerAnims.Idle);
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
	}
}

state stateSpawn
{
	event EndState()
	{
		// End anim cooldown
		bAnimCooldown = False;
		Super.EndState();
	}

	begin:
		Log(string(Self)$": Spawning items!");
		// If not on anim cooldown
		if ( !bAnimCooldown )
		{
			// If we should die, play final spawn anim and sound
			if ( ShouldDie() )
			{
				PlayAnim(SpawnerAnims.FinalSpawnEnd);
				PlaySound(SpawnerSounds.Ending);
			}
			// Otherwise, play normal spawn anim and sound
			else
			{
				PlayAnim(SpawnerAnims.Spawning);
				PlaySound(SpawnerSounds.Opening);
			}
		}
		// Spawn item
		SpawnItem();
		// Set anim cooldown
		bAnimCooldown = True;
		// Wait for spawn delay
		Sleep(GetSpawnDelay());
		// If spawn count exceed max spawn count, go to done
		if ( CurrentSpawnCount >= FinalMaxSpawnCount )
		{
			Log(string(Self)$": Finished spawning items, going to stateDone");
			GotoState('stateDone');
		}
		// Otherwise, loop
		Goto('begin');
}

state stateDone
{
	begin:
		// Finish any animations
		FinishAnim();
		// If we should die
		if ( ShouldDie() )
		{
			// Make us uncastable
			eVulnerableToSpell = SPELL_None;
			// Loop done anim
			LoopAnim(SpawnerAnims.DoneIdle);
		}
		// Otherwise
		else
		{
			// Play end anim & sound
			PlayAnim(SpawnerAnims.EndSpawning);
			PlaySound(SpawnerSounds.Closing);
			// Finish anim
			FinishAnim();
			// Go to idle
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