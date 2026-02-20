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
		eVulnerableToSpell=SPELL_None;
		FinishAnim();
		if ( ShouldDie() )
		{
			LoopAnim(SpawnerAnims.DoneIdle);
		}
		else
		{
			PlayAnim(SpawnerAnims.EndSpawning);
			PlaySound(SpawnerSounds.Closing);
			FinishAnim();
		}

		Sleep(2.0);
		GotoState('stateFadeAway');
}

state stateFadeAway
{
	event Tick(float DeltaTime)
	{
		Opacity -= FadeSpeed * DeltaTime;

		if ( Opacity <= 0.0 )
		{
			DetermineNextState();
		}
	}
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