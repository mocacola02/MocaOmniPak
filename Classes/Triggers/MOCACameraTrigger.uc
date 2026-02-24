//================================================================================
// MOCACameraTrigger.
//================================================================================
class MOCACameraTrigger extends MOCATrigger;

var() bool bTurnHarry;				// Moca: Should Harry turn towards MOCACameraTarget? Def: False
var() BaseCam.ECamMode CameraMode;	// Moca: What camera mode to use? Def: CM_Standard


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	local MOCACameraTarget CamTarget;
	// If mode is boss
	if ( CameraMode == CM_Boss )
	{
		// Get cam target
		foreach AllActors(class'MOCACameraTarget', CamTarget)
		{
			if ( CamTarget.Tag == Event )
			{
				break;
			}
		}
		// If we didn't find the correct cam target
		if ( CamTarget.Tag != Event )
		{
			// Log error and return
			Log(string(Self)$" could not find MOCACameraTarget with tag "$Event);
			return;
		}
		// Set boss target to cam target
		PlayerHarry.BossTarget = CamTarget;
		// If turn harry, set his rotation toward cam target
		if ( bTurnHarry )
		{
			PlayerHarry.SetRotation(Rotator(CamTarget.Location - PlayerHarry.Location));
		}
	}
	// Set camera mode
	SetCam();
}

function SetCam()
{
	PlayerHarry.Cam.SetCameraMode(CameraMode);
}

defaultproperties
{
	CameraMode=CM_Standard
}