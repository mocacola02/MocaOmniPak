class MOCAPhysicsProp extends MOCAExperimentalProps;

var rotator AngularVelocity;
var bool bOnGround;

var float TimeSinceLastBump;       // Timer to track time since the last bump
var float Gravity;
var float BumpCooldownTime;        // Time in seconds before allowing a new log after a bump

const VELOCITY_STOP_THRESHOLD = 2.0;
const ANGULAR_STOP_THRESHOLD = 5;

event PreBeginPlay()
{
    Super.PreBeginPlay();
    SetPhysics(PHYS_None); // Manual physics
}

event HitWall (Vector HitNormal, Actor Wall)
{
    // Keeping this function empty, as per your request
}

event Tick(float DeltaTime)
{
    // Apply gravity
    Velocity.Z += Gravity * DeltaTime;

    // Apply friction
    local float Friction;
    Friction = 0.85;

    Velocity.X *= Friction;
    Velocity.Y *= Friction;

    if (Abs(Velocity.X) < VELOCITY_STOP_THRESHOLD)
        Velocity.X = 0;
    if (Abs(Velocity.Y) < VELOCITY_STOP_THRESHOLD)
        Velocity.Y = 0;

    // Apply angular friction (less aggressive to allow more rotation)
    AngularVelocity.Pitch *= 0.5;  // Less friction for pitch
    AngularVelocity.Yaw   *= 0.5;  // Less friction for yaw
    AngularVelocity.Roll  *= 0.5;  // Less friction for roll

    if (Abs(AngularVelocity.Pitch) < ANGULAR_STOP_THRESHOLD &&
        Abs(AngularVelocity.Yaw) < ANGULAR_STOP_THRESHOLD &&
        Abs(AngularVelocity.Roll) < ANGULAR_STOP_THRESHOLD)
    {
        AngularVelocity = rot(0, 0, 0);  // Stop rotating completely if below threshold
    }

    // Prevent tilting when on the ground
    if (bOnGround)
    {
        AngularVelocity.Pitch = 0;   // Stop pitch (up/down rotation)
        AngularVelocity.Roll  = 0;   // Stop roll (side-to-side rotation)
    }

    // Move the actor
    MoveSmooth(Velocity * DeltaTime);

    // Update the rotation based on both falling and bump direction
    local rotator newRotation;
    newRotation = Rotation;  // Copy the current rotation

    // Update yaw with AngularVelocity and apply rotation based on bump
    newRotation.Yaw += AngularVelocity.Yaw * DeltaTime;  // Update yaw with AngularVelocity

    // Apply the new rotation to the actor
    SetRotation(newRotation);  // Apply the new rotation

    // Log the rotation for debugging
    Log("Current Rotation: " $ Rotation);
    Log("AngularVelocity.Yaw: " $ AngularVelocity.Yaw);

    // Update the time since the last bump
    TimeSinceLastBump += DeltaTime;
}

event Bump(Actor Other)
{
    if (Other == None || Mass <= 0)
        return;

    // Prevent log spam by allowing logging only after a cooldown period
    if (TimeSinceLastBump > BumpCooldownTime)
    {
        Log("Bumped! Velocity: " $ Velocity);
        Log("Bumped! AngularVelocity.Yaw: " $ AngularVelocity.Yaw);
        Log("Push Direction: " $ Normal(Location - Other.Location));

        TimeSinceLastBump = 0;  // Reset the timer after a bump log
    }

    // Apply a push
    local vector PushDir;
    PushDir = Normal(Location - Other.Location);
    Velocity += PushDir * 100;  // Decent push
    Velocity.Z = 50;            // Little bounce

	// Calculate the direction of the bump (relative to the object's forward axis)
	local rotator HitRotation;
	HitRotation = Rotation;  // Current rotation of the object

	local vector HitDirection;
	HitDirection = Normal(Location - Other.Location); // Direction of bump

	// Manually calculate the forward vector based on the rotation's yaw
	local vector ForwardVector;
	ForwardVector.X = -sin(HitRotation.Yaw * 3.14159 / 180);  // Sin of yaw for forward direction
	ForwardVector.Y = cos(HitRotation.Yaw * 3.14159 / 180);   // Cos of yaw for forward direction
	ForwardVector.Z = 0;  // No vertical component, purely horizontal

	// Manually calculate the size (magnitude) of the HitDirection vector
	local float HitDirectionSize;
	HitDirectionSize = sqrt(HitDirection.X * HitDirection.X + HitDirection.Y * HitDirection.Y + HitDirection.Z * HitDirection.Z); 

	// Scale the forward vector by the size of the bump direction
	local vector LocalHitDirection;
	LocalHitDirection = ForwardVector * HitDirectionSize; // Scale forward vector

	// Use the LocalHitDirection to determine how much to rotate the object
	local float DotX;
	DotX = LocalHitDirection.X * ForwardVector.X + LocalHitDirection.Y * ForwardVector.Y; // Dot product with the forward vector (X axis)

	// Apply angular velocity based on bump direction
	AngularVelocity.Yaw += DotX * 500;  // Adjust multiplier as necessary for rotation speed

    // Calculate rotation to align to the bump direction more naturally
    if (!bOnGround)
    {
        // Add some angular velocity for falling rotation
        AngularVelocity.Yaw += (Velocity.X + Velocity.Y) * 0.1;
    }

    bOnGround = false;  // Set the actor to be "off the ground"
}

defaultproperties
{
     Gravity=-980
     BumpCooldownTime=1
     bAlwaysTick=True
     Mass=1
}
