//================================================================================
// MOCATapestrySpawner.
//================================================================================
class MOCATapestrySpawner extends MOCAVisibleSpawner;

defaultproperties
{
	SpawnerAnims=(Spawning=Hit,EndSpawning=None,Idle=Idle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=MultiSound'MocaSoundPak.Spawners.multi_banner_hit',Ending=MultiSound'MocaSoundPak.Spawners.multi_rollup_sound')

	Mesh=SkeletalMesh'MocaModelPak.skHP3Tapestry'
	DrawScale=1.3
	PrePivot=(Z=-80)
	AmbientGlow=32
	CollisionRadius=8
	CollisionWidth=50
	CollisionHeight=80
	CollideType=CT_Box
	bBlockCamera=False
	bBlockPlayers=False
}
