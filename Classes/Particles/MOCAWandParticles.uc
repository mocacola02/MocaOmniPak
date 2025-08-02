//================================================================================
// MOCAWandParticles.
//================================================================================

class MOCAWandParticles extends AllSpellCast_FX;

//texture package import -AdamJD
#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

defaultproperties
{
    bEmit=false

    ParticlesPerSec=(Base=100.00,Rand=10.00)

    SourceWidth=(Base=2.00,Rand=0.00)

    SourceHeight=(Base=2.00,Rand=0.00)

    AngularSpreadWidth=(Base=10.00,Rand=0.00)

    AngularSpreadHeight=(Base=10.00,Rand=0.00)

    Speed=(Base=30.00,Rand=15.00)

    Lifetime=(Base=3.00,Rand=0.00)

    ColorStart=(Base=(R=255,G=255,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=255,G=255,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=16.00,Rand=3.00)

    SizeLength=(Base=16.00,Rand=3.00)

    SizeEndScale=(Base=-1.00,Rand=0.00)

    SpinRate=(Base=5.00,Rand=10.00)

    Chaos=3.00

    GravityModifier=0.05

    Textures(0)=Texture'HPParticle.hp_fx.Particles.flare4'

    Rotation=(Pitch=16640,Yaw=0,Roll=0)
}
