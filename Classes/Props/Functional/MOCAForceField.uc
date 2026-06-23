class MOCAForceField extends MOCAFunctionalProp;

var() float ForceRange;		// Moca: How far does our force have influence? Def: 512.0
var() float ForceStrength;	// Moca: How strong is our force? Def: 128.0
var() float DispelRange;	// Moca: How close does Harry have to be to start preparing to dispel him? Def: 128.0
var() float DispelTime;		// Moca: How long does Harry have to be close to start dispelling him?	Def: 3.0
var() float DispelStrength;	// Moca: How strong should our dispel be? Def: -256.0
var() float PickupRatio;

var float DispelLevel;		// Current dispel time buildup


//==========
// Helpers
//==========

function bool IsHarryNear(float DistCheck)
{
	return GetDistanceBetweenActors(Self,PlayerHarry) <= DistCheck;
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
			DebugLog("Going to stateForce");
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
		//  Reset dispel time
		DispelLevel = 0.0;
	}

	event Tick(float DeltaTime)
	{
		// If Harry isn't within range, go back to idle
		if ( !IsHarryNear(ForceRange) )
		{
			DebugLog("Going to stateIdle");
			GotoState('stateIdle');
		}
		// If Harry is within dispel range, increment dispel level
		else if ( IsHarryNear(DispelRange) )
		{
			DispelLevel += DeltaTime;
			DebugLog("Dispel level: " $ DispelLevel);
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
			ForceStrength = DispelStrength;
		}
		// If dispel level is now 0.0, reset to normal force
		else if ( DispelLevel <= 0.0 )
		{
			ForceStrength = MapDefault.ForceRange;
		}

		local vector Direction, FinalForce;
		local float Distance, Strength;

		// Prep direction and get distance from it
		Direction = Location - PlayerHarry.Location;
		Distance = VSize(Direction);
		DebugLog("Distance: " $ Distance);

		// Normalize direction
		Direction = Normal(Direction);

		// Calculate strength based on Harry's distance to force center
		Strength = (1.0 - (Distance / ForceRange)) * ForceStrength;

		// Set Harry's velocity
		FinalForce = Direction * Strength * DeltaTime;

		if ( Distance <= ForceRange * PickupRatio )
		{
			PlayerHarry.SetPhysics(PHYS_Flying);
			PlayerHarry.LoopAnim(PlayerHarry.HarryAnims[PlayerHarry.HarryAnimSet].fall);
		}
		else if ( PlayerHarry.Physics == PHYS_Flying )
		{
			PlayerHarry.SetPhysics(PHYS_Walking);
		}

		PlayerHarry.Velocity += FinalForce;
	}
}


defaultproperties
{
	bHidden=True
	bStatic=False
	ForceRange=512.0
	ForceStrength=768.0
	DispelRange=128.0
	DispelTime=2.0
	DispelStrength=-1024.0
	PickupRatio=0.45
}