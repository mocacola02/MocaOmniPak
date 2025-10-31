class MOCAKillTrigger extends MOCATrigger;

var() array<Actor> ActorsToKill;

function Activate(actor Other, pawn Instigator)
{
	super.Activate(Other, Instigator);

	if (ActorsToKill.Length <= 0)
	{
		Log("No actors to kill set!");
		Destroy();
	}

	local int i;
	local Actor A;
	
	foreach AllActors(class'Actor', A)
	{
		for (i=0; i < ActorsToKill.Length; i++)
		{
			if (A == ActorsToKill[i])
			{
				A.Destroy();
			}
		}
	}
}