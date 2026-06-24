//================================================================================
// MOCAJellybean.
//
// Custom Jellybean class that has the benefits of MOCACollectibles
// and allows you to set an array of available bean textures.
//================================================================================
class MOCAJellybean extends MOCACollectible;

//=General Variables==/
var() array<Texture> BeanTextures;	// Array of bean textures to use


//=========
// Events
//=========

event PostBeginPlay()
{
	Super.PostBeginPlay();
	Skin = BeanTextures[ Rand(BeanTextures.Length) ];
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	BeanTextures(0)=Texture'skBeanBlueSpotTex0'
	BeanTextures(1)=Texture'skJellybeanTex0'
	BeanTextures(2)=Texture'skBeanBlackTex0'
	BeanTextures(3)=Texture'skBeanPurpleTex0'
	BeanTextures(4)=Texture'skBeanRedTex0'
	BeanTextures(5)=Texture'skBeanDarkGreenTex0'
	BeanTextures(6)=Texture'skBeanBogieTex0'
	BeanTextures(7)=Texture'skBlueJellyBeanTex0'
	BeanTextures(8)=Texture'skGreenJellyBeanTex0'
	BeanTextures(9)=Texture'skGreenPurpleCheckerBeanTex0'
	BeanTextures(10)=Texture'skSpottedJellyBeanTex0'
	BeanTextures(11)=Texture'skRedBlackStripeBeanTex0'
	BeanTextures(12)=Texture'skBeanBrownTex0'
	BeanTextures(13)=Texture'skBeanDkBlueTex0'
	BeanTextures(14)=Texture'skBeanMauveTex0'
	BeanTextures(15)=Texture'skBeanOrngeTex0'
	BeanTextures(16)=Texture'skBeanYellowyTex0'
	classStatusGroup=Class'HGame.StatusGroupJellybeans'
	classStatusItem=Class'HGame.StatusItemJellybeans'
	Mesh=SkeletalMesh'HProps.skJellybeanMesh'
}