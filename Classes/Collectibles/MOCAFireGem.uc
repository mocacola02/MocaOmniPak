//================================================================================
// MOCAFireGem.
//================================================================================
class MOCAFireGem extends MOCACollectible;

defaultproperties
{
	pickUpSound=Sound'HPSounds.menu_sfx.Pop_up_in-game'
	soundPickup=Sound'HPSounds.menu_sfx.Pop_up_in-game'
	EventToSendOnPickup=FirePickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupFire'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemFire'
	Mesh=SkeletalMesh'MocaModelPak.skFireMedalMesh'
}
