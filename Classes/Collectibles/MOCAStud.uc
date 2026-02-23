//================================================================================
// MOCAStud.
//================================================================================
class MOCAStud extends MOCACollectible;

enum StudType	// Types of studs
{
	STUD_10,
	STUD_100,
	STUD_1000,
	STUD_10000,
	STUD_RandomType,
	STUD_FullyRandom,
	STUD_Custom
};

var() StudType StudValue; // Moca: How much is the stud worth? RandomType chooses a random type from the numbered options. Fully random chooses a totally random value 1 - 10000. Custom uses the MOCACollectible increment value. Def: STUD_100

var int RedoIndex;		// Index to use when redoing our value check

var Texture Color10;	// Texture for Stud10
var Texture Color100;	// Texture for Stud100
var Texture Color1000;	// Texture for Stud1000
var Texture Color10000;	// Texture for Stud10000

var Texture SilverIcon;	// Icon texture of Stud10
var Texture BronzeIcon; // Icon texture of Stud100
var Texture BlueIcon;	// Icon texture of Stud1000
var Texture PurpleIcon;	// Icon texture of Stud <= 10000

var Sound SoundLow;		// Sound for low tier studs
var Sound SoundMid;		// Sound for mid tier studs
var Sound SoundHi;		// Sound for high tier studs

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Determine our stud value
	if ( SetStudValue() )
	{
		// If we used STUD_RandomType, check for our stud value again
		ResolveRedo();
		// Set the increment value again
		SetStudValue();
	}

	// Set our bounce sound based on stud tier
	soundBounce = SetStudSound();

	// Get texture based on value
	Skin = GetTexture(nPickupIncrement);
}

event Touch (Actor Other)
{
	Super.Touch(Other);
	
	// Set the icon to the correct stud color
	PlayerHarry.managerStatus.GetStatusItem(classStatusGroup,classStatusItem).textureHudIcon = Texture(DynamicLoadObject(string(GetStudIcon(nPickupIncrement)),Class'Texture'));
}

function ResolveRedo()
{
	// Match our RedoIndex to StudValue
	switch(RedoIndex)
	{
		case 0:
			StudValue = STUD_10;
			break;
		case 1:
			StudValue = STUD_100;
			break;
		case 2:
			StudValue = STUD_1000;
			break;
		case 3:
			StudValue = STUD_10000;
			break;
		default:
			StudValue = STUD_10;
			break;
	}
}

function Texture GetStudIcon(int Value)
{
	// Determine stud icon based on value
	if ( Value <= 10 )
	{
		return SilverIcon;
	}
	else if ( Value <= 100 )
	{
		return BronzeIcon;
	}
	else if ( Value <= 1000 )
	{
		return BlueIcon;
	}

	return PurpleIcon;
}

function bool SetStudValue()
{
	local bool bRedo;
	// Match stud value to our increment count
	switch(StudValue)
	{
		case STUD_10:
			nPickupIncrement = 10;
			break;
		case STUD_100:
			nPickupIncrement = 100;
			break;
		case STUD_1000:
			nPickupIncrement = 1000;
			break;
		case STUD_10000:
			nPickupIncrement = 10000;
			break;
		case STUD_RandomType:
			// If random, determine a random index for STUD-10 thru STUD_10000
			RedoIndex = Rand(4);
			// Set flag to redo assignment
			bRedo = True;
			break;
		case STUD_FullyRandom:
			// Get random value, but don't allow it to go higher than 10000 (subject to change?)
			nPickupIncrement = Rand(10001);
			nPickupIncrement = Clamp(nPickupIncrement,1,10000);
			break;
		case STUD_Custom:
			// If custom, don't assign anything
			break;
	}

	return bRedo;
}

function Texture GetTexture(int Value)
{
	// Get stud texture (color) based on value
	if ( Value <= 10 )
	{
		return Color10;
	}
	else if ( Value <= 100 )
	{
		return Color100;
	}
	else if ( Value <= 1000 )
	{
		return Color1000;
	}

	return Color10000;
}

function Sound SetStudSound()
{
	// Get stud pickup sound based on value
	if ( nPickupIncrement < 60 )
	{
		pickUpSound = SoundLow;
	}
	else if ( nPickupIncrement < 500 )
	{
		pickUpSound = SoundMid;
	}
	else
	{
		pickUpSound = SoundHi;
	}

	return pickUpSound;
}

defaultproperties
{
	pickUpSound=Sound'MocaSoundPak.Magic.LowStud'
	SoundLow=Sound'MocaSoundPak.Magic.LowStud'
	SoundMid=Sound'MocaSoundPak.Magic.MidStud'
	SoundHi=Sound'MocaSoundPak.Magic.HiStud'
	EventToSendOnPickup=StudPickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupStuds'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemStuds'
	soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
	bPersistent=True
	Mesh=SkeletalMesh'MocaModelPak.skLegoStud'
	AmbientGlow=16

	Color10=Texture'MocaTexturePak.Skins.LegoStud'
	Color100=Texture'MocaTexturePak.Skins.LegoStudBronze'
	Color1000=Texture'MocaTexturePak.Skins.LegoStudBlue'
	Color10000=Texture'MocaTexturePak.Skins.LegoStudPurple'

	SilverIcon=Texture'MocaTexturePak.SilverStud.SilverStudIcon_0'
	BronzeIcon=Texture'MocaTexturePak.BronzeStud.BronzeStudIcon_0'
	BlueIcon=Texture'MocaTexturePak.BlueStud.BlueStudIcon_0'
	PurpleIcon=Texture'MocaTexturePak.PurpleStud.PurpleStudIcon_0'

	fTotalFlyTime=0.5

	CollisionRadius=10
	CollisionHeight=10
}
