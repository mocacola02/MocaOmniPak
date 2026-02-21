class MOCAForceField extends HProp;

var() float ForceRange;
var() float ForceStrength;
var() float DispelRange;
var() float DispelTime;
var() float DispelStrength;

var float DispelLevel;


function bool IsHarryNear(float DistCheck)
{
	return MOCAHelpers.GetDistanceBetweenActors(Self,PlayerHarry) > DistCheck;
}

auto state stateIdle
{
	begin:
		if ( IsHarryNear(ForceRange) )
		{
			GotoState('stateForce');
		}

		Sleep(0.25);
		Goto('begin');
}

state stateForce
{
	event EndState()
	{
		DispelLevel = 0.0;
	}

	event Tick(float DeltaTime)
	{
		if ( !IsHarryNear(ForceRange) )
		{
			GotoState('stateIdle');
		}
		else if ( IsHarryNear(DispelRange) )
		{
			DispelLevel += DeltaTime;
		}
		else
		{
			DispelLevel -= DeltaTime;
		}

		DispelLevel = FClamp(DispelLevel,0.0,99999.0);

		if ( DispelLevel >= DispelTime )
		{
			ForceRange = DispelStrength;
		}
		else if ( DispelTime <= 0.0 )
		{
			ForceRange = MapDefault.ForceRange;
		}

		local vector Direction;
		local float Distance, Strength;

		Direction = PlayerHarry.Location - Location;
		Distance = VSize(Direction);

		Direction = Normal(Direction);

		Strength = (1.0 - (Distance / ForceRange)) * ForceStrength;

		PlayerHarry.Velocity += Direction * Strength * DeltaTime;
	}
}


defaultproperties
{
	ForceRange=512.0
	ForceStrength=128.0
	DispelRange=128.0
	DispelTime=3.0
	DispelStrength=-256.0
}