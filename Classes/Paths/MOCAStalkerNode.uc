//=============================================================================
// MOCAStalkerNode.
//=============================================================================
class MOCAStalkerNode extends PathNode;

var() bool bPerformanceMode;	// Moca: Makes node check only once or twice a second instead of every tick
var() float MinDot;				// Moca: Minimum dot product required to be seen
var() float RequiredDistance;	// Moca: Required proximity to be triggered as seen

var harry PlayerHarry;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bPerformanceMode )
	{
		local float TimerRate;
		TimerRate = RandRange(0.334,0.667);
		SetTimer(TimerRate,True);
		Disable('Tick');
	}
}

event Tick(float DeltaTime)
{
	CheckForHarry();
}

event Timer()
{
	CheckForHarry();
}


///////////////////
// Main Functions
///////////////////

function CheckForHarry()
{
	if ( MOCAHelpers.GetDistanceBetweenActors(Self,PlayerHarry) < RequiredDistance )
	{
		bBlocked = MOCAHelpers.IsFacingOther(PlayerHarry,Self,MinDot);
	}
	else
	{
		bBlocked = False;
	}

	SetTexture();
}

function SetRequiredDistance(float NewDistance)
{
	if ( NewDistance <= 0.0 )
	{
		NewDistance = 1.0;
	}

	RequiredDistance = NewDistance;
}

function SetTexture()
{
	if ( bBlocked )
	{
		Texture = Texture'MocaTexturePak.ICO_BrackenPath';
	}
	else
	{
		Texture = Texture'MocaTexturePak.ICO_BrackenPathGreen';
	}
}


defaultproperties
{
	MinDot=0.25
	RequiredDistance=2000

	bSpecialCost=True
	bStatic=False
	Texture=Texture'MocaTexturePak.ICO_BrackenPathGreen'
}