class MOCAForceField extends HProp;

var() float AttractionRange;    // Moca: Maximum AttractionRange of effect
var() float Attraction;     	// Moca: Positive = pull, Negative = push, 0 = no force
var vector lastHarryPos;

auto state stateDormant
{
    begin:
        if (isHarryNear(AttractionRange))
        {
            GotoState('statePull');
        }
        sleep(0.25);
        goto('begin');
}

state statePull
{
    event Tick(float DeltaTime)
    {
        if (!isHarryNear(AttractionRange))
        {
            GotoState('stateDormant');
        }

        local vector ToPlayer;
        local vector Dir;
        local float DistSquared;
        local float Strength;
        local vector FinalVelocity;

        Super.Tick(DeltaTime);

        // Vector from player to this actor
        ToPlayer = Location - PlayerHarry.Location;

        // Check squared distance first
        DistSquared = ToPlayer Dot ToPlayer; 

        Dir = Normal(ToPlayer);
        Strength = (1.0 - (Sqrt(DistSquared) / AttractionRange)) * Attraction;

        FinalVelocity = Dir * Strength * DeltaTime;

        PlayerHarry.Velocity += FinalVelocity;
    }
}

function bool isHarryNear(optional float requiredDistance)
{
    local float Size;
    local float distToCheck;
    distToCheck = SightRadius;
    Size = VSize(PlayerHarry.Location - Location);
    //PlayerHarry.ClientMessage("Distance" @ string(Size));

    if (requiredDistance != 0)
    {
        distToCheck = requiredDistance;
    }

    if (VSize(PlayerHarry.Location - Location) < distToCheck)
    {
        //Log("is close: " $ string(VSize(PlayerHarry.Location - Location) < distToCheck));
        lastHarryPos = PlayerHarry.Location;
        return True;
    }
    //Log("not close");
    return False;
}

defaultproperties
{
    AttractionRange=512.0
    Attraction=256.0
    bHidden=True
}
