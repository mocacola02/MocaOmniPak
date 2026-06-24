class MOCAProp extends Actor;

var(MOCADisplay) float DrawDistance; // Moca: From how far away can the actor be seen? If 0.0, this isn't applied. Disable bStatic in the Advanced properties for this to work! Def: 0.0
var(MOCADebug) bool bDebugLogging;

var harry PlayerHarry;


event PostBeginPlay()
{
	super.PostBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);

	if (DrawDistance <= 0)
	{
		return;
	}
	
	GetDetail();
	SetTimer(3.0,true);
}

event Timer()
{
	super.Timer();

	GetDetail();
}

event Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (DrawDistance <= 0)
	{
		return;
	}

	if (VSize(Location - PlayerHarry.Location) > DrawDistance)
	{
		if (!bHidden)
		{
			bHidden = True;
		}
	}
	else if (bHidden)
	{
		bHidden = False;
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


function GetDetail()
{
	switch(PlayerHarry.ObjectDetail)
	{
		case ObjectDetailVeryHigh: break;
		case ObjectDetailHigh: DrawDistance *= 0.95; break;
		case ObjectDetailMedium: DrawDistance *= 0.9; break;
		case ObjectDetailLow: DrawDistance *= 0.8; break;
		case ObjectDetailVeryLow: DrawDistance *= 0.7; break;
		default: break;
	}
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
	DrawDistance=0.0

	bStatic=True

	bBlockActors=True
	bBlockCamera=True
	bBlockPlayers=True
	bCollideActors=True
	bCollideWorld=True

	AmbientGlow=32
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'skSundialMesh'
}