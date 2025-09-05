//================================================================================
// MOCAJellybean.
//================================================================================

class MOCACollectible extends HProp;


var() float RotationSpeed; // Moca: How fast should bean spin? (in degrees per second) Def: 160
var() Sound pickUpSound;    //Moca: What sound to play on pickup?
var() bool bFallsToGround; //Moca: Should bean fall to ground? Def: True
var() bool attractedToHarry; //Moca: Should bean move towards harry? Def: False
var() float attractionSpeed; //Moca: How fast should bean move towards harry? Def: 300.0
var() vector attractionOffset; //Moca: Position offset to be attacted to Def: (0,0,0)

var bool bInitialized;

var float CurrentYawF;
var float fPickupFlyTime;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    soundPickup = pickUpSound;
}

event Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other.IsA('Tut1Gnome') )
  {
    return;
  }
}

auto state BounceIntoPlace
{
    event BeginState()
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

    event Tick(float DeltaTime)
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
        
        if (attractedToHarry)
        {
            FlyToHarry(DeltaTime);
        }
    }
}

function FlyToHarry(float DeltaTime)
{
    local vector TargetLoc;
    local vector Dir;
    local vector DistanceFromHarry;

    SetPhysics(PHYS_Flying);

    // Make sure the player exists
    if (PlayerHarry != None)
    {
        // Get target position
        TargetLoc = PlayerHarry.Location + AttractionOffset;

        // Direction from this actor to the target
        Dir = Normal(TargetLoc - Location);

        // Move this actor toward the target
        SetLocation(Location + Dir * attractionSpeed * DeltaTime);
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
     attractionSpeed=300.0
     bCanFly=True
}