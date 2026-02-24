class MOCAForceField extends HProp;

var() float ForceRange;		// Moca: How far does our force have influence? Def: 512.0
var() float ForceStrength;	// Moca: How strong is our force? Def: 128.0
var() float DispelRange;	// Moca: How close does Harry have to be to start preparing to dispel him? Def: 128.0
var() float DispelTime;		// Moca: How long does Harry have to be close to start dispelling him?	Def: 3.0
var() float DispelStrength;	// Moca: How strong should our dispel be? Def: -256.0

var float DispelLevel;		// Current dispel time buildup


function bool IsHarryNear(float DistCheck)
{
	return GetDistanceBetweenActors(Self,PlayerHarry) > DistCheck;
}

function float GetDistanceBetweenActors(Actor A, Actor B)
{
	return VSize(A.Location - B.Location);
}


///////////
// States
///////////

auto state stateIdle
{
	begin:
		// If Harry is within range, start calculating force
		if ( IsHarryNear(ForceRange) )
		{
			GotoState('stateForce');
		}

		// Otherwise, wait a quarter of a second and check again
		Sleep(0.25);
		Goto('begin');
}

state stateForce
{
	event EndState()
	{
		//  Reset despel time
		DispelLevel = 0.0;
	}

	event Tick(float DeltaTime)
	{
		// If Harry isn't within range, go back to idle
		if ( !IsHarryNear(ForceRange) )
		{
			GotoState('stateIdle');
		}
		// If Harry is within dispel range, increment dispel level
		else if ( IsHarryNear(DispelRange) )
		{
			DispelLevel += DeltaTime;
		}
		// Otherwise, decrease our dispel level
		else
		{
			DispelLevel -= DeltaTime;
		}

		// Make sure dispel level doesn't go below 0.0
		DispelLevel = FClamp(DispelLevel,0.0,99999.0);

		// If dispel level exceeds our dispel time, switch over to dispel strength
		if ( DispelLevel >= DispelTime )
		{
			ForceRange = DispelStrength;
		}
		// If dispel time is now 0.0, reset to normal force
		else if ( DispelTime <= 0.0 )
		{
			ForceRange = MapDefault.ForceRange;
		}

		local vector Direction;
		local float Distance, Strength;
		// Prep direction and get distance from it
		Direction = PlayerHarry.Location - Location;
		Distance = VSize(Direction);
		// Normalize direction
		Direction = Normal(Direction);
		// Calculate strength based on Harry's distance to force center
		Strength = (1.0 - (Distance / ForceRange)) * ForceStrength;
		// Set Harry's velocity
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