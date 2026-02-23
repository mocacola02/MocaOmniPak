//================================================================================
// MOCAPawn.
//================================================================================
class MOCAPawn extends HPawn;

var(MOCAFloating) bool bFloatingActor;	// Moca: Is this actor a floating actor? Use this for stuff like floating torches. Uses RotationSpeed, BobSpeed, & BobIntensity.
var(MOCAFloating) float RotationSpeed;	// Moca: How fast to rotate if bFloatingActor
var(MOCAFloating) float BobSpeed;		// Moca: How fast to bob up and down if bFloatingActor
var(MOCAFloating) float BobIntensity;	// Moca: How deep to bob up and down if bFloatingActor

var float BobTime;		// Current bob time
var Vector HomeLocation;// Home location


///////////
// Events
///////////

event PreBeginPlay()
{
	Super.PreBeginPlay();
	// Set home location
	HomeLocation = Location;
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	// If we should float, do bob
	if ( bFloatingActor )
	{
		DoBob(DeltaTime);
	}
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
	// Crash game with error message
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

function DoBob(float DeltaTime)
{
	local float Offset;
	local Rotator NewRotation;

	// Determine our bob time so we can calculate our offset
	BobTime += DeltaTime * BobSpeed * 2 * Pi;
	// Set offset multiplied by the intensity
	Offset = Sin(BobTime) * BobIntensity;

	// Set our target rotation
	NewRotation.Yaw = Rotation.Yaw + (RotationSpeed * DeltaTime);

	// Set bob location & rotation
	SetLocation(Home + Vect(0,0,1) * Offset);
	SetRotation(NewRotation);
}


defaultproperties
{
	RotationSpeed=3000.0
	BobIntensity=8.0
	BobSpeed=0.5
}