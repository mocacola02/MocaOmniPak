//================================================================================
// MOCAPawn.
//================================================================================

class MOCAPawn extends HPawn;

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellFlipendo(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Flipendo)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellAlohomora(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Alohomora)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellDiffindo (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellDiffindo(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Diffindo)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellEcto (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellEcto(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Ecto)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellLumos (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellLumos(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Lumos)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellRictusempra(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Rictusempra)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellSkurge (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellSkurge(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Skurge)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
}

function bool HandleSpellSpongify (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellSpongify(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Spongify)
    {
        ProcessSpell();
        return True;
    }
    else
    {
        return False;
    }
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
        else
        {
            return False;
        }
    }
    else
    {
        return false;
    }
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