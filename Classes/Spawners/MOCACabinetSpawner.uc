//================================================================================
// MOCACabinetSpawner.
//================================================================================

class MOCACabinetSpawner extends MOCAVisibleSpawner;

defaultproperties
{
     spawnAnims=(Spawning=Hit2,EndSpawning=Close2,Idle=IdleClosed,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
     visibleSpawnSounds=(Opening=Sound'MocaSoundPak.Spawners.spawner_armoire',Closing=Sound'MocaSoundPak.Spawners.spawner_armoire_close01')
     Physics=PHYS_None
     Mesh=SkeletalMesh'MocaModelPak.skBeanDispenser'
     DrawScale=1.3
     AmbientGlow=32
     CollisionRadius=28
     CollisionWidth=50
     CollisionHeight=55
     CollideType=CT_Box
     bBlockPlayers=True
     bAlignBottomAlways=True
     bBlockCamera=True
}
