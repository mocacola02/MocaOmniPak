//================================================================================
// MOCAChangeSizeTrigger.
//================================================================================
class MOCAChangeSizeTrigger extends MOCATrigger;

var() bool bKeepHarryStill;	// Moca: Should Harry be kept still during size change? Def: True
var() float TargetScale;	// Moca: What scale to make Harry. Def: 1.0
var() float ChangeTime;		// Moca: How long it takes to grow/shrink. Def: 1.0
var() name ChangeAnimation;	// Moca: What animation should Harry play during change? Def: fidget_1

var float ChangeFactor;	// Current scale factor
var float CurrentTime;	// Current time accrued

var Vector PreScaleLocation; // Location of Harry before scaling


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If not changing size, change size
	if ( !IsInState('stateChangeSize') )
	{
		GotoState('stateChangeSize');
	}
}


///////////
// States
///////////

state stateChangeSize
{
	event BeginState()
	{
		// Calculate change factor
		ChangeFactor = TargetScale / DrawScale;
		// Play change anim
		PlayerHarry.PlayAnim(ChangeAnimation);
	}

	event Tick(float DeltaTime)
	{
		// If keep harry still
		if ( bKeepHarryStill )
		{
			local Vector HoldLocation;
			// Hold Harry in place but let him shift up or down
			HoldLocation = Vec(PreScaleLocation.X,PreScaleLocation.Y,PlayerHarry.Location.Z);
			PlayerHarry.SetLocation(HoldLocation);
		}

		local float ChangeIncrement;
		local float TargetRadius,TargetHeight;
		local float TargetDist,TargetOffset;
		// Get change increment
		ChangeIncrement = DeltaTime / ChangeTime;
		// Calculate new targets
		TargetRadius = PlayerHarry.CollisionRadius + (((PlayerHarry.CollisionRadius * ChangeFactor) - PlayerHarry.CollisionRadius) * ChangeIncrement);
		TargetHeight = PlayerHarry.CollisionHeight + (((PlayerHarry.CollisionHeight * ChangeFactor) - PlayerHarry.CollisionHeight) * ChangeIncrement);
		TargetDist = PlayerHarry.Cam.CurrentSet.fLookAtDistance + (((PlayerHarry.Cam.CurrentSet.fLookAtDistance * ChangeFactor) - PlayerHarry.Cam.CurrentSet.fLookAtDistance) * ChangeIncrement);
		TargetOffset = PlayerHarry.Cam.CamTarget.vOffset.Z + (((PlayerHarry.Cam.CamTarget.vOffset.Z * ChangeFactor) - PlayerHarry.Cam.CamTarget.vOffset.Z) * ChangeIncrement);

		// Apply target values
		PlayerHarry.SetCollisionSize(TargetRadius,TargetHeight);
		PlayerHarry.DrawScale += (TargetScale - PlayerHarry.DrawScale) * ChangeIncrement;
		PlayerHarry.GroundSpeed += ((PlayerHarry.GroundSpeed * ChangeFactor) - PlayerHarry.GroundSpeed) * ChangeIncrement;
		PlayerHarry.GroundRunSpeed += ((PlayerHarry.GroundRunSpeed * ChangeFactor) - PlayerHarry.GroundRunSpeed) * ChangeIncrement;
		PlayerHarry.GroundJumpSpeed += ((PlayerHarry.GroundJumpSpeed * ChangeFactor) - PlayerHarry.GroundJumpSpeed) * ChangeIncrement;
		PlayerHarry.GroundEctoSpeed += ((PlayerHarry.GroundEctoSpeed * ChangeFactor) - PlayerHarry.GroundEctoSpeed) * ChangeIncrement;
		PlayerHarry.JumpZ += ((PlayerHarry.JumpZ * ChangeFactor) - PlayerHarry.JumpZ) * ChangeIncrement;
		PlayerHarry.Cam.SetDistance(TargetDist);
		PlayerHarry.Cam.SetZOffset(TargetOffset);
		// Increment time
		CurrentTime += DeltaTime;
		// If finished, go to initial state
		if ( CurrentTime >= ChangeTime )
		{
			GotoState(InitialState);
		}
	}
}


defaultproperties
{
	bKeepHarryStill=True
	TargetScale=1.0
	ChangeTime=1.0
	ChangeAnimation=fidget_1
}