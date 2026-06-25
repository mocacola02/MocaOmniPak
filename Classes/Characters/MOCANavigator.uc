class MOCANavigator extends MOCAChar;

const MAX_VERIFIES = 5;

var() int MaxPathFails;
var() float ActivationRadius;
var() float ViewDot;
var() float FadeTime;				// Moca: How long to fade out the screen before respawning? Def: 3.0
var() Color CameraFadeColor;		// Moca: What color to use for screen fade? Def: R=0 G=0 B=0

var int FailCount;
var NavigationPoint PrevCandidate;


event Tick(float DeltaTime)
{
	if ( CanISeeHarry(ViewDot, True) )
	{
		HandleHarrySpotted();
	}
}

function HandleHarrySpotted();

function FadeScreen(float Alpha, float FadeT)
{
	local FadeViewController FVC;
	FVC = Spawn(Class'FadeViewController');
	FVC.Init(Alpha, CameraFadeColor.R, CameraFadeColor.G, CameraFadeColor.B, FadeT);
}


//=====================
// Navigation Helpers
//=====================

function UpdateNavP()
{
	navP = NavigationPoint(FindPathToward(destP));
	DebugLog("Updated navP: " $ navP);
}

function bool IsValidNavP()
{
	DebugLog("Is navP valid: " $ navP != destP $ " and " $ navP != None);
	return navP != destP && navP != None;
}

function NavigationPoint GetDestinationTo(optional Vector TargetPos)
{
	if ( VSize(TargetPos) >= 0.1 )
	{
		DebugLog("Finding path to " $ TargetPos);
		return NavigationPoint(FindPathTo(TargetPos));
	}

	DebugLog("Finding random dest");
	return FindRandomDest();
}

function NavigationPoint GetValidDestinationTo(optional Vector TargetPos, optional bool bTryFallback, optional bool bIgnoreFail)
{
	local int CurrAttempts;
	local NavigationPoint WorkingNavP;

	WorkingNavP = GetDestinationTo(TargetPos);

	while ( (WorkingNavP == PrevCandidate || WorkingNavP == None) && CurrAttempts < MAX_VERIFIES )
	{
		CurrAttempts++;

		DebugLog("Attempt #" $ CurrAttempts $ ": We had a duplicate or null navP of " $ WorkingNavP);
		WorkingNavP = GetDestinationTo(TargetPos);
	}

	if ( bTryFallback && (WorkingNavP == PrevCandidate || WorkingNavP == None) )
	{
		DebugLog("Trying one more time, looking for a nearest navP");
		WorkingNavP = GetClosestNavPToPoint(TargetPos);
	}

	if ( WorkingNavP == None && !bIgnoreFail )
	{
		FailCount++;
		DebugLog("We have hit " $ FailCount $ " pathing fails.");

		if ( FailCount > MaxPathFails )
		{
			ErrorMsg(self $ " has failed " $ MaxPathFails $ " pathing checks with bIgnoreFail set to false, closing to avoid an infinite loop hardlock. Try decreasing MOCANavigator's collision radius.");
			return None;
		}
	}
	else
	{
		FailCount = 0;
	}

	PrevCandidate = WorkingNavP;
	DebugLog("Selected " $ WorkingNavP);
	return WorkingNavP;
}

function NavigationPoint GetFurthestNavPFromActor(Actor ActorToCheck)
{
	local NavigationPoint TestNav;
	local NavigationPoint FurthestNav;
	local float TestDistance;
	local float FurthestDistance;
	
	foreach AllActors(class'NavigationPoint', TestNav)
	{
		TestDistance = GetDistanceBetweenActors(TestNav, ActorToCheck);

		if ( FurthestNav == None || ( TestDistance > FurthestDistance ) )
		{
			FurthestNav = TestNav;
			FurthestDistance = TestDistance;
		}
	}

	return FurthestNav;
}

function NavigationPoint GetClosestNavPToPoint(Vector TargetPos)
{
	local NavigationPoint TestNav;
	local NavigationPoint ClosestNav;
	local float TestDistance;
	local float ClosestDistance;
	
	foreach AllActors(class'NavigationPoint', TestNav)
	{
		TestDistance = VSize(TestNav.Location - TargetPos);

		if ( ClosestNav == None || ( TestDistance < ClosestDistance ) )
		{
			ClosestNav = TestNav;
			ClosestDistance = TestDistance;
		}
	}

	return ClosestNav;
}


defaultproperties
{
	ActivationRadius=384.0
	ViewDot=0.35
	FadeTime=3.0
	CameraFadeColor=(R=0,G=0,B=0)

	MaxPathFails=64

	bTiltOnMovement=False

	bAdvancedTactics=True
	SightRadius=2048.0
}