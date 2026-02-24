//================================================================================
// MOCAPumpkinSpawner.
//================================================================================
class MOCAPumpkinSpawner extends MOCAVisibleSpawner;

var() bool bDespawnWhenDone;	// Moca: Should pumpkin disappear and destroy when lives run out
var() float FadeSpeed;			// Moca: Speed to fade out if bDespawnWhenDone


///////////
// States
///////////

state stateDone
{
	begin:
		// Make us uncastable
		eVulnerableToSpell = SPELL_None;
		// Finish anim
		FinishAnim();
		// Sleep for 2 seconds then fade away
		Sleep(2.0);
		GotoState('stateFadeAway');
}

state stateFadeAway
{
	event BeginState()
	{
		Log(string(Self)$": Fading away");
		Opacity = 1.0;
	}

	event Tick(float DeltaTime)
	{
		// Decrease our opacity
		Opacity -= FadeSpeed * DeltaTime;

		// If we're invisible
		if ( Opacity <= 0.0 )
		{
			Log(string(Self)$": Done fading away");
			// If we should die, destroy self
			if ( ShouldDie() )
			{
				GotoState('stateDestroy');
			}
			// Otherwise, grow back
			else
			{
				GotoState('stateGrow');
			}
		}
	}
}

state stateGrow
{
	begin:
		// Play grow anim
		PlayAnim('grow',,0.0);
		// Become visible again
		Opacity = 1.0;
		// Finish anim then go to idle
		FinishAnim();
		GotoState('stateIdle');
}


defaultproperties
{
	FadeSpeed=0.5

	bRandomSpawnDirection=True
	SpawnerAnims=(Spawning=Hit,EndSpawning=Grow,Idle=None,DoneIdle=HitIdle,FinalSpawnEnd=None)
	SpawnerSounds=(Opening=Sound'MocaSoundPak.pumpkin_explode',Closing=Sound'MocaSoundPak.pumpkin_spawn',Ending=Sound'MocaSoundPak.pumpkin_explode')

	Mesh=SkeletalMesh'MocaModelPak.skPumpkinSpawner'
	DrawScale=1.3
	AmbientGlow=32
	bAlignBottomAlways=True
	PrePivot=(X=0,Y=0,Z=-96)
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
}