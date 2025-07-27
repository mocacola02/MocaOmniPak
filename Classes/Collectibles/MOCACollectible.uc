//================================================================================
// MOCAJellybean.
//================================================================================

class MOCACollectible extends HProp;

var float CurrentYawF; // Float version of yaw
var() float RotationSpeed; // Default: 160 | How fast should bean spin? (in degrees per second)
var() Sound pickUpSound;
var float fPickupFlyTime;
var() bool bFallsToGround;
var bool bInitialized;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    soundPickup = pickUpSound;
}

function Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other.IsA('Tut1Gnome') )
  {
    return;
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

    function Tick(float DeltaTime)
    {
        local Rotator NewRotation;

        Super.Tick(DeltaTime);

        CurrentYawF += RotationSpeed * DeltaTime;

        if (CurrentYawF >= 360.0)
            CurrentYawF -= 360.0;
        else if (CurrentYawF < 0.0)
            CurrentYawF += 360.0;

        NewRotation.Pitch = 0;
        NewRotation.Yaw = int(CurrentYawF * 65536.0 / 360.0) & 65535;
        NewRotation.Roll = 0;

        SetRotation(NewRotation);

        if (bBounceIntoPlaceTiming)
            fBounceIntoPlaceTimeout -= DeltaTime;
    }
}

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'HPSounds.Magic_sfx.pickup11'
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
     CollisionRadius=32
     CollisionHeight=20
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
     RotationSpeed=160
     bAlignBottom=False
}
