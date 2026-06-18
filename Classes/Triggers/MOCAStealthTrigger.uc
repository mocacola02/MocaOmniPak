//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var() float TimeOutDuration;	// Moca: How long to deactivate trigger after activation. Def: 4.0

//=====================
// Default Properties
//=====================

defaultproperties
{
	TimeOutDuration=4.0

	CollisionHeight=35
	CollisionRadius=42

	CollideType=CT_Box
}    