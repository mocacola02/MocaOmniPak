//================================================================================
// MOCASkullSpawner.
//================================================================================

class MOCASkullSpawner extends MOCAGenericSpawner;

defaultproperties
{
     GoodieToSpawn(0)=Class'HGame.Jellybean'
     GoodieToSpawn(1)=Class'HGame.Jellybean'
     GoodiesProbability(0)=32
     GoodiesProbability(1)=1
     Anims=(Spawning=Hit1,EndSpawning=None,Idle=Idle,DoneIdle=IdleEnd,FinalSpawnEnd=HitEnd)
     Snds=(Opening=Sound'MocaSoundPak.Spawners.skull_hit',Ending=Sound'MocaSoundPak.Spawners.skull_hitend')
     BaseDelay=0.15
     GoodieDelay=0.5
     Lives=2
     ProbabilityBasedSpawns=True
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
