//================================================================================
// MOCASkullSpawner.
//================================================================================

class MOCASkullSpawner extends MOCAVisibleSpawner;

defaultproperties
{
     spawnAnims=(Spawning=Hit1,EndSpawning=None,Idle=Idle,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
     visibleSpawnSounds=(Opening=Sound'MocaSoundPak.Spawners.skull_hit',Ending=Sound'MocaSoundPak.Spawners.skull_hitend')
     Physics=PHYS_None
     Mesh=SkeletalMesh'MocaModelPak.skCacklingSkull'
     DrawScale=1.3
     AmbientGlow=32
     CollisionRadius=21
     CollisionHeight=14
     CollideType=CT_OrientedCylinder
     bBlockPlayers=True
     bAlignBottomAlways=True
     bBlockCamera=True
}
