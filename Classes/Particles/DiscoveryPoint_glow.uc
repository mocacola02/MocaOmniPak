//================================================================================
// DiscoveryPoint_fx.
//================================================================================

class DiscoveryPoint_glow extends ParticleFX;


defaultproperties
{
    SourceWidth=(Base=0.00,Rand=0.00)

    SourceHeight=(Base=0.00,Rand=0.00)

    bSteadyState=True

    Speed=(Base=0.00,Rand=0.00)

    ColorStart=(Base=(R=118,G=150,B=199,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=88,G=167,B=205,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=36.00,Rand=0.00)

    SizeLength=(Base=36.00,Rand=0.00)

    SpinRate=(Base=0.50,Rand=0.00)

    bSystemRelative=True

    AlphaStart=(Base=0.05,Rand=0.0)

    Textures(0)=Texture'HPParticle.hp_fx.Particles.flare4'
}