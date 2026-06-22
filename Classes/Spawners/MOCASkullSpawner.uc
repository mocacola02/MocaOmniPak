//================================================================================
// MOCASkullSpawner.
//================================================================================

class MOCASkullSpawner extends MOCAVisibleSpawner;

defaultproperties
{
	GlobalSpawnOffset=(X=0,Y=0,Z=8)
	SpawnerAnims=(Spawning=Hit1,EndSpawning=None,Idle=Idle,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
	SpawnerSounds=(Opening=Sound'MocaOmniResources.Spawners.skull_hit',Ending=Sound'MocaOmniResources.Spawners.skull_hit_end')
	Mesh=SkeletalMesh'MocaOmniResources.skCacklingSkull'
	DrawScale=1.3
	AmbientGlow=32
	CollisionRadius=21
	CollisionHeight=14
	CollideType=CT_OrientedCylinder
	bAlignBottomAlways=True
}
