//================================================================================
// BundimunMist.
//================================================================================

class BundimunMist extends ParticleFX;

defaultproperties
{
    AlphaDelay=1.5
    ColorStart=(Base=(R=63,G=167,B=136,A=0),Rand=(R=0,G=0,B=0,A=0))
    ColorEnd=(Base=(R=63,G=167,B=136,A=0),Rand=(R=0,G=0,B=0,A=0))
    Textures(0)=Texture'HPParticle.hp_fx.Particles.Smoke3'
    SizeLength=(Base=16.00,Rand=0.00)
    SizeWidth=(Base=16.00,Rand=0.00)
    AngularSpreadHeight=(Base=0.00,Rand=0.00)
    AngularSpreadWidth=(Base=180.00,Rand=0.00)
    bSteadyState=true
    ParticlesMax=12
    ParticlesPerSec=(Base=32.00,Rand=0.00)
    SourceDepth=(Base=0.00,Rand=0.00)
    SourceHeight=(Base=0.00,Rand=0.00)
    SourceWidth=(Base=0.00,Rand=0.00)
    Damping=8.00
    Lifetime=(Base=3.00,Rand=0.00)
    Speed=(Base=64.00,Rand=128.00)
    bSystemRelative=true
    bVelocityRelative=true
    CollisionHeight=5
    CollisionRadius=10
}