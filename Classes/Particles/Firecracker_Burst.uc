class Firecracker_Burst extends firecracker;

defaultproperties
{
     ColorEnd=(Base=(R=255,G=43,B=156,A=0),Rand=(R=240,G=43,B=156,A=0))
     ColorStart=(Base=(R=29,G=17,B=255,A=0),Rand=(R=255,G=23,B=23,A=0))

     RenderPrimitive=PPRIM_Shard

     ParticlesMax=200.0
     ParticlesPerSec=(Base=700.0,Rand=0.0)

     Elasticity=0.5
     Gravity=(X=0,Y=0,Z=-300)
     Speed=(Base=400.0,Rand=100.0)
}
