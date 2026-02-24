//================================================================================
// MOCAPumpkinPasty.
//================================================================================
class MOCAPumpkinPasty extends MOCACollectible;

defaultproperties
{
	pickUpSound=Sound'MocaSoundPak.Magic.pastie_pickup'
	soundPickup=Sound'MocaSoundPak.Magic.pastie_pickup'
	EventToSendOnPickup=PastyPickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupPasty'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemPasty'
	Mesh=SkeletalMesh'MocaModelPak.skPumpkinPasty'
	CollisionRadius=32
	CollisionHeight=10
	SoundVolMult=0.7
}
