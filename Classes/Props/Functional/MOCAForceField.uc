class MOCAForceField extends HProp;

var() float AttractionRange;          // Maximum AttractionRange of effect
var() float Attraction;     // Positive = pull, Negative = push, 0 = no force

function Tick(float DeltaTime)
{
    local vector ToPlayer;
    local vector Dir;
    local float DistSquared;
    local float Strength;

    if (Attraction == 0)
        Destroy();
        return;

    // Vector from player to this actor
    ToPlayer = Location - PlayerHarry.Location;

    // Check squared distance first
    DistSquared = ToPlayer Dot ToPlayer; 

    if (DistSquared > AttractionRange * AttractionRange)
        return; // too far, skip all math

    Dir = Normal(ToPlayer);
    Strength = (1.0 - (Sqrt(DistSquared) / AttractionRange)) * Attraction;

    PlayerHarry.Velocity += Dir * Strength * DeltaTime;
}

defaultproperties
{
    AttractionRange=512.0
    Attraction=32.0
    bHidden=True
}
