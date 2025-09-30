//================================================================================
// MOCAPawn.
//================================================================================

class MOCAPawn extends HPawn;

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