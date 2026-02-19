//================================================================================
// MOCADiscoveryPoint.
//================================================================================

class MOCADiscoveryPoint extends MOCACollectible;

var() float MinHoverTime;
var() float MaxHoverTime;
var() float CircleRadius;
var() float CircleSpeed;
var() float FlySpeed;

var bool bFlyDone;
var float CircleAngle;
var Vector CircleCenter;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	AttractionSpeed += FRand() * 10.0;

	PlaySound(Sound'MocaSoundPak.Magic.SFX_DiscoveryPointStart',SLOT_None,,,1500);

	bCollideWorld = !bAttractedToHarry;
}

event FellOutOfWorld();

event Touch(Actor Other)
{
	if ( Other.IsA('harry') && !IsInState('stateCircle') )
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

		CircleCenter = PlayerHarry.Location + AttractionOffset;

		if ( !bFlyDone )
		{
			RadSpeed = CircleSpeed * Pi / 180.0;

			CircleAngle += RadSpeed * DeltaTime;

			if ( CircleAngle > 2.0 * Pi )
			{
				CircleAngle -= 2.0 * Pi;
			}

			DesiredLocation.X = CircleCenter.X + CircleRadius * Cos(CircleAngle);
			DesiredLocation.Y = CircleCenter.Y + CircleRadius * Sin(CircleAngle);
			DesiredLocation.Z = CircleCenter.Z;

			NewLocation = Location + (DesiredLocation - Location) * FMin(DeltaTime * 5.0, 1.0);

			SetLocation(NewLocation);

			Direction.X = -Sin(CircleAngle);
			Direction.Y = Cos(CircleAngle);
			Direction.Z = 0.0;
			SetRotation(Rotator(Direction));
		}
		else
		{
			TargetPoint = PlayerHarry.Location;

			Direction = Normal(TargetPoint - Location);
			NewLocation = Location + Direction * FlySpeed * DeltaTime;

			SetLocation(NewLocation);
			SetRotation(Rotator(Direction));
		}
	}

	begin:
		Sleep(RandRange(MinHoverTime,MaxHoverTime));
		bFlyDone = True;
		Sleep(0.2);
		Super.Touch(PlayerHarry);
}


defaultproperties
{
	AttractionOffset=(X=0.0,Y=0.0,Z=42.0)
	MinHoverTime=2.5
	MaxHoverTime=5.0
	AttractionRange=99999.0
	bAttractedToHarry=True
	AttractionSpeed=300.0
	CircleRadius=48.0
	CircleSpeed=400.0
	FlySpeed=400.0

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