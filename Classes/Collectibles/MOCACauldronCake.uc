class MOCACauldronCake extends HProp;

var() Sound good;
var() Sound Bad;
var float fPickupFlyTime;
var() bool bFallsToGround;
var int iSkinTexture;
var bool bInitialized;

function Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other.IsA('Tut1Gnome') )
  {
    PlaySound(soundPickup);
    Destroy();
  }
}

auto state BounceIntoPlace
{
  function BeginState()
  {
    if ( bFallsToGround )
    {
      // SetPhysics(2);
	  SetPhysics(PHYS_Falling);
    } else {
      // SetPhysics(0);
	  SetPhysics(PHYS_None);
    }
  }
}

defaultproperties
{
     bFallsToGround=True
     soundPickup=Sound'HPSounds.Magic_sfx.pickup11'
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
