class MOCATrigger extends Trigger;

var harry PlayerHarry;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);
}

event Activate(Actor Other, Pawn Instigator)
{
	ProcessTrigger();
}

defaultproperties
{
	bDoActionWhenTriggered=True
	bSpriteRelativeScale=True
}