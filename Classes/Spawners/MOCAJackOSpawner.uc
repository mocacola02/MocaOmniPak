//================================================================================
// MOCAJackOSpawner.
//================================================================================
class MOCAJackOSpawner extends MOCAVisibleSpawner;


defaultproperties
{
	SpawnerAnims=(Spawning=Scream,EndSpawning=None,Idle=Rest,DoneIdle=Rest,FinalSpawnEnd=Scream)
	SpawnerSounds=(Opening=Sound'MocaSoundPak.jacko_spawn)

	Mesh=SkeletalMesh'MocaModelPak.skJackOLanternMesh'
	AmbientGlow=32
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
	bAlignBottomAlways=True
}