class SmokeShoot extends GrateSteam;

defaultproperties
{
     ParticlesPerSec=(Base=100)
     AngularSpreadWidth=(Rand=360)
     AngularSpreadHeight=(Rand=360)
     bSteadyState=False
     MinTimeBtwEmit=0
     MaxTimeBtwEmit=0
     MinEmitPeriod=0
     MaxEmitPeriod=0
     ColorStart=(Base=(R=20,G=20,B=5),Rand=(R=0,G=0,B=0))
     ColorEnd=(Base=(R=23,G=4,B=4))
     SizeWidth=(Base=4)
     SizeLength=(Base=4)
     SizeEndScale=(Rand=4)
     GravityModifier=-1
     ParticlesMax=200
}
