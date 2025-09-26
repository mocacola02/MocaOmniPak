class ShieldCollect extends Fireworks1;

defaultproperties
{
	ColorEnd=(Base=(R=255,G=147,B=0,A=0),Rand=(R=155,G=137,B=100,A=0))
	ColorStart=(Base=(R=255,G=100,B=6,A=0),Rand=(R=190,G=97,B=97,A=0))

	RenderPrimitive=PPRIM_Liquid

	SizeEndScale=(Base=0,Rand=0)
	SizeLength=(Base=4,Rand=0)
	SizeWidth=(Base=4,Rand=0)
	SpinRate=(Base=0,Rand=0)

	Textures(0)=Texture'HPParticle.hp_fx.Particles.Les_Sparkle_04'
	Textures(1)=Texture'MocaTexturePak.Particles.TexDiscoveryPoint'

	ParticlesMax=360

	Damping=0

	Speed=(Base=64,Rand=0)
}
