//================================================================================
// MOCACauldronCake.
//================================================================================
class MOCACauldronCake extends MOCACollectible;

defaultproperties
{
	PickUpSound=Sound'MocaOmniResources.Collectibles.pickup_cauldroncake'
	EventToSendOnPickup=CakePickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupCake'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemCake'
	Mesh=SkeletalMesh'MocaOmniResources.skCauldronCake'
	CollisionRadius=32
	CollisionHeight=10
	SoundVolMult=0.7
}
