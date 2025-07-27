//================================================================================
// MOCAEssence. alternate bean essentially, but cooler :sunglasses:
//================================================================================

class MOCAEssence extends HProp;

var(JellyBeand) bool bFallsToGround;

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
    DrawType=DT_Sprite
    Texture=Texture'HPParticle.hp_fx.Particles.Sparkle_BW'
    bFallsToGround=False
    soundPickup=Sound'HPSounds.menu_sfx.gui_rollover2'
    bPickupOnTouch=True
    EventToSendOnPickup=JellyBeanPickupEvent
    PickupFlyTo=FT_HudPosition
    classStatusGroup=Class'MOCAStatusGroupEssence'
    classStatusItem=Class'MOCAStatusItemEssence'
    bBounceIntoPlace=True
    soundBounce=Sound'HPSounds.menu_sfx.gui_rollover3'
    Physics=PHYS_Walking
    bPersistent=True
    AmbientGlow=200
    CollisionRadius=16.00
    CollisionHeight=24.00
    bBlockActors=False
    bBlockPlayers=False
    bProjTarget=False
    bBlockCamera=False
    bBounce=True
    attachedParticleClass(0)=Class'MocaOmniPak.Essence_fx'
    bHidden=True
    AmbientSound=Sound'HPSounds.menu_sfx.sp_gui_amb_0001'
    SoundPitch=128
    SoundRadius=4
    SoundVolume=255
}