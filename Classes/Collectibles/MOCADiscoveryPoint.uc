//================================================================================
// MOCADiscoveryPoint.
//================================================================================

class MOCADiscoveryPoint extends MOCACollectible;

var() float minHoverTime;   // Moca: Minimum amount of time to circle above harry. Def: 2.5
var() float maxHoverTime;   // Moca: Maximum amount of time to circle above harry. Def: 5.0

var vector CircleCenter;     // The point to circle around
var vector TargetPoint;      // The point to fly to after done
var() float CircleRadius;      // Moca: Distance to keep from Harry's center while circling Harry. Def: 48.0
var() float CircleSpeed;       // Moca: Angular speed in radians/sec while circling. Def: 400.0
var() float FlySpeed;          // Moca: Speed when flying to target. Def: 400.0
var bool bFlyDone;            // Switch between orbiting and flying

var float CircleAngle;       // Keeps track of the orbit angle

event PostBeginPlay()
{
    super.PostBeginPlay();
    attractionSpeed += (FRand() * 10.0);
    PlaySound(Sound'MocaSoundPak.Magic.SFX_DiscoveryPointStart',SLOT_None,,,1500);

    if (!bAttractedToHarry)
    {
        bCollideWorld = True;
        SetPhysics(PHYS_Walking);
    }
}

event FellOutOfWorld()
{
}

event Touch (Actor Other)
{
    if (Other.IsA('harry') && !IsInState('stateCircle'))
    {
        GotoState('stateCircle');
    }  
}


state stateCircle
{
    event Tick(float DeltaTime)
    {
        local vector DesiredLocation;
        local vector Direction;
        local vector NewLocation;
        local float RadSpeed;

        CircleCenter = PlayerHarry.Location + attractionOffset;

        if (!bFlyDone)
        {
            // Convert degrees/sec to radians/sec
            RadSpeed = CircleSpeed * Pi / 180.0;

            // Update orbit angle
            CircleAngle += RadSpeed * DeltaTime;

            // Keep it from getting huge
            if (CircleAngle > 2 * Pi)
                CircleAngle -= 2 * Pi;

            // Compute orbit location
            DesiredLocation.X = CircleCenter.X + CircleRadius * Cos(CircleAngle);
            DesiredLocation.Y = CircleCenter.Y + CircleRadius * Sin(CircleAngle);
            DesiredLocation.Z = CircleCenter.Z;

            // Interpolate manually toward desired location
            NewLocation = Location + (DesiredLocation - Location) * FMin(DeltaTime * 5.0, 1.0);

            SetLocation(NewLocation);

            // Face tangent of circle
            Direction.X = -Sin(CircleAngle);
            Direction.Y =  Cos(CircleAngle);
            Direction.Z =  0;
            SetRotation(Rotator(Direction));
        }
        else
        {
            TargetPoint = PlayerHarry.Location;

            // Fly straight to target
            Direction = Normal(TargetPoint - Location);
            NewLocation = Location + Direction * FlySpeed * DeltaTime;

            SetLocation(NewLocation);

            // Instantly face flight direction
            SetRotation(Rotator(Direction));
        }
    }


    begin:
        Log("Circling harry!");
        sleep(FClamp(FRand() * maxHoverTime, minHoverTime, maxHoverTime));
        bFlyDone = true;
        sleep(0.2);
        Super.Touch(PlayerHarry);
}

defaultproperties
{
    attractionOffset=(X=0.0,Y=0.0,Z=42.0)
    DrawType=DT_Sprite
    DrawScale=0.25
    Texture=Texture'MocaTexturePak.Particles.TexDiscoveryPoint'
    pickUpSound=Sound'MocaSoundPak.Magic.SFX_DiscoveryPointEnd'
    bPickupOnTouch=True
    EventToSendOnPickup=EssencePickupEvent
    PickupFlyTo=FT_HudPosition
    classStatusGroup=Class'MOCAStatusGroupDiscovery'
    classStatusItem=Class'MOCAStatusItemDiscovery'
    bBounceIntoPlace=True
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
    bBounce=True
    attachedParticleClass(0)=Class'MocaOmniPak.DiscoveryPoint_accent'
    attachedParticleClass(1)=Class'MocaOmniPak.DiscoveryPoint_glow'
    bHidden=False
    AmbientSound=Sound'MocaSoundPak.Magic.SFX_DiscoveryPointFollowLoop'
    SoundPitch=128
    SoundRadius=64
    SoundVolume=255
    bAttractedToHarry=True
    attractionSpeed=300.0
    CircleRadius=48.0
    CircleSpeed=400.0
    FlySpeed=400.0
    bSpriteRelativeScale=true
    minHoverTime=2.5
    maxHoverTime=5.0
}