//================================================================================
// MOCACabinetSpawner.
//================================================================================

class MOCACabinetSpawner extends MOCAGenericSpawner;

defaultproperties
{
     GoodieToSpawn(0)=Class'HGame.Jellybean'
     GoodieToSpawn(1)=Class'HGame.Jellybean'
     GoodiesProbability(0)=32
     GoodiesProbability(1)=1
     Anims=(Spawning=Hit2,EndSpawning=Close2,Idle=IdleClosed,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
     Snds=(Opening=Sound'MocaSoundPak.Spawners.spawner_armoire',Closing=Sound'MocaSoundPak.Spawners.spawner_armoire_close01')
     GoodieDelay=0.5
     Lives=2
     ProbabilityBasedSpawns=True
     EndOnFinalSpawn=True
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
