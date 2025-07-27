class SmokePuff extends GrateSteam;

defaultproperties
{
     ParticlesPerSec=(Base=400)
     SourceWidth=(Base=36)
     SourceHeight=(Base=36)
     AngularSpreadWidth=(Rand=360)
     AngularSpreadHeight=(Rand=360)
     bSteadyState=False
     MinTimeBtwEmit=0
     MaxTimeBtwEmit=0
     MinEmitPeriod=0
     MaxEmitPeriod=0
     Speed=(Base=64)
     ColorStart=(Base=(R=20,G=20,B=5),Rand=(R=0,G=0,B=0))
     ColorEnd=(Base=(R=23,G=4,B=4))
     SizeWidth=(Base=4)
     SizeLength=(Base=4)
     SizeEndScale=(Rand=4)
     Chaos=6
     Attraction=(X=0,Y=0,Z=0)
     Damping=0
     GravityModifier=0
     ParticlesMax=200
}
