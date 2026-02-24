//================================================================================
// MOCADiscoveryPoint.
//================================================================================
class MOCADiscoveryPoint extends MOCACollectible;

var() Range HoverTime;		// Moca: Min and max value for HoverTime (will choose a random value between the two). Default: Min 2.5 Max 5.0
var() float CircleRadius;	// Moca: Radius size to circle around Harry. Def: 48.0
var() float CircleSpeed;	// Moca: Speed to circle around Harry at. Def: 400.0

var bool bFlyDone;		// Is fly done
var float CircleAngle;	// Current angle
var Vector CircleCenter;// Current circle center


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Vary our attraction speed
	AttractionSpeed += FRand() * 10.0;

	// Play point creation sound
	PlaySound(Sound'MocaSoundPak.Magic.SFX_DiscoveryPointStart',SLOT_None,,,1500);

	// If not attracted to Harry, collide with world so we don't fall out
	bCollideWorld = !bAttractedToHarry;
}

event FellOutOfWorld();	// Don't do anything if we fall out of world

event Touch(Actor Other)
{
	// If we touched Harry and we're not already circling him
	if ( Other == PlayerHarry && !IsInState('stateCircle') )
	{
		GotoState('stateCircle');
	}
}


///////////
// States
///////////

state stateCircle
{
	event Tick(float DeltaTime)
	{
		local Vector DesiredLocation;
		local Vector Direction;
		local Vector NewLocation;
		local float RadSpeed;

		// Get circle center
		CircleCenter = PlayerHarry.Location + AttractionOffset;

		// If not done flying
		if ( !bFlyDone )
		{
			// Get radius speed
			RadSpeed = CircleSpeed * Pi / 180.0;

			// Get angle to circle at
			CircleAngle += RadSpeed * DeltaTime;

			// If our angle is coming full circle, reset it
			if ( CircleAngle > 2.0 * Pi )
			{
				CircleAngle -= 2.0 * Pi;
			}

			// Set desired location, conforming to a circular movement
			DesiredLocation.X = CircleCenter.X + CircleRadius * Cos(CircleAngle);
			DesiredLocation.Y = CircleCenter.Y + CircleRadius * Sin(CircleAngle);
			DesiredLocation.Z = CircleCenter.Z;

			// Get final location
			NewLocation = Location + (DesiredLocation - Location) * FMin(DeltaTime * 5.0, 1.0);

			// Set location
			SetLocation(NewLocation);

			// Get direction
			Direction.X = -Sin(CircleAngle);
			Direction.Y = Cos(CircleAngle);
			Direction.Z = 0.0;
			// Rotate in that direction
			SetRotation(Rotator(Direction));
		}
		// Otherwise, if we're done
		else
		{
			local Vector TargetLocation;
			// Fly into Harry proper
			TargetLocation = PlayerHarry.Location;

			// Get direction to Harry and calculate our new location
			Direction = Normal(TargetLocation - Location);
			NewLocation = Location + Direction * AttractionSpeed * DeltaTime;

			// Set location and rotation
			SetLocation(NewLocation);
			SetRotation(Rotator(Direction));
		}
	}

	begin:
		// Delay for random hover time
		Sleep(RandRange(HoverTime.Min,HoverTime.Max));
		// After delay, tell us to finish flying
		bFlyDone = True;
		// Delay for a quarter of a second to allow some movement towards Harry
		Sleep(0.2);
		// Force Touch instructions from parent class
		Super.Touch(PlayerHarry);
}


defaultproperties
{
	AttractionOffset=(X=0.0,Y=0.0,Z=42.0)
	HoverTime=(Min=2.5,Max=5.0)
	AttractionRange=99999.0
	bAttractedToHarry=True
	AttractionSpeed=300.0
	CircleRadius=48.0
	CircleSpeed=400.0

	DrawType=DT_Sprite
	DrawScale=0.25
	Texture=Texture'MocaTexturePak.Particles.TexDiscoveryPoint'
	PickUpSound=Sound'MocaSoundPak.Magic.SFX_DiscoveryPointEnd'
	bPickupOnTouch=True
	EventToSendOnPickup=EssencePickupEvent
	PickupFlyTo=FT_HudPosition
	classStatusGroup=Class'MOCAStatusGroupDiscovery'
	classStatusItem=Class'MOCAStatusItemDiscovery'
	bBounceIntoPlace=False
	soundBounce=Sound'HPSounds.menu_sfx.gui_rollover3'
	Physics=PHYS_Flying
	bPersistent=True
	AmbientGlow=220
	CollisionRadius=16.00
	CollisionHeight=24.00
	bBlockActors=False
	bBlockPlayers=False
	bProjTarget=False
	bCollideWorld=False
	bBlockCamera=False
	bBounce=False
	attachedParticleClass(0)=Class'MocaOmniPak.DiscoveryPoint_accent'
	attachedParticleClass(1)=Class'MocaOmniPak.DiscoveryPoint_glow'
	AmbientSound=Sound'MocaSoundPak.Magic.SFX_DiscoveryPointFollowLoop'
	SoundPitch=128
	SoundRadius=64
	SoundVolume=255
	bSpriteRelativeScale=True
}