class MOCATrigger extends Trigger;

var(MOCADebug) bool bDebugLogging;
var harry PlayerHarry;


//=========
// Events
//=========

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Get player ref
	PlayerHarry = harry(Level.PlayerHarryActor);
}

event Activate(Actor Other, Pawn Instigator)
{
	// When activated, call process
	ProcessTrigger(Other,Instigator);
}

function ProcessTrigger(Actor Other, Pawn EventInstigator);


//============
// Debugging
//============

function PushError(string ErrorMessage)
{
	// Crash game with message
	ErrorMsg("THIS IS A MOCA OMNI PAK ERROR, DO NOT REPORT THIS TO M212 ENGINE! Error Message: "$ErrorMessage);
}

function DebugLog(string Msg)
{
	if ( bDebugLogging )
	{
		Log(self $ ": " $ Msg);
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bDoActionWhenTriggered=True
	bSpriteRelativeScale=True
}