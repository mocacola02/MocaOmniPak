//================================================================================
// MOCAJellybean.
//================================================================================

class MOCACollectible extends HProp;


var() float RotationSpeed; 		// Moca: How fast should bean spin? (in degrees per second) Def: 160
var() Sound pickUpSound;    	// Moca: What sound to play on pickup? Def: Sound'HPSounds.Magic_sfx.pickup11'
var() bool bFallsToGround; 		// Moca: Should bean fall to ground? Def: True
var() bool bAttractedToHarry; 	// Moca: Should bean move towards harry? Def: False
var() float attractionSpeed; 	// Moca: How fast should bean move towards harry? Def: 300.0
var() float attractionRange;	// Moca: How close does Harry have to be for attraction? Def: 128.0
var() vector attractionOffset; 	// Moca: Position offset to be attacted to Def: (0,0,0)
var() int IncrementAmount; // Moca: How many do you get from collecting this? Def: 1
var() float attractionDelay; // Moca: How long to wait until attraction begins? Useful if you want it to fall to the ground or bounce first.

var bool bInitialized;

var float CurrentYawF;
var float fPickupFlyTime;
var float currentDelayTime;

var bool bDefColActors;
var bool bDefBlockActors;
var bool bDefBlockPlayers;
var bool bDefCollideWorld;

event PreBeginPlay()
{
    Super.PreBeginPlay();
	nPickupIncrement = IncrementAmount;
    soundPickup = None;
}

event Touch (Actor Other)
{
  Super.Touch(Other);
  if ( Other.IsA('Tut1Gnome') )
  {
    return;
  }

  if (Other.IsA('harry'))
  {
	PlaySound(pickUpSound,,SoundVolMult);
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
        
        if (bAttractedToHarry && attractionDelay < currentDelayTime)
        {
            FlyToHarry(DeltaTime);
        }
		else if (bAttractedToHarry)
		{
			currentDelayTime += DeltaTime;
		}
    }
}

function FlyToHarry(float DeltaTime)
{
    local vector TargetLoc;
    local vector Dir;
    local float DistanceFromHarry;

	DistanceFromHarry = VSize(Location - PlayerHarry.Location);

    // Make sure the player exists
    if (PlayerHarry != None && DistanceFromHarry <= attractionRange)
    {
		if (Physics != PHYS_Flying)
		{
			SetPhysics(PHYS_Flying);
			SetCollision(true,false,false);
			bCollideWorld = False;
		}

        // Get target position
        TargetLoc = PlayerHarry.Location + AttractionOffset;

        // Direction from this actor to the target
        Dir = Normal(TargetLoc - Location);

        // Move this actor toward the target
        SetLocation(Location + Dir * attractionSpeed * DeltaTime);
    }
	else
	{
		if (Physics != PHYS_Falling)
		{
			Log("Harry out of range, going back to normal physics");
			SetPhysics(PHYS_Falling);
			SetCollision(bDefColActors,bDefBlockActors,bDefBlockPlayers);
			bCollideWorld = bDefCollideWorld;
		}
		
	}
}

defaultproperties
{
     bFallsToGround=True
     pickUpSound=Sound'HPSounds.Magic_sfx.pickup11'
	 soundPickup=Sound'HPSounds.Magic_sfx.pickup11'
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
     CollisionRadius=22
     CollisionHeight=12
     bBlockActors=False
     bBlockPlayers=False
     bProjTarget=False
     bBlockCamera=False
     bBounce=True
     RotationSpeed=160
     bAlignBottom=False
     attractionSpeed=300.0
     bCanFly=True
	 SoundVolMult=1.0
	 IncrementAmount=1.0
	 attractionRange=128.0
}