//================================================================================
// MOCAChangeSizeTrigger.
//================================================================================
class MOCAChangeSizeTrigger extends MOCATrigger;

//= Export Vars =//
var() bool  bKeepHarryStill;	// Moca: Should Harry be kept in place during the size change? Def: True
var() bool bNoFallingDamage;	// Moca: Should there be no falling damage any non-1.0 scales? Def: True
var() float TargetScale;		// Moca: Target scale to scale Harry to. Def: 1.0 (aka default sizes)
var() float ChangeTime;			// Moca: How long it takes to scale Harry. Def: 1.0
var() name  ChangeAnimation;	// Moca: Animation to play on Harry during the scale. Def: fidget_1

//= General Vars =//
var bool bRepeatRun;
var float CurrentTime;			// Moca: Current scaling time
var Vector PreScaleLocation;	// Moca: Location Harry was at before scaling so we can hold him in place

//= Default Scale Vars =//
// Harry's default scale values
var float DefScale;
var float DefColRad, DefColHgt;
var float DefGS, DefGRS, DefGJS, DefGES;
var float DefJumpZ;
var float DefCamDist, DefCamZ;

//= Start Scale Vars =//
// Scale values at the start of a new scale
var float StartScale;
var float StartColRad, StartColHgt;
var float StartGS, StartGRS, StartGJS, StartGES;
var float StartJumpZ;
var float StartCamDist, StartCamZ;

//= End Scale Vars =//
// Scale values to lerp to by the end of the scale
var float EndScale;
var float EndColRad, EndColHgt;
var float EndGS, EndGRS, EndGJS, EndGES;
var float EndJumpZ;
var float EndCamDist, EndCamZ;


//===================
// Trigger Handling
//===================

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( !bRepeatRun )
	{
		SetDefScales();
		bRepeatRun = True;
	}

	TargetScale = FMax(TargetScale, 0.125);
	SetStartScale();
	SetEndScales(TargetScale);

	if ( !IsInState('stateChangeSize') && StartScale != EndScale )
	{
		StopOtherScales();

		if ( ChangeTime > 0.0 )
		{
			DebugLog("Preparing to scale over " $ ChangeTime $ " seconds");
			PreScaleLocation = PlayerHarry.Location;
			GotoState('stateChangeSize');
		}
		else
		{
			DebugLog("Instantly changing scale");
			InstantChange();
		}
	}
	else
	{
		DebugLog("We are either already changing, or we are already at the target scale");
	}
}


//==========
// Scaling
//==========

function InstantChange()
{
	PlayerHarry.SetCollisionSize(EndColRad, EndColHgt);

	PlayerHarry.DrawScale 		= EndScale;
	PlayerHarry.GroundSpeed 	= EndGS;
	PlayerHarry.GroundRunSpeed 	= EndGRS;
	PlayerHarry.GroundJumpSpeed = EndGJS;
	PlayerHarry.GroundEctoSpeed = EndGES;
	PlayerHarry.JumpZ 			= EndJumpZ;

	PlayerHarry.Cam.SetDistance(EndCamDist);
	PlayerHarry.Cam.SetZOffset(EndCamZ);
}

function SetStartScale()
{
	StartScale 	= 	PlayerHarry.DrawScale;
	StartColRad = 	PlayerHarry.CollisionRadius;
	StartColHgt = 	PlayerHarry.CollisionHeight;
	StartGS 	= 	PlayerHarry.GroundSpeed;
	StartGRS 	= 	PlayerHarry.GroundRunSpeed;
	StartGJS 	= 	PlayerHarry.GroundJumpSpeed;
	StartGES 	= 	PlayerHarry.GroundEctoSpeed;
	StartJumpZ 	= 	PlayerHarry.JumpZ;
	StartCamDist= 	PlayerHarry.Cam.CurrentSet.fLookAtDistance;
	StartCamZ 	= 	PlayerHarry.Cam.CurrentSet.vLookAtOffset.Z;

	DebugLog("Start scale: " $ StartScale);
}

