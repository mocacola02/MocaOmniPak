//================================================================================
// MOCAJellybean.
//================================================================================

class MOCAJellybean extends Jellybean;

var float CurrentYawF; // Float version of yaw
var() float RotationSpeed; // Default: 160 | How fast should bean spin? (in degrees per second)

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
     RotationSpeed=160
}
