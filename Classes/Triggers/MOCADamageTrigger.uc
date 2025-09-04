class MOCADamageTrigger extends Trigger;

var() int Damage; //Moca: How much to damage Harry

function Activate( actor Other, pawn Instigator )
{
    TriggerEvent('',Other,Instigator);
}

function TriggerEvent (name EventName, Actor Other, Pawn EventInstigator)
{
    local harry PlayerHarry;

    Log("ACTIVATING DAMAGE TRIGGER!!!!!!!!!!!!!!!!");

	PlayerHarry = harry(Level.PlayerHarryActor);
    if (PlayerHarry != None)
    {
        PlayerHarry.TakeDamage(Damage, None, location, vect(0,0,0), 'DamageTrigger');
    }
}

defaultproperties
{
     bSendEventOnEvent=True
}
