//================================================================================
// MOCABannerSpawner.
//================================================================================
class MOCABannerSpawner extends MOCAVisibleSpawner;

defaultproperties
{
	SpawnerAnims=(Spawning=HitRight,EndSpawning=None,Idle=InsideIdle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=MultiSound'MocaSoundPak.Spawners.multi_banner_hit',Ending=MultiSound'MocaSoundPak.Spawners.multi_rollup_sound')
	Mesh=SkeletalMesh'MocaModelPak.skBanner'
	AmbientGlow=32
	CollisionRadius=8
	CollisionWidth=50
	CollisionHeight=95
	CollideType=CT_Box
	bBlockCamera=False
	bBlockPlayers=False
}
