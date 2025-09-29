//================================================================================
// MOCAChangeSizeTrigger.
//================================================================================

class MOCAChangeSizeTrigger extends MOCATrigger;

//TODO: this all feels really inefficient

var bool hasBeenActivated;
var() float sizeMultiplier;   			// Moca: What size to make Harry Def: 2.0
var() float growthFrameRate;  			// Moca: How smooth should the resize be? Def: 60.0
var() float growthTime;       			// Moca: How long should the resize take? Def: 2.0
var() bool mustBeReactivated; 			// Moca: Does the trigger need to be reactivated by another trigger to grow again? Def: True
var() name growthAnimation;   			// Moca: What animation should Harry play while growing? Def: fidget_1
var() bool freezeHarryDuringGrowth; 	// Moca: Should Harry be held in place during growth? If false, movement may be buggy. Def: True

//so many variables. almost certainly a better way to do this but if it works...... and we aren't exactly strapped for memory
//follow up comment: bruh
var float Elapsed;
var float FrameTime;
var float Alpha;
var float StartHeight;
var float StartRadius;
var float StartScale;
var float StartGroundSpeed;
var float StartGroundJumpSpeed;
var float StartGroundEctoSpeed;
var float StartCamDist;
var float StartCamHeight;
var float StartAccelRate;
var float StartJumpZ;
var float EndHeight;
var float EndRadius;
var float EndScale;
var float EndCamDist;
var float EndCamHeight;
var float EndGroundSpeed;
var float EndGroundJumpSpeed;
var float EndGroundEctoSpeed;
var float EndAccelRate;
var float EndJumpZ;
var float CurrentHeight;
var float CurrentRadius;
var float CurrentScale;
var float CurrentCamDist;
var float CurrentCamHeight;
var float CurrentGroundSpeed;
var float CurrentGroundJumpSpeed;
var float CurrentGroundEctoSpeed;
var float CurrentAccelRate;
var float CurrentJumpZ;
var bool isExternalTrigger;
var vector preGrowthLocation;

event Activate (Actor Other, Pawn Instigator)
{
  if(hasBeenActivated)
  {
    hasBeenActivated = false;
    //Log("REACTIVATED!");
  }
  else
  {
    isExternalTrigger = true;
    if ((Other.IsA('harry') || isExternalTrigger) && !hasBeenActivated)
    {
      hasBeenActivated = true;
      isExternalTrigger = false;
      Disable('Touch');
      preGrowthLocation = PlayerHarry.Location;
      //Log("Hold Harry at: " $ string(preGrowthLocation));
      GotoState('stateChangeSize');
    }
  }
}

