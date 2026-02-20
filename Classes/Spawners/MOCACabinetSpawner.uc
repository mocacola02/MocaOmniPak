//================================================================================
// MOCACabinetSpawner.
//================================================================================
class MOCACabinetSpawner extends MOCAVisibleSpawner;

defaultproperties
{
	SpawnerAnims=(Spawning=Hit2,EndSpawning=Close2,Idle=IdleClosed,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=Sound'MocaSoundPak.Spawners.spawner_armoire',Closing=Sound'MocaSoundPak.Spawners.spawner_armoire_close01')
	Mesh=SkeletalMesh'MocaModelPak.skBeanDispenser'
	DrawScale=1.3
	AmbientGlow=32
	CollisionRadius=28
	CollisionWidth=50
	CollisionHeight=55
	CollideType=CT_Box
	bAlignBottomAlways=True
}
