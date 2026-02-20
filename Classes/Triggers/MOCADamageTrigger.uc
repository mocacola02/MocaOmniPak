class MOCADamageTrigger extends MOCATrigger;

var() int Damage;		//Moca: How much to damage Harry
var() name DamageName;

function Activate(Actor Other, Pawn Instigator)
{
	ProcessTrigger();
}

function ProcessTrigger ()
{
	PlayerHarry.TakeDamage(Damage, None, location, vect(0,0,0), DamageName);
}

defaultproperties
{
	DamageName=DamageTrigger

	bSendEventOnEvent=True
}
