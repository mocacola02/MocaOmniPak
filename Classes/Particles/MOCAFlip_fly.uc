//================================================================================
// MOCAFlip_fly.
//================================================================================

class MOCAFlip_fly extends AllSpellCast_FX;

//texture package import -AdamJD
#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

defaultproperties
{
    ParticlesPerSec=(Base=150.00,Rand=0.00)

    SourceWidth=(Base=1.00,Rand=0.00)

    SourceHeight=(Base=1.00,Rand=0.00)

    AngularSpreadWidth=(Base=180.00,Rand=0.00)

    AngularSpreadHeight=(Base=180.00,Rand=0.00)

    bSteadyState=True

    Speed=(Base=75.00,Rand=0.00)

    ColorStart=(Base=(R=254,G=142,B=61,A=0),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=201,G=85,B=46,A=0),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=2.00,Rand=6.00)

    SizeLength=(Base=2.00,Rand=6.00)

    SizeEndScale=(Base=7.00,Rand=0.00)

    SpinRate=(Base=-3.00,Rand=16.00)

    AlphaGrowPeriod=0.10

    Attraction=(X=32.00,Y=32.00,Z=32.00)

    Damping=1.00

    Textures(0)=Texture'HPParticle.hp_fx.Particles.flare4'

    LastUpdateLocation=(X=132.00,Y=-348.00,Z=-44.50)

    LastEmitLocation=(X=132.00,Y=-348.00,Z=-44.50)

    LastUpdateRotation=(Pitch=16464,Yaw=0,Roll=0)

    EmissionResidue=0.04

    Age=1139.42

    ParticlesEmitted=53159

    bDynamicLight=True

    Tag=Dummyparticle

    Location=(X=132.00,Y=-348.00,Z=-44.50)

    OldLocation=(X=0.00,Y=0.00,Z=32.00)

    bSelected=True

    Chaos=16
}
