class MOCAEarthGem extends MOCACollectible;

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'HPSounds.menu_sfx.ss_gui_rotatebut_0002'
     soundPickup=Sound'HPSounds.menu_sfx.ss_gui_rotatebut_0002'
     bPickupOnTouch=True
     EventToSendOnPickup=EarthPickupEvent
     PickupFlyTo=FT_HudPosition
     classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupEarth'
     classStatusItem=Class'MocaOmniPak.MOCAStatusItemEarth'
     bBounceIntoPlace=True
     soundBounce=Sound'HPSounds.Magic_sfx.bean_bounce'
     Physics=PHYS_Walking
     bPersistent=True
     Mesh=SkeletalMesh'MocaModelPak.skEarthGem'
     AmbientGlow=200
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
}
