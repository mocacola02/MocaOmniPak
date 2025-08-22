//================================================================================
// MOCABannerSpwnr.
//================================================================================

class MOCABannerSpawner extends MOCAVisibleSpawner;

defaultproperties
{
     spawnAnims=(Spawning=HitRight,EndSpawning=None,Idle=InsideIdle,DoneIdle=HitEndIdle,FinalSpawnEnd=HitEnd)
     visibleSpawnSounds=(Opening=MultiSound'MocaSoundPak.Spawners.multi_banner_hit',Ending=MultiSound'MocaSoundPak.Spawners.multi_rollup_sound')
     Physics=PHYS_None
     Mesh=SkeletalMesh'MocaModelPak.skBanner'
     AmbientGlow=32
     CollisionRadius=8
     CollisionWidth=50
     CollisionHeight=95
     CollideType=CT_Box
}
