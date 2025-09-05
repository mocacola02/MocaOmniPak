class MOCADamageTrigger extends MOCATrigger;

var() int Damage; //Moca: How much to damage Harry

function Activate( actor Other, pawn Instigator )
{
    ProcessTrigger();
}

function ProcessTrigger ()
{
    Log("ACTIVATING DAMAGE TRIGGER!!!!!!!!!!!!!!!!");

    if (PlayerHarry != None)
    {
        PlayerHarry.TakeDamage(Damage, None, location, vect(0,0,0), 'DamageTrigger');
    }
}

defaultproperties
{
     bSendEventOnEvent=True
}
