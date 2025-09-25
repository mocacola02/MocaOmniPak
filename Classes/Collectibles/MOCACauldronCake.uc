class MOCACauldronCake extends MOCACollectible;

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'MocaSoundPak.Magic.pickup_cauldroncake'
     soundPickup=Sound'MocaSoundPak.Magic.pickup_cauldroncake'
     bPickupOnTouch=True
     EventToSendOnPickup=CakePickupEvent
     PickupFlyTo=FT_HudPosition
     classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupCake'
     classStatusItem=Class'MocaOmniPak.MOCAStatusItemCake'
     bBounceIntoPlace=True
     soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
     Physics=PHYS_Walking
     bPersistent=True
     Mesh=SkeletalMesh'MocaModelPak.skCauldronCake'
     AmbientGlow=200
     CollisionRadius=32
     CollisionHeight=10
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
	 SoundVolMult=0.7
}
