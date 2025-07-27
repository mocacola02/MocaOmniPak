//================================================================================
// MOCACameraTrigger.
//================================================================================

class MOCACameraTrigger extends Trigger;

var harry PlayerHarry;

enum ECamMode 
{
	CM_Startup,
	CM_Idle,
	CM_Transition,
	CM_Standard,
	CM_Quidditch,
	CM_FlyingCar,
	CM_Dueling,
	CM_CutScene,
	CM_Boss,
	CM_Free
};

var() bool OrientHarry;  //Moca: Orient Harry to face CameraTarget?
var() ECamMode CameraMode; //Moca: CameraMode to switch to
var() Name CameraTargetTag; //Moca: Tag of the MOCACameraTarget

event PreBeginPlay()
{
	Super.PreBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);
}

function Activate ( actor Other, pawn Instigator )
{
    ProcessTrigger();
}

function ProcessTrigger()
{
    local MOCACameraTarget A;
	local MOCACameraTarget CamTarget;

	if (CameraMode == CM_Boss)
	{
		foreach AllActors(Class'MOCACameraTarget', A)
		{
			if (A.Tag == CameraTargetTag)
			{
				CamTarget = A;
				break; // Exit the loop early when a match is found
			}
		}

		if (CamTarget == None)
		{
			return;
		}

		PlayerHarry.BossTarget = CamTarget;

		if (OrientHarry)
		{
			log("rotat");
			PlayerHarry.SetRotation(Rotator(CamTarget.Location - PlayerHarry.Location));
		}
	}

	SetCam(CameraMode);
}

function SetCam( ECamMode eMode )
{
	switch( eMode )
	{
		case CM_Startup:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Startup);		break;
		case CM_Idle:		PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Idle);			break;

		case CM_Transition:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Transition); break;
		
		case CM_Standard:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Standard);	break;
		case CM_FlyingCar:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_FlyingCar);	break;
		case CM_Quidditch:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Quidditch);	break;
		case CM_Dueling:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Dueling);		break;
		case CM_CutScene:	PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_CutScene);	break;
		case CM_Boss:		PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Boss);		break;

		case CM_Free:		PlayerHarry.Cam.SetCameraMode(PlayerHarry.Cam.ECamMode.CM_Free);		break;
		
		
		default: log("Camera: Trying to set a camera mode that is not supported!!!");
	}
}

defaultproperties
{
}
