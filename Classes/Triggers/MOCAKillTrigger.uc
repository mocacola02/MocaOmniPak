class MOCAKillTrigger extends MOCATrigger;

var() bool bSendEventOnKill;				// Moca: Should we send an event when we kill something? Def: True
var() name DamageName; 						// Moca: What type of damage to inflict? Use ZonePain for a kill zone style death. See harry's class for other DamageTypes. Default: ZonePain
var() array<class<HPawn>> ClassesToKill;	// Moca: List of HPawns we should kill.


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	local int i;

	if ( ClassesToKill.Length <= 0 )
	{
		Log(string(Self)$" has no classes listed to kill!");
	}

	for ( i = 0; i < ClassesToKill.Length; i++ )
	{
		if ( Other.Class == ClassesToKill[i] )
		{
			Other.TakeDamage(MAXINT,None,Location,Velocity,DamageName);

			if ( bSendEventOnKill )
			{
				TriggerEvent(Event,Self,None);
			}
		}
	}
}


defaultproperties
{
	bSendEventOnKill=True
	DamageName=ZonePain
}