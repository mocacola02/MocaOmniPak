//================================================================================
// MOCAPawn.
//================================================================================

//Mostly to categorize. May get additional functionality later

class MOCAPawn extends HPawn;

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
    Super.HandleSpellFlipendo(spell,vHitLocation);
    if (eVulnerableToSpell == SPELL_Flipendo)
    {
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
        return True;
    }
    else
    {
        return False;
    }
}