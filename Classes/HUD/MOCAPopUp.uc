//=============================================================================
// MOCAPopUp.
//=============================================================================
class MOCAPopUp extends basePopup;

const BASE_X = 1024.0;
const BASE_Y = 768.0;

struct Vector2
{
	var float X;
	var float Y;
};


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