//================================================================================
// MOCATapestrySpawner.
//================================================================================

class MOCATapestrySpawner extends MOCAGenericSpawner;

defaultproperties
{
     GoodieToSpawn(0)=Class'HGame.Jellybean'
     GoodieToSpawn(1)=Class'HGame.Jellybean'
     GoodiesProbability(0)=32
     GoodiesProbability(1)=1
     Anims=(Spawning=Hit,EndSpawning=None,Idle=Idle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
     Lives=3
     ProbabilityBasedSpawns=True
     HitSounds(0)=Sound'MocaSoundPak.Spawners.banner_hit01'
     HitSounds(1)=Sound'MocaSoundPak.Spawners.banner_hit02'
     HitSounds(2)=Sound'MocaSoundPak.Spawners.banner_hit03'
     CloseSounds(0)=Sound'MocaSoundPak.Spawners.banner_rollup01'
     CloseSounds(1)=Sound'MocaSoundPak.Spawners.banner_rollup02'
     CloseSounds(2)=Sound'MocaSoundPak.Spawners.banner_rollup03'
     randomHitSounds=True
     Physics=PHYS_None
     Mesh=SkeletalMesh'MocaModelPak.skHP3Tapestry'
     DrawScale=1.3
     PrePivot=(Z=-80)
     AmbientGlow=32
     CollisionRadius=8
     CollisionWidth=50
     CollisionHeight=80
     CollideType=CT_Box
}
