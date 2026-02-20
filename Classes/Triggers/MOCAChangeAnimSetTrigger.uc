class MOCAChangeAnimSetTrigger extends MOCATrigger;

var() harry.enumHarryAnimSet NewAnimSet;


///////////
// Events
///////////

event Activate(Actor Other, Pawn Instigator)
{
	if ( Other == PlayerHarry )
	{
		ProcessTrigger();
	}
}


///////////////////
// Main Functions
///////////////////

function ProcessTrigger()
{
	PlayerHarry.HarryAnimSet = NewAnimSet;
}