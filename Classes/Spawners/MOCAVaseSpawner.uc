//================================================================================
// MOCAVaseSpawner.
//================================================================================

class MOCAVaseSpawner extends MOCAVisibleSpawner;

defaultproperties
{
	Physics=PHYS_None
	Mesh=SkeletalMesh'MocaModelPak.skVase'
	DrawScale=3.0
	PrePivot=(Z=-297)
	AmbientGlow=32
	CollisionRadius=8
	CollisionHeight=10
	CollideType=CT_OrientedCylinder
	bAlignBottomAlways=True
	SpawnerAnims=(Spawning=Jostle,EndSpawning=None,Idle=Idle,DoneIdle=BreakIdle,FinalSpawnEnd=Break)
	SpawnerSounds=(Opening=Sound'HPSounds.General.spawner_plant_pot',Ending=Sound'HPSounds.General.ss_Jar_Smash_0001')
}
