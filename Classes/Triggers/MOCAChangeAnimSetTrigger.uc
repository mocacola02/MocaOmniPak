class MOCAChangeAnimSetTrigger extends MOCATrigger;

var() harry.enumHarryAnimSet NewAnimSet;	// Moca: Which anim set to use? Def: HARRY_ANIM_SET_MAIN


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// Set new anim set
	PlayerHarry.HarryAnimSet = NewAnimSet;
}