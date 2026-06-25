//=============================================================================
// MOCAStalkerNode.
//=============================================================================
class MOCAStalkerNode extends PathNode;

var() float MinDot;
var() float RequiredDistance;

var harry PlayerHarry;


//=========
// Events
//=========

event PostBeginPlay()
{
	PlayerHarry = harry(Level.PlayerHarryActor);

	// Probably not necessary, but I'm gonna randomize update rate so
	// everything doesn't tick all at once in case you have a ton of these
	SetTimer(RandRange(0.334, 0.5), True);
}

event Timer()
{
	if ( VSize(PlayerHarry.Location - Location) <= RequiredDistance )
	{
		bBlocked = IsSeen();

		if ( bBlocked )
		{
			Texture = Texture'MocaOmniResources.icon_bracken_path_default';
		}
		else
		{
			Texture = MapDefault.Texture;
		}
	}
}


//================
// View Handling
//================

function bool IsSeen()
{
	return PlayerCanSeeMe() && IsFacingOther(PlayerHarry, self, MinDot) && Abs(PlayerHarry.Location.Z - Location.Z) <= 50.0;
}

function bool IsFacingOther(Actor SourceActor, Actor Other, float DotMin)
{
	local float DotProduct;

	DotProduct = Vector(SourceActor.Rotation) Dot Normal(Other.Location - SourceActor.Location);

	return DotProduct > DotMin;
}


//=================
// State Handling
//=================

function EnableNode()
{
	RequiredDistance = MapDefault.RequiredDistance;
}

function DisableNode()
{
	RequiredDistance = 0.0;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	MinDot=0.35
	RequiredDistance=2000.0

	bSpecialCost=True
	bStatic=False
	Texture=Texture'MocaOmniResources.icon_bracken_path_green'
}