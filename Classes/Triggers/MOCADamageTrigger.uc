class MOCADamageTrigger extends MOCATrigger;

var() int Damage;		// Moca: How much to damage Harry. Def: 5
var() name DamageName;	// Moca: Name of damage type. Use ZonePain for a kill zone style death. See harry's class for other DamageTypes. Def: DamageTrigger. 


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// Take damage
	PlayerHarry.TakeDamage(Damage, None, Location, vect(0,0,0), DamageName);
}

defaultproperties
{
	Damage=5
	DamageName=DamageTrigger

	bSendEventOnEvent=True
}
