class MOCAKillTrigger extends MOCATrigger;

var() array<class<HPawn>> ClassesToExclude; // Moca: List of HPawn classes that should not be killed if triggered by them
var() bool bSendEventOnKill; // Moca: Should we broadcast Event after destroying an actor
var() bool bKillHarry; // Moca: Should the kill trigger kill Harry
var() name PainType; // Moca: What type of pain to inflict? Use ZonePain for a kill zone style death. See harry's class for other DamageTypes. Default: ZonePain

function Activate(actor Other, pawn Instigator)
{
	super.Activate(Other, Instigator);

	if (Other.IsA('harry') && bKillHarry)
	{
		KillOther(Other,Instigator);
	}

	if (ClassesToExclude.Length > 0)
	{
		local int i;

		for(i=0; i < ClassesToExclude.Length; i++)
		{
			local name NameOfClass;
			NameOfClass = ClassesToExclude[i].Default.Name;

			if (Other.IsA(NameOfClass))
			{
				Log(string(Other) $ " is in our excluded class list for class " $ NameOfClass);
				return;
			}

			KillOther(Other,Instigator);
		}
	}
	else
	{
		KillOther(Other,Instigator);
	}
}

function KillOther(Actor Other, Pawn Instigator)
{
	Log(string(self) $ " is killing " $ string(Other));
	Other.TakeDamage(MaxInt,Instigator,Location,Velocity,PainType);

	if (bSendEventOnKill)
	{
		TriggerEvent(Event,self,Instigator);
	}
}

defaultproperties
{
	bSendEventOnKill=True
	bKillHarry=True
	PainType=ZonePain
}