//================================================================================
// MOCAPawn.
//================================================================================

class MOCAPawn extends HPawn;

var() bool bFloatingActor;		// Moca: Is this actor a floating actor? Use this for stuff like floating torches. Def: False

var() float RotationSpeed;		// Moca: How fast should the actor rotate on its Yaw axis (aka turning left or right)? Def: 128.0
var() float BobSpeed;			// Moca: How fast should the floating actor bob up and down? Def: 128.0
var() float BobIntensity;		// Moca: How intense should the bobbing be? Aka how far up and down does it go? Def: 1.0

var float BobTime;
var Vector StartingLocation;

event PreBeginPlay()
{
	Super.PreBeginPlay();

	StartingLocation = Location;
}

event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if(bFloatingActor)
	{
		DoBob(DeltaTime);
	}
}

function EnableTurnTo(actor TurnTarget)
{
    bTurnTo_FollowActor = true;
    TurnTo_TargetActor = TurnTarget;
    MakeTurnToPermanentController();
}

function DisableTurnTo()
{
	bTurnTo_FollowActor = false;
	TurnTo_TargetActor = None;
	DestroyTurnToPermanentController();
}

function DoBob(float DeltaTime)
{
	local float Offset;
	local Rotator NewRotation;

	BobTime += DeltaTime * BobSpeed * 2 * Pi;
	Offset = sin(BobTime) * BobIntensity;

	NewRotation.Yaw = Rotation.Yaw + (RotationSpeed * DeltaTime);

	SetLocation(StartingLocation + vect(0,0,1) * Offset);
	SetRotation(NewRotation);
}

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

function bool HandleSpell (optional baseSpell spell, optional Vector vHitLocation)
{
    if (PlayerHarry.IsA('MOCAharry'))
    {
        if (eVulnerableToSpell == DetermineSpellType(spell.Class))
        {
            Log("Spell hit and match on " $ string(self));
            ProcessSpell();
            return true;
        }
    }

    return false;
}

function ProcessSpell()
{
    //Define in child classes.
}

function ESpellType DetermineSpellType (class<baseSpell> TestSpell)
{
    local int i;
    local MOCAharry MocaPlayerHarry;

    MocaPlayerHarry = MOCAharry(PlayerHarry);

    for (i = 0; i < ArrayCount(MocaPlayerHarry.SpellMapping); i++)
    {
        if (MocaPlayerHarry.SpellMapping[i].SpellToAssign == TestSpell)
        {
            Log("Found mapping at index " $ i $ " with slot " $ MocaPlayerHarry.SpellMapping[i].SpellSlot);
            return MocaPlayerHarry.SpellMapping[i].SpellSlot;
        }
    }

    Log("No mapping found for " $ string(TestSpell));
    return SPELL_None;
}

defaultproperties
{
	RotationSpeed=3000.0
	BobIntensity=8.0
	BobSpeed=0.5
}