function SetEndScales(float TS)
{
	local float MoveMod, JumpMod, CamMod, DistMod;

	// Not really a great solution, but with how niche this trigger is likely to be, I'd rather not spend a ton of time calculating this
	if ( TS < 1.0 )
	{
		PlayerHarry.bNoFallingDamage = bNoFallingDamage;
		MoveMod = 1.5;
		JumpMod = 2.5;
		CamMod 	= 0.75;
		DistMod = 1.0;
	}
	else if ( TS > 1.0 )
	{
		PlayerHarry.bNoFallingDamage = bNoFallingDamage;
		MoveMod = 0.85;
		JumpMod = 0.85;
		CamMod = 0.75;
		DistMod = 1.334;
	}
	else
	{
		PlayerHarry.bNoFallingDamage = False;
		MoveMod = 1.0;
		JumpMod = 1.0;
		CamMod 	= 1.0;
		DistMod = 1.0;
	}

	EndScale	= DefScale	* TS;
	EndColRad 	= DefColRad * TS;
	EndColHgt 	= DefColHgt * TS;
	EndGS 		= DefGS 	* TS * MoveMod;
	EndGRS 		= DefGRS 	* TS * MoveMod;
	EndGJS 		= DefGJS 	* TS * MoveMod;
	EndGES 		= DefGES 	* TS * MoveMod;
	EndJumpZ 	= DefJumpZ 	* TS * JumpMod;
	EndCamDist 	= DefCamDist* TS * DistMod;
	EndCamZ 	= DefCamZ 	* TS * CamMod;

	DebugLog("End scale: " $ EndScale);
}

function SetDefScales()
{
	DefScale 	= PlayerHarry.MapDefault.DrawScale;
	DefColRad 	= PlayerHarry.MapDefault.CollisionRadius;
	DefColHgt 	= PlayerHarry.MapDefault.CollisionHeight;
	DefGS 		= PlayerHarry.MapDefault.GroundSpeed;
	DefGRS 		= PlayerHarry.MapDefault.GroundRunSpeed;
	DefGJS 		= PlayerHarry.MapDefault.GroundJumpSpeed;
	DefGES 		= PlayerHarry.MapDefault.GroundEctoSpeed;
	DefJumpZ 	= PlayerHarry.MapDefault.JumpZ;
	DefCamDist 	= PlayerHarry.Cam.CamSetStandard.fLookAtDistance;
	DefCamZ 	= PlayerHarry.Cam.CamSetStandard.vLookAtOffset.Z;

	DebugLog(string(DefScale));
	DebugLog(string(DefColRad));
	DebugLog(string(DefColHgt));
	DebugLog(string(DefGS));
	DebugLog(string(DefGRS));
	DebugLog(string(DefGJS));
	DebugLog(string(DefGES));
	DebugLog(string(DefJumpZ));
	DebugLog(string(DefCamDist));
	DebugLog(string(DefCamZ));
}

function StopOtherScales()
{
	local MOCAChangeSizeTrigger A;
	
	foreach AllActors(class'MOCAChangeSizeTrigger', A)
	{
		if( A != self && A.IsInState('stateChangeSize') )
		{
			DebugLog("Stopping scaling on " $ A);
			A.GotoState(InitialState);
		}
	}
}


//=========
// States
//=========

state stateChangeSize
{
	event BeginState()
	{
		PreScaleLocation = PlayerHarry.Location;
		PlayerHarry.PlayAnim(ChangeAnimation);
	}

	event EndState()
	{
		CurrentTime = 0.0;
		PlayerHarry.bKeepStationary = False;
	}

	event Tick(float DeltaTime)
	{
		local float Alpha;

		if ( bKeepHarryStill )
		{
			PlayerHarry.bKeepStationary = True;
			PlayerHarry.SetLocation(Vec(PreScaleLocation.X, PreScaleLocation.Y, PlayerHarry.Location.Z));
		}

		CurrentTime += DeltaTime;
		Alpha = FClamp(CurrentTime / ChangeTime, 0.0, 1.0);

		PlayerHarry.SetCollisionSize(lerp(Alpha, StartColRad, EndColRad), lerp(Alpha, StartColHgt, EndColHgt));

		DebugLog("DS going from " $ StartScale $ " to " $ EndScale $ " and is at alpha " $ Alpha);

		PlayerHarry.DrawScale 		= lerp(Alpha, StartScale, EndScale);
		PlayerHarry.GroundSpeed 	= lerp(Alpha, StartGS, EndGS);
		PlayerHarry.GroundRunSpeed 	= lerp(Alpha, StartGRS, EndGRS);
		PlayerHarry.GroundJumpSpeed = lerp(Alpha, StartGJS, EndGJS);
		PlayerHarry.GroundEctoSpeed = lerp(Alpha, StartGES, EndGES);
		PlayerHarry.JumpZ 			= lerp(Alpha, StartJumpZ, EndJumpZ);

		PlayerHarry.Cam.SetDistance(lerp(Alpha, StartCamDist, EndCamDist));
		PlayerHarry.Cam.SetZOffset(lerp(Alpha, StartCamZ, EndCamZ));

		if ( CurrentTime >= ChangeTime )
		{
			DebugLog("Finished scale, ensuring correct values and idling");
			InstantChange();
			GotoState(InitialState);
		}
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bKeepHarryStill=True
	bNoFallingDamage=True
	TargetScale=1.0
	ChangeTime=1.0
	ChangeAnimation="fidget_1"
}