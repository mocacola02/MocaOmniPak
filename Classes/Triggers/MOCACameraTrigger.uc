//================================================================================
// MOCACameraTrigger.
//================================================================================
class MOCACameraTrigger extends MOCATrigger;

var() bool bTurnHarry;
var() BaseCam.ECamMode CameraMode;


///////////
// Events
///////////

event Activate(Actor Other, Pawn Instigator)
{
	ProcessTrigger();
}


///////////////////
// Main Functions
///////////////////

function ProcessTrigger()
{
	local MOCACameraTarget CamTarget;

	if ( CameraMode == CM_Boss )
	{
		foreach AllActors(class'MOCACameraTarget', CamTarget)
		{
			if ( CamTarget.Tag == Event )
			{
				break;
			}
		}

		if ( CamTarget.Tag != Event )
		{
			Log(string(Self)$" could not find MOCACameraTarget with tag "$Event);
			return;
		}

		PlayerHarry.BossTarget = CamTarget;

		if ( bTurnHarry )
		{
			PlayerHarry.SetRotation(Rotator(CamTarget.Location - PlayerHarry.Location));
		}
	}

	SetCam();
}

function SetCam()
{
	PlayerHarry.Cam.SetCameraMode(CameraMode);
}