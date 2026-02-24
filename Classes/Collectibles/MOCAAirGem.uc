//================================================================================
// MOCAAirGem
//================================================================================
class MOCAAirGem extends MOCACollectible;

defaultproperties
{
	bFallsToGround=True
	PickUpSound=Sound'HPSounds.menu_sfx.s_menu_click'
	bPickupOnTouch=True
	EventToSendOnPickup=AirPickupEvent
	PickupFlyTo=FT_HudPosition
	classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupAir'
	classStatusItem=Class'MocaOmniPak.MOCAStatusItemAir'
	bBounceIntoPlace=True
	soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
	Physics=PHYS_Walking
	bPersistent=True
	Mesh=SkeletalMesh'MocaModelPak.skAirMedalMesh'
	AmbientGlow=200
	bBlockActors=False
	bBlockPlayers=False
	bProjTarget=False
	bBlockCamera=False
	bBounce=True
}
