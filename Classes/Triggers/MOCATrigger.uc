class MOCATrigger extends Trigger;

var harry PlayerHarry;

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

function PushError(string ErrorMessage)
{
	// Crash game with message
	ErrorMsg("THIS IS A MOCA OMNI PAK ERROR, DO NOT REPORT THIS TO M212 ENGINE! Error Message: "$ErrorMessage);
}


defaultproperties
{
	bDoActionWhenTriggered=True
	bSpriteRelativeScale=True
}