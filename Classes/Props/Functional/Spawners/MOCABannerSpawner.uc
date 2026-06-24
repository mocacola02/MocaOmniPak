//================================================================================
// MOCABannerSpawner.
//================================================================================
class MOCABannerSpawner extends MOCAVisibleSpawner;

defaultproperties
{
	bRemoveCollisionWhenDone=True
	SpawnerAnims=(Spawning=HitRight,EndSpawning=None,Idle=InsideIdle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=MultiSound'MocaOmniResources.Spawners.banner_hit_multi',Ending=MultiSound'MocaOmniResources.Spawners.banner_rollup_multi')
	Mesh=SkeletalMesh'MocaOmniResources.skBanner'
	AmbientGlow=32
	CollisionRadius=8
	CollisionWidth=50
	CollisionHeight=95
	CollideType=CT_Box
	bBlockCamera=False
	bBlockPlayers=False
}
