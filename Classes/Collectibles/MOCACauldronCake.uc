//================================================================================
// MOCACauldronCake.
//================================================================================
class MOCACauldronCake extends MOCACollectible;

defaultproperties
{
	PickUpSound=Sound'MocaSoundPak.Magic.pickup_cauldroncake'
	EventToSendOnPickup=CakePickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupCake'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemCake'
	Mesh=SkeletalMesh'MocaModelPak.skCauldronCake'
	CollisionRadius=32
	CollisionHeight=10
	SoundVolMult=0.7
}
