class MOCATrigger extends Trigger;

var harry PlayerHarry;

event PostBeginPlay()
{
    super.PostBeginPlay();
    PlayerHarry = harry(Level.PlayerHarryActor);
}

defaultproperties
{
    bDoActionWhenTriggered=True
	bSpriteRelativeScale=True
}