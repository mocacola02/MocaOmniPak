//=============================================================================
// MOCAStalkerNode.
//=============================================================================
class MOCAStalkerNode extends PathNode;

var() bool bPerformanceMode;	// Moca: Makes node check only once or twice a second instead of every tick. Def: False
var() float MinDot;				// Moca: Minimum dot product required to be seen. Def: 0.25
var() float RequiredDistance;	// Moca: Required proximity to be triggered as seen. Def: 2000.0

var harry PlayerHarry;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If performance mode, use manual timer and disable tick
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
	// If Harry is near
	if ( GetDistanceBetweenActors(Self,PlayerHarry) < RequiredDistance )
	{
		// If Harry is facing self, become blocked
		bBlocked = IsFacingOther(PlayerHarry,Self,MinDot);
	}
	// Otherwise, don't be blocked
	else
	{
		bBlocked = False;
	}

	SetTexture();
}

function SetRequiredDistance(float NewDistance)
{
	// Set required distance to 1.0 if it is 0.0
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


/////////////////////
// Helper Functions
/////////////////////

function float GetDistanceBetweenActors(Actor A, Actor B)
{
	return VSize(A.Location - B.Location);
}

function bool IsFacingOther(Actor SourceActor, Actor Other, float MinDotProd)
{
	local float DotProduct;
	DotProduct = Vector(Rotation) Dot Normal(Other.Location - Location);
	return DotProduct > MinDotProd;
}


defaultproperties
{
	MinDot=0.25
	RequiredDistance=2000

	bSpecialCost=True
	bStatic=False
	Texture=Texture'MocaTexturePak.ICO_BrackenPathGreen'
}