class MOCAFireGem extends MOCACollectible;

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'HPSounds.menu_sfx.Pop_up_in-game'
     soundPickup=Sound'HPSounds.menu_sfx.Pop_up_in-game'
     bPickupOnTouch=True
     EventToSendOnPickup=FirePickupEvent
     PickupFlyTo=FT_HudPosition
     classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupFire'
     classStatusItem=Class'MocaOmniPak.MOCAStatusItemFire'
     bBounceIntoPlace=True
     soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
     Physics=PHYS_Walking
     bPersistent=True
     Mesh=SkeletalMesh'MocaModelPak.skFireGem'
     AmbientGlow=200
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
}
