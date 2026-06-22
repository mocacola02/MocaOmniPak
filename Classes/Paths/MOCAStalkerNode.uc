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
		local bool bIsOtherFacing,bPlayCanSeeMe;
		bIsOtherFacing = IsOtherFacing(PlayerHarry,MinDot);
		bPlayCanSeeMe = PlayerCanSeeMe();
		//Log(string(bIsOtherFacing)$" | "$string(bPlayCanSeeMe));
		// If Harry is facing self, become blocked
		bBlocked = IsOtherFacing(PlayerHarry,MinDot) && PlayerCanSeeMe();
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
		Texture = Texture'MocaOmniResources.icon_bracken_path_default';
	}
	else
	{
		Texture = Texture'MocaOmniResources.icon_bracken_path_green';
	}
}


/////////////////////
// Helper Functions
/////////////////////

function float GetDistanceBetweenActors(Actor A, Actor B)
{
	return VSize(A.Location - B.Location);
}

function bool IsOtherFacing(Actor Other, float MinDotProduct)
{
	local float DotProduct;
	DotProduct = Vector(Other.Rotation) Dot Normal(Location - Other.Location);

	return DotProduct > MinDotProduct;
}


defaultproperties
{
	MinDot=0.25
	RequiredDistance=2000

	bSpecialCost=True
	bStatic=False
	Texture=Texture'MocaOmniResources.icon_bracken_path_green'
}