//================================================================================
// MOCAJackOSpawner.
//================================================================================

class MOCAJackOSpawner extends MOCAVisibleSpawner;

defaultproperties
{
     spawnAnims=(Spawning=Scream,EndSpawning=None,Idle=Rest,DoneIdle=Rest,FinalSpawnEnd=Scream)
     visibleSpawnSounds=(Opening=Sound'MocaSoundPak.Spawners.skull_hit',Ending=Sound'MocaSoundPak.Spawners.skull_hitend')
     Physics=PHYS_None
     Mesh=SkeletalMesh'MocaModelPak.skJackOLanternMesh'
     DrawScale=1.0
     AmbientGlow=32
     CollisionRadius=21
     CollisionHeight=14
     CollideType=CT_OrientedCylinder
     bBlockPlayers=True
     bAlignBottomAlways=True
     bBlockCamera=True
}