state stateChangeSize
{
  event Tick (float DeltaTime)
  {
    if (freezeHarryDuringGrowth)
    {
      PlayerHarry.SetLocation(vec(preGrowthLocation.X,preGrowthLocation.Y,PlayerHarry.Location.Z));
    }
  }

  begin:
    if (freezeHarryDuringGrowth)
    {
      PlayerHarry.bKeepStationary = true;
    }
		// Cache starting values
		StartHeight = PlayerHarry.CollisionHeight;
		StartRadius = PlayerHarry.CollisionRadius;
		StartScale  = PlayerHarry.DrawScale;
    StartGroundSpeed = PlayerHarry.GroundSpeed;
    StartGroundJumpSpeed = PlayerHarry.GroundJumpSpeed;
    StartGroundEctoSpeed = PlayerHarry.GroundEctoSpeed;
    StartCamDist = PlayerHarry.Cam.CurrentSet.fLookAtDistance;
    StartCamHeight = PlayerHarry.Cam.CamTarget.vOffset.Z;
    StartAccelRate = PlayerHarry.AccelRate;
    StartJumpZ = PlayerHarry.JumpZ;

		// Calculate end values
		EndHeight = StartHeight * sizeMultiplier;
		EndRadius = StartRadius * sizeMultiplier;
		EndScale  = StartScale  * sizeMultiplier;
    EndGroundSpeed = StartGroundSpeed * sizeMultiplier;
    EndGroundJumpSpeed = StartGroundJumpSpeed * sizeMultiplier;
    EndGroundEctoSpeed = StartGroundEctoSpeed * sizeMultiplier;
    EndCamDist = StartCamDist * sizeMultiplier;
    EndCamHeight = StartCamHeight * sizeMultiplier;
    if (sizeMultiplier >= 1.0)
    {
      EndAccelRate = StartAccelRate * (sizeMultiplier * 10);
      EndJumpZ = StartJumpZ * (sizeMultiplier * 0.5);
    }
    else
    {
      EndAccelRate = StartAccelRate * (sizeMultiplier / 10);
      EndJumpZ = StartJumpZ * (sizeMultiplier * 2);
    }

    //Log("Start Ground, End Ground: " $ string(StartGroundSpeed) $ ", " $ string(EndGroundSpeed));

		Elapsed = 0;
		FrameTime = 1.0 / growthFrameRate;

		while (Elapsed < growthTime)
		{
			Alpha = Elapsed / growthTime;

			CurrentHeight = StartHeight + (EndHeight - StartHeight) * Alpha;
			CurrentRadius = StartRadius + (EndRadius - StartRadius) * Alpha;
			CurrentScale  = StartScale + (EndScale - StartScale) * Alpha;
      CurrentGroundSpeed = StartGroundSpeed + (EndGroundSpeed - StartGroundSpeed) * Alpha;
      CurrentGroundJumpSpeed = StartGroundJumpSpeed + (EndGroundJumpSpeed - StartGroundJumpSpeed) * Alpha;
      CurrentGroundEctoSpeed = StartGroundEctoSpeed + (EndGroundEctoSpeed - StartGroundEctoSpeed) * Alpha;
      CurrentCamDist = StartCamDist + (EndCamDist - StartCamDist) * Alpha;
      CurrentCamHeight = StartCamHeight + (EndCamHeight - StartCamHeight) * Alpha;
      CurrentAccelRate = StartAccelRate + (EndAccelRate - StartAccelRate) * Alpha;
      CurrentJumpZ = StartJumpZ + (EndJumpZ - StartJumpZ) * Alpha;

			// Apply changes
			PlayerHarry.SetCollisionSize(CurrentRadius, CurrentHeight);
			PlayerHarry.DrawScale = CurrentScale;
      PlayerHarry.GroundSpeed = CurrentGroundSpeed;
      PlayerHarry.GroundRunSpeed = CurrentGroundSpeed;
      PlayerHarry.GroundJumpSpeed = CurrentGroundJumpSpeed;
      PlayerHarry.GroundEctoSpeed = CurrentGroundEctoSpeed;
      PlayerHarry.Cam.SetDistance(CurrentCamDist);
      PlayerHarry.Cam.SetZOffset(CurrentCamHeight);
      PlayerHarry.AccelRate = CurrentAccelRate;
      PlayerHarry.JumpZ = CurrentJumpZ;

			Sleep(FrameTime);
			Elapsed += FrameTime;
		}

		// Ensure exact end values are applied
		PlayerHarry.SetCollisionSize(EndRadius, EndHeight);
		PlayerHarry.DrawScale = EndScale;
    PlayerHarry.GroundSpeed = EndGroundSpeed;
    PlayerHarry.GroundRunSpeed = EndGroundSpeed;
    PlayerHarry.GroundJumpSpeed = EndGroundJumpSpeed;
    PlayerHarry.GroundEctoSpeed = EndGroundEctoSpeed;
    PlayerHarry.Cam.SetDistance(EndCamDist);
    PlayerHarry.Cam.SetZOffset(EndCamHeight);
    PlayerHarry.AccelRate = EndAccelRate;
    PlayerHarry.JumpZ = EndJumpZ;

    //Log("Start, End, and Harry's AccelRate: " $ string(StartAccelRate) $ ", " $ string(EndAccelRate) $ ", " $ string(PlayerHarry.AccelRate));

    if (!mustBeReactivated)
    {
      Enable('Touch');
    }

		GotoState('stateInactive');
}

state stateInactive
{
  event BeginState()
  {
    Elapsed = 0;
    FrameTime = 0;
    Alpha = 0;
    StartHeight = 0;
    StartRadius = 0;
    StartScale = 0;
    EndHeight = 0;
    EndRadius = 0;
    EndScale = 0;
    CurrentHeight = 0;
    CurrentRadius = 0;
    CurrentScale = 0; 
    PlayerHarry.bKeepStationary = false;
  }
}

defaultproperties
{
  sizeMultiplier=2.0
  growthFrameRate=60.0
  growthTime=2.0
  mustBeReactivated=true
  growthAnimation=fidget_1
  freezeHarryDuringGrowth=true
}