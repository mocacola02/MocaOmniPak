//================================================================================
// MOCAChar
//================================================================================

class MOCAChar extends HChar;

var(MOCAMovement) bool bTiltOnMovement;
var(MOCAMovement) float MaxTravelDistance;

var(MOCACombat) int HitsToKill;

var int HitsTaken;

var Vector HomeLocation;
var Vector LastHarryLocation;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Get a default prevNavP
	prevNavP = Level.NavigationPointList;

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

function bool IsCloseToHome(float DistanceThreshold)
{
	return VSize(Location - HomeLocation ) < DistanceThreshold;
}

function bool IsHarryNear(optional float TargetDistance)
{
	return GetDistanceFromHarry() <= TargetDistance;
}

function float GetDistanceFromHarry()
{
	return MOCAHelpers.GetDistanceBetweenActors(Self,PlayerHarry);
}

function float GetDistanceFromSelf(Actor ActorToCheck)
{
	return MOCAHelpers.GetDistanceBetweenActors(Self, ActorToCheck);
}

function Vector GetNearbyNavPInView(float MaxRange)
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


//////////
// Sight
//////////

function bool CanHarrySeeMe(float MinDot)
{
	return MOCAHelpers.IsFacingOther(PlayerHarry,Self,MinDot) && PlayerCanSeeMe();
}

function bool CanISeeHarry(float MinDot, optional bool bRememberLocation)
{
	if ( PlayerCanSeeMe() && MOCAHelpers.IsFacingOther(Self,PlayerHarry,MinDot) && Abs(PlayerHarry.Location.Z - Location.Z) <= 50.0 )
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


//////////
// Magic
//////////

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
	// If we're using MOCAharry (required for new spell system) AND we're vulnerable to the matching spell class
	if ( PlayerHarry.IsA('MOCAharry') && eVulnerableToSpell == DetermineSpellType(Spell.Class) )
	{
		// React to spell
		ProcessSpell();
		return True;
	}

	return False;
}

function ESpellType DetermineSpellType(class<baseSpell> TestSpell)
{
	local int i;
	local MOCAharry MocaPlayer;

	MocaPlayer = MOCAharry(PlayerHarry);

	// For each spell in our spell map
	for ( i = 0; i < MocaPlayer.SpellMapping.Length; i++ )
	{
		// If our spell class matches the spell map entry
		if ( MocaPlayer.SpellMapping[i].SpellToAssign == TestSpell )
		{
			// Return the proper spell slot
			return MocaPlayer.SpellMapping[i].SpellSlot;
		}
	}

	// Default to no spell otherwise
	return SPELL_None;
}

function ProcessSpell(); // Define in child classes.


////////////////////
// Misc. Functions
////////////////////

function EnterErrorMode(string ErrorMessage)
{
	ErrorMsg("THIS IS A MOCA OMNI PAK ERROR, DO NOT REPORT TO M212! Error Message: "$ErrorMessage);
}

function EnableTurnTo(Actor TurnTarget)
{
	bTurnTo_FollowActor = True;
	TurnTo_TargetActor = TurnTarget;
	MakeTurnToPermanentController();
}

function DisableTurnTo()
{
	bTurnTo_FollowActor = False;
	TurnTo_TargetActor = None;
	DestroyTurnToPermanentController();
}

function bool ShouldDie()
{
	return HitsTaken >= HitsToKill && HitsToKill > 0;
}


defaultproperties
{
	MaxTravelDistance=1024.0
	bTiltOnMovement=True
}