//================================================================================
// DiscoveryPoint_fx.
//================================================================================

class DiscoveryPoint_accent extends ParticleFX;


defaultproperties
{
    ParticlesPerSec=(Base=1.00,Rand=2.00)

    SourceWidth=(Base=10.00,Rand=10.00)

    SourceHeight=(Base=10.00,Rand=10.00)

    SourceDepth=(Base=5.00,Rand=10.00)

    AngularSpreadWidth=(Base=180.00,Rand=0.00)

    AngularSpreadHeight=(Base=180.00,Rand=0.00)

    bSteadyState=True

    Speed=(Base=5.00,Rand=10.00)

    Lifetime=(Base=0.50,Rand=0.50)

    ColorStart=(Base=(R=255,G=255,B=255,A=0),Rand=(R=138,G=138,B=138,A=0))

    ColorEnd=(Base=(R=255,G=255,B=255,A=0),Rand=(R=127,G=127,B=127,A=0))

    SizeWidth=(Base=4.00,Rand=2.00)

    SizeLength=(Base=4.00,Rand=2.00)

    SpinRate=(Base=-6.00,Rand=2.00)

    AlphaDelay=0.0

    AlphaStart=(Base=0.2,Rand=0.3)

    Attraction=(X=5.00,Y=5.00,Z=5.00)

    Textures(0)=Texture'MocaTexturePak.Particles.TexDiscoveryPoint'

    Rotation=(Pitch=16640,Yaw=0,Roll=0)
}
