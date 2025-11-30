class MOCALastValidStateTestTrigger extends MOCATrigger;

function Activate( actor Other, pawn Instigator )
{
    ProcessTrigger();
}

function ProcessTrigger ()
{
    if ( PlayerHarry != None )
	{
		PlayerHarry.CM("TESTING! OUR LAST VALID STATE WAS " $ string(PlayerHarry.LastValidState));
	}
}
