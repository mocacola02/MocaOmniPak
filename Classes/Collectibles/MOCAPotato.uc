//================================================================================
// MOCAPotato.
//================================================================================

class MOCAPotato extends MOCACollectible;

var() bool bFunnyMode; //Moca: Enable the funny :) def: False

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// if funni
	if ( bFunnyMode )
	{
		// play funni :)
		soundPickup = Sound'MocaSoundPak.Meme.Potato';
	}
}

defaultproperties
{
	PickUpSound=Sound'HPSounds.menu_sfx.ss_gui_rotatebut_0002'
	EventToSendOnPickup=PotatoPickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupPotato'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemPotato'
	soundBounce=Sound'HPSounds.FootSteps.HAR_foot_wood2'
	Mesh=SkeletalMesh'MocaModelPak.skPotato'
	CollisionRadius=32
	CollisionHeight=20
}