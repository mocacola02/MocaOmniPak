//================================================================================
// MOCAJackOSpawner.
//================================================================================
class MOCAJackOSpawner extends MOCAVisibleSpawner;


defaultproperties
{
	SpawnerAnims=(Spawning=Scream,EndSpawning=None,Idle=Rest,DoneIdle=Rest,FinalSpawnEnd=Scream)
	SpawnerSounds=(Opening=Sound'MocaSoundPak.jacko_spawn)
	GlobalSpawnOffset=(X=0,Y=0,Z=8)
	Mesh=SkeletalMesh'MocaModelPak.skJackOLanternMesh'
	AmbientGlow=32
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
	bAlignBottomAlways=True
}