class Paper_Fly extends Flip_wand;

defaultproperties
{
	ColorEnd=(Base=(R=112,G=112,B=112,A=0),Rand=(R=0,G=0,B=0,A=0))
	ColorStart=(Base=(R=112,G=112,B=112,A=0),Rand=(R=0,G=0,B=0,A=0))

	SizeLength=(Base=16,Rand=2)
	SizeWidth=(Base=16,Rand=2)

	Textures(0)=Texture'MocaTexturePak.Particles.PaperScrap1'
	Textures(1)=Texture'MocaTexturePak.Particles.PaperScrap2'
	Textures(2)=Texture'MocaTexturePak.Particles.PaperScrap3'
	Textures(3)=Texture'MocaTexturePak.Particles.PaperScrap4'

	ParticlesPerSec=(Base=16,Rand=0)

	SourceDepth=(Base=8,Rand=0)
	SourceHeight=(Base=8,Rand=0)
	SourceWidth=(Base=8,Rand=0)

	Attraction=(X=0,Y=0,Z=0)
	Chaos=3
	Damping=0
	Gravity=(X=0,Y=0,Z=-64)
	Lifetime=(Base=0.5,Rand=0)
	Speed=(Base=0,Rand=0)
}
