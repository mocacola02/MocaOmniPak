class MOCAKillTrigger extends MOCATrigger;

var() bool bSendEventOnKill;
var() name DamageName; // Moca: What type of damage to inflict? Use ZonePain for a kill zone style death. See harry's class for other DamageTypes. Default: ZonePain
var() array<class<HPawn>> ClassesToKill;


function ProcessTrigger(Actor Other)
{
	local int i;

	if ( MOCAHelpers.IsEmpty(ClassesToKill) )
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