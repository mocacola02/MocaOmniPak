//================================================================================
// MOCATapestrySpawner.
//================================================================================
class MOCATapestrySpawner extends MOCAVisibleSpawner;

defaultproperties
{
	bRemoveCollisionWhenDone=True
	SpawnerAnims=(Spawning=Hit,EndSpawning=None,Idle=Idle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=MultiSound'MocaOmniResources.Spawners.banner_hit_multi',Ending=MultiSound'MocaOmniResources.Spawners.banner_rollup_multi')

	Mesh=SkeletalMesh'MocaOmniResources.skHP3Tapestry'
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
