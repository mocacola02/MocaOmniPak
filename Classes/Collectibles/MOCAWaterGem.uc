class MOCAWaterGem extends MOCACollectible;

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'MocaSoundPak.Magic.ps1_jingle1'
     soundPickup=Sound'MocaSoundPak.Magic.ps1_jingle1'
     bPickupOnTouch=True
     EventToSendOnPickup=WaterPickupEvent
     PickupFlyTo=FT_HudPosition
     classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupWater'
     classStatusItem=Class'MocaOmniPak.MOCAStatusItemWater'
     bBounceIntoPlace=True
     soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
     Physics=PHYS_Walking
     bPersistent=True
     Mesh=SkeletalMesh'MocaModelPak.skWaterGem'
     AmbientGlow=200
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
}
