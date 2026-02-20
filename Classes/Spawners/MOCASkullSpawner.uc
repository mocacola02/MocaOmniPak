//================================================================================
// MOCASkullSpawner.
//================================================================================

class MOCASkullSpawner extends MOCAVisibleSpawner;

defaultproperties
{
	SpawnerAnims=(Spawning=Hit1,EndSpawning=None,Idle=Idle,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=Sound'MocaSoundPak.Spawners.skull_hit',Ending=Sound'MocaSoundPak.Spawners.skull_hitend')
	Mesh=SkeletalMesh'MocaModelPak.skCacklingSkull'
	DrawScale=1.3
	AmbientGlow=32
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
	bAlignBottomAlways=True
}
