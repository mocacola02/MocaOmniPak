//=============================================================================
// MOCAPopUp.
//=============================================================================
class MOCAPopUp extends basePopup;


event Timer()
{
	OnTimeout();
}

function OnTimeout()
{
	baseHUD(PlayerHarry.myHUD).DestroyPopup();
}


defaultproperties
{
	LifeSpan=0
}