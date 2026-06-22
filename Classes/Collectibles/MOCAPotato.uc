//================================================================================
// MOCAPotato.
//================================================================================
class MOCAPotato extends MOCACollectible;

defaultproperties
{
	PickUpSound=Sound'HPSounds.menu_sfx.ss_gui_rotatebut_0002'
	EventToSendOnPickup=PotatoPickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupPotato'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemPotato'
	soundBounce=Sound'HPSounds.FootSteps.HAR_foot_wood2'
	Mesh=SkeletalMesh'MocaOmniResources.skPotato'
	CollisionRadius=32
	CollisionHeight=20
}