//================================================================================
// MOCAWaterGem.
//================================================================================
class MOCAWaterGem extends MOCACollectible;

defaultproperties
{
	PickUpSound=Sound'MocaOmniResources.Collectibles.pickup_water'
	soundPickup=Sound'MocaOmniResources.Collectibles.pickup_water'
	EventToSendOnPickup=WaterPickupEvent
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupWater'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemWater'
	Mesh=SkeletalMesh'MocaOmniResources.skWaterMedalMesh'
}
