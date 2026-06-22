//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() bool bResetHuntersOnCatch;
var() float HoldTime;
var() float FadeTime;
var() name HarryCaughtAnim;
var() Color CameraFadeColor;


function Setup(bool bResetHunters, float HoldT, float FadeT, name CaughtAnim, name EventName, Color FadeColor)
{
	bResetHuntersOnCatch = bResetHunters;
	HoldTime = HoldT;
	FadeTime = FadeT;
	HarryCaughtAnim = CaughtAnim;
	CameraFadeColor = FadeColor;
	Event = EventName;
}

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( Other == PlayerHarry && !IsInState('stateCatch') )
	{
		GoToCatch();
	}
}

function GoToCatch()
{
	GotoState('stateCatch');
}

function LockHarry()
{
	PlayerHarry.bStationary = True;
	PlayerHarry.LoopAnim(HarryCaughtAnim);
}

function UnlockHarry()
{
	PlayerHarry.bStationary = False;
	PlayerHarry.LoopAnim(PlayerHarry.GetCurrIdleAnimName());
}

function TeleportHarry(Vector NewLocation, Rotator NewRotation)
{
	PlayerHarry.SetLocation(NewLocation);
	PlayerHarry.SetRotation(NewRotation);
}

function ResetHunters()
{
	if ( bResetHuntersOnCatch )
	{
		local MOCAKnightHunter A;
		
		foreach AllActors(class'MOCAKnightHunter', A)
		{
			A.Reset();
		}
	}
}

function FadeScreen(float Alpha, float FadeDuration)
{
	local FadeViewController Fader;
	Fader.Init(Alpha, CameraFadeColor.R, CameraFadeColor.G, CameraFadeColor.B, FadeDuration);
}


//=========
// States
//=========

state stateCatch
{
	begin:
		LockHarry();

		Sleep(HoldTime);
		FadeScreen(1.0, FadeTime);
		Sleep(FadeTime + 0.25);

		if ( PlayerHarry.IsA('MOCAharry') )
		{
			TeleportHarry(MOCAharry(PlayerHarry).RespawnLocation, MOCAharry(PlayerHarry).RespawnRotation);
		}
		else
		{
			TeleportHarry(PlayerHarry.ChessTargetLocation, PlayerHarry.Rotation);
		}

		Sleep(0.25);

		UnlockHarry();

		FadeScreen(0.0, FadeTime);

		TriggerEvent(Event, self, PlayerHarry);
		GotoState('stateLook');
}

//=====================
// Default Properties
//=====================

defaultproperties
{
	bResetHuntersOnCatch=True
	HoldTime=5.0
	FadeTime=1.0
	HarryCaughtAnim="webstuck"
	CameraFadeColor=(R=0,G=0,B=0)

	CollisionHeight=35
	CollisionRadius=42
	CollideType=CT_Box
}    