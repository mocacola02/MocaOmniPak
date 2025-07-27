//================================================================================
// MOCAVaseSpawner.
//================================================================================

class MOCAVaseSpawner extends MOCAGenericSpawner;

defaultproperties
{
     GoodieToSpawn(0)=Class'HGame.Jellybean'
     GoodieToSpawn(1)=Class'HGame.Jellybean'
     GoodiesProbability(0)=32
     GoodiesProbability(1)=1
     Anims=(Spawning=Jostle,EndSpawning=None,Idle=Idle,DoneIdle=BreakIdle,FinalSpawnEnd=Break)
     Snds=(Opening=Sound'HPSounds.General.spawner_jewel_box')
     StartPos=(Z=0)
     BaseDelay=0.75
     GoodieDelay=0.8
     Lives=2
     ProbabilityBasedSpawns=True
     EndOnFinalSpawn=True
     NoDelayForEndOnFinal=True
     Physics=PHYS_None
     Mesh=SkeletalMesh'MocaModelPak.skVase'
     DrawScale=1.3
     PrePivot=(Z=-128)
     AmbientGlow=32
     CollisionRadius=8
     CollisionHeight=10
     CollideType=CT_OrientedCylinder
     bAlignBottomAlways=True
}
