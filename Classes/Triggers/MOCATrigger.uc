class MOCATrigger extends Trigger;

var() int HoverOverMe; //Moca: This trigger is just a categorization trigger, it doesn't do anything different than a normal Trigger on its own

var harry PlayerHarry;

event PostBeginPlay()
{
    super.PostBeginPlay();
    PlayerHarry = harry(Level.PlayerHarryActor);
}

defaultproperties
{
    bDoActionWhenTriggered=True
}