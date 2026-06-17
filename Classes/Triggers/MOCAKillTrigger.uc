class MOCAKillTrigger extends MOCATrigger;

var() bool bSendEventOnKill;				// Moca: Should we send an event when we kill something? Def: True
var() bool bDestroyInsteadOfDamage;			// Moca: Should we destroy the other actor instead of dealing damage? Def: False
var() name DamageName; 						// Moca: What type of damage to inflict? Use ZonePain for a kill zone style death. See harry's class for other DamageTypes. Default: ZonePain
var() array<class<HPawn>> ClassesToKill;	// Moca: List of HPawns we should kill.


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	local int i;

	DebugLog("I hit other actor " $ Other);

	if ( ClassesToKill.Length <= 0 )
	{
		DebugLog("I have no classes listed to kill!");
	}

	for ( i = 0; i < ClassesToKill.Length; i++ )
	{
		if ( Other.Class == ClassesToKill[i] )
		{
			if ( bDestroyInsteadOfDamage )
			{
				DebugLog("Destroying actor " $ Other);
				Other.Destroy();
			}
			else
			{
				DebugLog("Killing actor " $ Other);
				Other.TakeDamage(MAXINT,None,Location,Velocity,DamageName);
			}

			if ( bSendEventOnKill )
			{
				DebugLog("Emitting kill event " $ Event);
				TriggerEvent(Event,Self,None);
			}
		}
	}
}


defaultproperties
{
	bSendEventOnKill=True
	DamageName=ZonePain

	TriggerType=TT_AnyProximity
}