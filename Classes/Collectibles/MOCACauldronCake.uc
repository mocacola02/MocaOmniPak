class MOCACauldronCake extends MOCACollectible;

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'MocaSoundPak.Magic.pastie_pickup'
     soundPickup=Sound'MocaSoundPak.Magic.pastie_pickup'
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
}
