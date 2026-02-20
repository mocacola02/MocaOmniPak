//================================================================================
// MOCAChangeSizeTrigger.
//================================================================================
class MOCAChangeSizeTrigger extends MOCATrigger;

var() bool bKeepHarryStill;
var() float TargetScale;
var() float ChangeTime;
var() name ChangeAnimation;

var float ChangeFactor;
var float CurrentTime;

var Vector PreScaleLocation;


///////////
// Events
///////////

event Activate(Actor Other, Pawn Instigator)
{
	if ( Other == PlayerHarry && !IsInState('stateChangeSize') )
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
		ChangeFactor = TargetScale / StartingScale;
		PlayerHarry.PlayAnim(ChangeAnimation);
	}

	event Tick(float DeltaTime)
	{
		if ( bKeepHarryStill )
		{
			local Vector HoldLocation;
			HoldLocation = Vect(PreScaleLocation.X,PreScaleLocation.Y,PlayerHarry.Location.Z);
			PlayerHarry.SetLocation(HoldLocation);
		}

		local float ChangeIncrement;
		local float TargetRadius,TargetHeight;
		local float TargetDist,TargetOffset;
		ChangeIncrement = DeltaTime / ChangeTime;
		TargetRadius = PlayerHarry.CollisionRadius + (((PlayerHarry.CollisionRadius * ChangeFactor) - PlayerHarry.CollisionRadius) * ChangeIncrement);
		TargetHeight = PlayerHarry.CollisionHeight + (((PlayerHarry.CollisionHeight * ChangeFactor) - PlayerHarry.CollisionHeight) * ChangeIncrement);
		TargetDist = PlayerHarry.Cam.CurrentSet.fLookAtDistance + (((PlayerHarry.Cam.CurrentSet.fLookAtDistance * ChangeFactor) - PlayerHarry.Cam.CurrentSet.fLookAtDistance) * ChangeIncrement);
		TargetOffset = PlayerHarry.Cam.CamTarget.vOffset.Z + (((PlayerHarry.Cam.CamTarget.vOffset.Z * ChangeFactor) - PlayerHarry.Cam.CamTarget.vOffset.Z) * ChangeIncrement);

		PlayerHarry.SetCollisionSize(TargetRadius,TargetHeight);
		PlayerHarry.DrawScale += (TargetScale - PlayerHarry.DrawScale) * ChangeIncrement;
		PlayerHarry.GroundSpeed += ((PlayerHarry.GroundSpeed * ChangeFactor) - PlayerHarry.GroundSpeed) * ChangeIncrement;
		PlayerHarry.GroundRunSpeed += ((PlayerHarry.GroundRunSpeed * ChangeFactor) - PlayerHarry.GroundRunSpeed) * ChangeIncrement;
		PlayerHarry.GroundJumpSpeed += ((PlayerHarry.GroundJumpSpeed * ChangeFactor) - PlayerHarry.GroundJumpSpeed) * ChangeIncrement;
		PlayerHarry.GroundEctoSpeed += ((PlayerHarry.GroundEctoSpeed * ChangeFactor) - PlayerHarry.GroundEctoSpeed) * ChangeIncrement;
		PlayerHarry.JumpZ += ((PlayerHarry.JumpZ * ChangeFactor) - PlayerHarry.JumpZ) * ChangeIncrement;
		PlayerHarry.Cam.SetDistance(TargetDist);
		PlayerHarry.Cam.SetZOffset(TargetOffset);

		CurrentTime += DeltaTime;

		if ( CurrentTime >= ChangeTime )
		{
			GotoState(LastValidState);
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