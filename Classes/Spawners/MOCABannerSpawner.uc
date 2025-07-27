//================================================================================
// MOCABannerSpwnr.
//================================================================================

class MOCABannerSpawner extends MOCAGenericSpawner;

defaultproperties
{
     GoodieToSpawn(0)=Class'HGame.Jellybean'
     GoodieToSpawn(1)=Class'HGame.Jellybean'
     GoodiesProbability(0)=32
     GoodiesProbability(1)=1
     Anims=(Spawning=HitRight,EndSpawning=None,Idle=InsideIdle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
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
     Mesh=SkeletalMesh'MocaModelPak.skBanner'
     AmbientGlow=32
     CollisionRadius=8
     CollisionWidth=50
     CollisionHeight=95
     CollideType=CT_Box
}
