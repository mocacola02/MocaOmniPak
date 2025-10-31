//================================================================================
// MOCAJellybean.
//================================================================================

class MOCAJellybean extends MOCACollectible;

var int iSkinTexture;

function PreBeginPlay()
{
	Super.PreBeginPlay();
	if (  !bInitialized )
	{
		iSkinTexture = Rand(17);
		bInitialized = True;
	}
	switch (iSkinTexture)
	{
		case 0:
		Skin = Texture'skBeanBlueSpotTex0';
		break;
		case 1:
		Skin = Texture'skJellybeanTex0';
		break;
		case 2:
		Skin = Texture'skBeanBlackTex0';
		break;
		case 3:
		Skin = Texture'skBeanPurpleTex0';
		break;
		case 4:
		Skin = Texture'skBeanRedTex0';
		break;
		case 5:
		Skin = Texture'skBeanDarkGreenTex0';
		break;
		case 6:
		Skin = Texture'skBeanBogieTex0';
		break;
		case 7:
		Skin = Texture'skBlueJellyBeanTex0';
		break;
		case 8:
		Skin = Texture'skGreenJellyBeanTex0';
		break;
		case 9:
		Skin = Texture'skGreenPurpleCheckerBeanTex0';
		break;
		case 10:
		Skin = Texture'skSpottedJellyBeanTex0';
		break;
		case 11:
		Skin = Texture'skRedBlackStripeBeanTex0';
		break;
		case 12:
		Skin = Texture'skBeanBrownTex0';
		break;
		case 13:
		Skin = Texture'skBeanDkBlueTex0';
		break;
		case 14:
		Skin = Texture'skBeanMauveTex0';
		break;
		case 15:
		Skin = Texture'skBeanOrngeTex0';
		break;
		case 16:
		Skin = Texture'skBeanYellowyTex0';
		break;
		default:
	}
}

defaultproperties
{
	classStatusGroup=Class'HGame.StatusGroupJellybeans'
    classStatusItem=Class'HGame.StatusItemJellybeans'
	Mesh=SkeletalMesh'HProps.skJellybeanMesh'
}