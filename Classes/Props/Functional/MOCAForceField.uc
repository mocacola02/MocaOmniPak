class MOCAForceField extends HProp;

var(MOCAFFAttraction) float AttractionRange;    // Moca: Maximum AttractionRange of effect. Def: 512.0
var(MOCAFFDispel) float DispelRange;		// Moca: How close should Harry be to start preparing to Dispel him? Only useful is attraction is positive. I recommend using around a third of your attraction range.  Def: 192.0
var(MOCAFFDispel) float DispelTime;		// Moca: How long does Harry need to be close for the Dispel function be triggered? Def: 3.0
var(MOCAFFDispel) float DispelStrength;	// Moca: How strong is the Dispel effect? Def: -512.0
var(MOCAFFDispel) float DispelDuration;	// Moca: How long does Dispel last? Def: 3.0
var(MOCAFFAttraction) float Attraction;     	// Moca: Positive = pull, Negative = push, 0 = no force. Def: 256.0

var float DispelLevel;
var vector lastHarryPos;

auto state stateDormant
{
    begin:
		DispelLevel = 0.0;

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

		if (isHarryNear(DispelRange))
		{
			DispelLevel += DeltaTime;
		}
		else
		{
			DispelLevel -= DeltaTime;
		}

		DispelLevel = FClamp(DispelLevel,0.0,99999.0);

		if (DispelLevel >= DispelTime)
		{
			GotoState('stateDispel');
		}

        local vector ToPlayer;
        local vector Dir;
        local float DistSquared;
        local float Strength;
        local vector FinalVelocity;

        Global.Tick(DeltaTime);

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

state stateDispel
{
	begin:
		Log(string(self) $ " IS DispelING!!!!!!!!!!!!");
		Attraction = DispelStrength;
		sleep(DispelDuration);
		Attraction = MapDefault.Attraction;
		GotoState('stateDormant');
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
	DispelRange=128.0
	DispelTime=3.0
	DispelStrength=-512.0
	DispelDuration=3.0
}
