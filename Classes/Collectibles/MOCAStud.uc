class MOCAStud extends MOCACollectible;

enum StudType
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

var Texture Color10;
var Texture Color100;
var Texture Color1000;
var Texture Color10000;

var Texture SilverIcon;
var Texture BronzeIcon;
var Texture BlueIcon;
var Texture PurpleIcon;

var Sound SoundLow;
var Sound SoundMid;
var Sound SoundHi;

var StatusManager managerStatus;

var int RedoIndex;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	managerStatus = PlayerHarry.managerStatus;

	if ( SetStudValue() )
	{
		ResolveRedo();
		SetStudValue();
	}

	soundBounce = SetStudSound();

	Skin = GetTexture(nPickupIncrement);
}

event Touch (Actor Other)
{
	Super.Touch(Other);
	
	managerStatus.GetStatusItem(classStatusGroup,classStatusItem).textureHudIcon = Texture(DynamicLoadObject(string(GetStudIcon(nPickupIncrement)),Class'Texture'));
}

function ResolveRedo()
{
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
			RedoIndex = Rand(4);
			bRedo = True;
			break;
		case STUD_FullyRandom:
			nPickupIncrement = Rand(10001);
			nPickupIncrement = Clamp(nPickupIncrement,1,10000);
			break;
		case STUD_Custom:
			break;
	}

	return bRedo;
}

function Texture GetTexture(int Value)
{
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
