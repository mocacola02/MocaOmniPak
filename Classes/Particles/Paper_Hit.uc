class Paper_Hit extends Diffindo_hit;

defaultproperties
{
	ColorStart=(Base=(R=255,G=255,B=255,A=0),Rand=(R=0,G=0,B=0,A=0))

	SpinRate=(Base=16,Rand=0)

	Textures(0)=Texture'MocaTexturePak.Particles.PaperScrap1'
	Textures(1)=Texture'MocaTexturePak.Particles.PaperScrap2'
	Textures(2)=Texture'MocaTexturePak.Particles.PaperScrap3'
	Textures(3)=Texture'MocaTexturePak.Particles.PaperScrap4'

	ParticlesMax=20
	ParticlesPerSec=(Base=200,Rand=0)

	SourceDepth=(Base=0,Rand=0)
	SourceHeight=(Base=0,Rand=0)
	SourceWidth=(Base=0,Rand=0)

	Attraction=(X=0,Y=0,Z=0)
	Chaos=3
	Gravity=(X=0,Y=0,Z=-64)
	Lifetime=(Base=0.2,Rand=0.5)
	Speed=(Base=50,Rand=100)
}
