//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() bool bResetHuntersOnCatch;
var() float HoldTime;
var() float FadeTime;
var() name HarryCaughtAnim;
var() Color CameraFadeColor;

var MOCAKnight KnightOwner;
var MOCAKnightBeam EyeBeam;


//=========
// Events
//=========

event Tick(float DeltaTime)
{
	if ( EyeBeam != None )
	{
		local Vector TargetPos;
		TargetPos = EyeBeam.GetTriggerPosition();
		SetLocation(TargetPos);
	}
}


function Setup(bool bResetHunters, float HoldT, float FadeT, name CaughtAnim, name EventName, Color FadeColor, MOCAKnight Knight)
{
	bResetHuntersOnCatch = bResetHunters;
	HoldTime = HoldT;
	FadeTime = FadeT;
	HarryCaughtAnim = CaughtAnim;
	CameraFadeColor = FadeColor;
	Event = EventName;
	KnightOwner = Knight;

	if ( KnightOwner != None )
	{
		EyeBeam = KnightOwner.EyeBeam;
	}

	LightRadius = 8.0;
}

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	if ( Other == PlayerHarry && !IsInState('stateCatch') )
	{
		DebugLog("Hit Harry, catching him!");
		GotoState('stateCatch');

		if ( KnightOwner != None )
		{
			KnightOwner.GotoState('stateCatch');;
		}
	}
}

function LockHarry()
{
	PlayerHarry.GotoState('stateIdle');
	PlayerHarry.bStationary = True;
	PlayerHarry.LoopAnim(HarryCaughtAnim);
}

function UnlockHarry()
{
	PlayerHarry.GotoState('PlayerWalking');
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
	Fader = Spawn(Class'FadeViewController');
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

		if ( KnightOwner != None )
		{
			KnightOwner.GotoState('stateIdle');
		}

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

	CollisionHeight=30
	CollisionRadius=30
	CollideType=CT_AlignedCylinder

	bHidden=False
	bDebugLogging=True

	bDynamicLight=True;
	LightType=LT_Steady;
	LightEffect=LE_WateryShimmer
	LightBrightness=150;
	LightHue=170;
	LightSaturation=32;
	LightRadius=0.0
}