//================================================================================
// MOCAJellybean.
//================================================================================

class MOCAPotato extends MOCACollectible;

var() bool bFunnyMode; //Moca: Enable the funny :) def: false

event PostBeginPlay()
{
    super.PostBeginPlay();
    if (bFunnyMode)
    {
        pickUpSound=Sound'MocaSoundPak.Meme.Potato';
        soundPickup = pickUpSound;
    }
}

defaultproperties
{
     pickUpSound=Sound'HPSounds.menu_sfx.ss_gui_rotatebut_0002'
     bPickupOnTouch=True
     EventToSendOnPickup=EarthPickupEvent
     PickupFlyTo=FT_HudPosition
     classStatusGroup=Class'MocaOmniPak.MOCAStatusGroupPotato'
     classStatusItem=Class'MocaOmniPak.MOCAStatusItemPotato'
     bBounceIntoPlace=True
     soundBounce=Sound'HPSounds.FootSteps.HAR_foot_wood2'
     Physics=PHYS_Walking
     bPersistent=True
     Mesh=SkeletalMesh'MocaModelPak.skPotato'
     AmbientGlow=200
     CollisionRadius=32
     CollisionHeight=20
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
     RotationSpeed=160
     bAlignBottom=False
     attractionSpeed=300.0
     bCanFly=True
}