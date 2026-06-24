//================================================================================
// MOCAPumpkinPasty.
//================================================================================
class MOCAPumpkinPasty extends MOCACollectible;

defaultproperties
{
	pickUpSound=Sound'MocaOmniResources.Collectibles.pickup_pastie'
	soundPickup=Sound'MocaOmniResources.Collectibles.pickup_pastie'
	EventToSendOnPickup=PastyPickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupPasty'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemPasty'
	Mesh=SkeletalMesh'MocaOmniResources.skPumpkinPasty'
	CollisionRadius=32
	CollisionHeight=10
	SoundVolMult=0.7
}
