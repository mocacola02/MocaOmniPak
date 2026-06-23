//================================================================================
// MOCAChar.
//================================================================================
class MOCAChar extends HChar;

var() bool bTiltOnMovement;		// Should we tilt with movement like Pawns usually do? Def: True
var(MOCADebug) bool bDebugLogging;
var() int HitsToKill;			// How many hits does it take to kill me? If 0, can't die. Def: 0
var() float MaxTravelDistance;	// How far can we travel from home? Def: 1024.0

var int HitsTaken;				// Current number of hits taken

var Vector HomeLocation;		// Home location
var Vector LastHarryLocation;	// Location we last saw Harry at


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Get a default LastNavP
	LastNavP = Level.NavigationPointList;

	// Set HomeLocation
	HomeLocation = Location;
}

event AlterDestination()
{
	Super.AlterDestination();

	// If not bTiltOnMovement, disable the rotation causing tilts
	if ( !bTiltOnMovement )
	{
		DesiredRotation.Pitch = 0.0;
	}
}


/////////////
// Distance
/////////////

function bool IsCloseToHome(optional float DistanceThreshold)
{
	if ( DistanceThreshold <= 0.0 )
	{
		DistanceThreshold = MaxTravelDistance;
	}
	return VSize( Location - HomeLocation ) < DistanceThreshold;
}

function float GetDistanceBetweenActors(Actor A, Actor B)
{
	return VSize(A.Location - B.Location);
}

function bool IsHarryNear(optional float TargetDistance)
{
	if ( TargetDistance <= 0.0 )
	{
		TargetDistance = 256.0;
	}
	
	return GetDistanceFromHarry() <= TargetDistance;
}

function float GetDistanceFromHarry()
{
	return GetDistanceBetweenActors(Self,PlayerHarry);
}

function float GetDistanceFromSelf(Actor ActorToCheck)
{
	return GetDistanceBetweenActors(Self, ActorToCheck);
}

function NavigationPoint GetNearestNavP()
{
	local float Distance, ClosestDist;
	local NavigationPoint TestNav, BestNav;
	local Vector DirectionToNav, ForwardDirection;

	// Default to something high
	ClosestDist = 999999.0;

	// Get forward direction
	ForwardDirection = Vector(Rotation);
	
	// For each NavigationPoint in level
	foreach AllActors(class'NavigationPoint', TestNav)
	{
		// Get direction to the tested navigation point
		DirectionToNav = Normal(TestNav.Location - Location);
		// Get distance between self and tested nav p
		Distance = GetDistanceFromSelf(TestNav);

		// If distance is larger than our recorded ClosestDist
		if ( Distance < ClosestDist )
		{
			// Set new distance and best nav
			ClosestDist = Distance;
			BestNav = TestNav;
		}
	}

	// Return our best nav
	return BestNav;
}

function NavigationPoint GetNearbyNavPInView(float MaxRange)
{
	local NavigationPoint TestNav, BestNav;
	local Vector DirectionToNav, ForwardDirection;
	local float Distance, DotProduct, ClosestDist;

	// Default to something high
	ClosestDist = 999999.0;

	// Get forward direction
	ForwardDirection = Vector(Rotation);
	
	// For each NavigationPoint in level
	foreach AllActors(class'NavigationPoint', TestNav)
	{
		// Get direction to the tested navigation point
		DirectionToNav = Normal(TestNav.Location - Location);
		// Get distance between self and tested nav p
		Distance = GetDistanceFromSelf(TestNav);
		// Get dot product from direction to nav & forward direction
		DotProduct = DirectionToNav Dot ForwardDirection;

		// If our tested distance doesn't exceed MaxRange AND distance is larger than our recorded ClosestDist AND we're facing the test nav p
		if ( Distance <= MaxRange && Distance < ClosestDist && DotProduct > 0.0 )
		{
			// Set new distance and best nav
			ClosestDist = Distance;
			BestNav = TestNav;
		}
	}

	// Return our best nav
	return BestNav;
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


//////////
// Sight
//////////

function bool CanHarrySeeMe(float MinDot)
{
	return IsFacingOther(PlayerHarry,Self,MinDot) && PlayerCanSeeMe();
}

function bool IsFacingOther(Actor SourceActor, Actor Other, float MinDot)
{
	local float DotProduct;

	DotProduct = Vector(SourceActor.Rotation) Dot Normal(Other.Location - SourceActor.Location);

	return DotProduct > MinDot;
}

function bool CanISeeHarry(float MinDot, optional bool bRememberLocation)
{
	// If Harry can see us and we're facing him and we're within 50 units on Z (up & down)
	if ( PlayerCanSeeMe() && IsFacingOther(Self,PlayerHarry,MinDot) && Abs(PlayerHarry.Location.Z - Location.Z) <= 50.0 )
	{
		if ( bRememberLocation )
		{
			// If we want to remember his location, set it
			LastHarryLocation = PlayerHarry.Location;
		}

		return True;
	}

	return False;
}

function bool FastViewCheck(Actor TargetActor)
{
	return FastTrace(TargetActor.Location, Location);
}


//////////
// Magic
//////////

// Redirect all stock handle spell functions to our new generic HandleSpell function
function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDiffindo (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellEcto (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellLumos (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellSkurge (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellSpongify (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDuelRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDuelMimblewimble (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDuelExpelliarmus (optional baseSpell spell, optional Vector vHitLocation)
{
	return HandleSpell(spell,vHitLocation);
}

function bool HandleSpell(optional baseSpell Spell, optional Vector HitLocation)
{
	if ( eVulnerableToSpell == DetermineSpellType(Spell.Class) )
	{
		// React to spell
		ProcessSpell();
		return True;
	}

	return False;
}

function ESpellType DetermineSpellType(class<baseSpell> TestSpell)
{
	if ( PlayerHarry.IsA('MOCAharry') )
	{
		return MOCAharry(PlayerHarry).GetSpellType(TestSpell);
	}
	else
	{
		return TestSpell.Default.SpellType;
	}
}

function ProcessSpell(); // Define in child classes.


////////////////////
// Misc. Functions
////////////////////

function PushError(string ErrorMessage)
{
	ErrorMsg("THIS IS A MOCA OMNI PAK ERROR, DO NOT REPORT TO M212! Error Message: "$ErrorMessage);
}

function EnableTurnTo(Actor TurnTarget)
{
	// Enable turn to and set turn target
	bTurnTo_FollowActor = True;
	TurnTo_TargetActor = TurnTarget;
	MakeTurnToPermanentController();
}

function DisableTurnTo()
{
	// Disable turn to
	bTurnTo_FollowActor = False;
	TurnTo_TargetActor = None;
	DestroyTurnToPermanentController();
}

function bool ShouldDie()
{
	// If we've taken enough hits and HitsToKill isn't 0
	return HitsTaken >= HitsToKill && HitsToKill > 0;
}

function bool DoesActorExist(Class<Actor> ActorToCheck)
{
	local Actor A;
	
	foreach AllActors(ActorToCheck, A)
	{
		return True;
	}

	return False;
}

function DebugLog(string Msg)
{
	if ( bDebugLogging )
	{
		Log(self $ ": " $ Msg);
	}
}


defaultproperties
{
	AmbientGlow=48.0
	MaxTravelDistance=1024.0
	bTiltOnMovement=True
}