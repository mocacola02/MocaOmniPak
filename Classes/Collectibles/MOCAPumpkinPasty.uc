class MOCAPumpkinPasty extends MOCACollectible;

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'MocaSoundPak.Magic.pastie_pickup'
     soundPickup=Sound'MocaSoundPak.Magic.pastie_pickup'
     bPickupOnTouch=True
     EventToSendOnPickup=PastyPickupEvent
     PickupFlyTo=FT_HudPosition
     classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupPasty'
     classStatusItem=Class'MocaOmniPak.MOCAStatusItemPasty'
     bBounceIntoPlace=True
     soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
     Physics=PHYS_Walking
     bPersistent=True
     Mesh=SkeletalMesh'MocaModelPak.skPumpkinPasty'
     AmbientGlow=200
     CollisionRadius=32
     CollisionHeight=10
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
}
