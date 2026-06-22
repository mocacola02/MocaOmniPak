//================================================================================
// MOCAharry.
//================================================================================
class MOCAharry extends harry;

//= General Exports =//
var() bool bSaveOnLoad;		// Moca: Should the game save when we load in? Def: False

//= Magic Exports =//

struct SpellMap
{
	var() const editconst ESpellType SpellSlot;
	var() class<baseSpell> SpellClass;
	var() ESpellType SpellToReplicate;
};

var(MOCAMagic) bool bUseMOCAWand;
var(MOCAMagic) Class<SpellCursor> SpellCursorClass;
var(MOCAMagic) SpellMap SpellMapping[28];

//= Debug Vars =//
var(MOCADebug) bool bDebugLogging;

//= Respawn Vars =//
var Vector RespawnLocation;		// Location to "respawn" harry at
var Rotator RespawnRotation;	// Rotation to set on "respawn"


//=========
// Events
//=========

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Set default respawn position (aka starting position)
	SetRespawnPosition(Location, Rotation.Yaw);

	SpellCursor.Destroy();
	SpellCursor = Spawn(SpellCursorClass);

	if ( SpellCursor.IsA('MOCASpellCursor') )
	{
		MOCASpellCursor(SpellCursor).bDebugLogging = bDebugLogging;
	}

	// If we're set to save on load, then save
	if ( bSaveOnLoad )
	{
		SaveGame();
	}
}

event PreClientTravel()
{
	DebugLog("Resetting to baseWand so we don't break a non-MOCAharry map");
	SetWeaponBySlot(4);
}

event TravelPostAccept()
{
    local Weapon weap;
	local MOCAWand Mweap;	// Mweap. Mweap. Job's gone.

	Super.TravelPostAccept();

	if ( FindInventoryType(Class'MOCAWand') == None )
	{
		// Spawn MOCAWand and make it our weapon
		weap = Spawn(Class'MOCAWand', self);
		weap.BecomeItem();
		AddInventory(weap);

		weap.WeaponSet(self);
		weap.GiveAmmo(self);

		DebugLog("We didn't have MOCAWand, so we spawned one: " $ weap);
	}
	else
	{
		DebugLog("We already have a MOCAWand, so we're not spawning one");
	}

	if ( bUseMOCAWand )
	{
		SetWeaponBySlot(2);
		UpdateSpellbook();
	}
}

event Touch(Actor Other)
{
	Super.Touch(Other);
	PickupActor(Other);
}


//============
// Magic SFX
//============

function StartAimSoundFX()
{
	if ( bInDuelingMode && (CurrentDuelSpell == 2) )
	{
		return;
	}

	PlaySound(Sound'Spell_aim',SLOT_Misc);

	if ( bInDuelingMode && (CurrentDuelSpell == 1) )
	{
		PlaySound(Sound'Dueling_MIM_buildup',SLOT_Interact);
	}
	else
	{
		PlaySound(Sound'spell_loop_nl',SLOT_Interact,,,,,,True);
	}
}

function StopAimSoundFX()
{
	if ( bInDuelingMode && (CurrentDuelSpell == 1) )
	{
		StopSound(Sound'Dueling_MIM_buildup',SLOT_Interact);
	}
	else
	{
		StopSound(Sound'Spell_aim',SLOT_Misc,2.5);
		StopSound(Sound'spell_loop_nl',SLOT_Interact,0.75);
	}
}

function PlaySpellCastSound (ESpellType SpellType)
{
	local Sound SpellSound;
	local class<baseSpell> CurrentSpell;
	local class<MOCAbaseSpell> CurrentMSpell;

	CurrentSpell = baseWand(Weapon).CurrentSpell;

	if ( CurrentSpell != None )
	{
		if ( CurrentSpell.IsA('MOCAbaseSpell') )
		{
			CurrentMSpell = class<MOCAbaseSpell>(CurrentSpell);
			SpellSound = CurrentMSpell.Default.CastSound;

			if ( SpellSound != None )
			{
				PlaySound(SpellSound,SLOT_None);
			}
		}
	}
	else
	{
		Super.PlaySpellCastSound(SpellType);
	}
}


//==================
// Stock Overrides
//==================

function AddToSpellBook (Class<baseSpell> spellClass)
{
	local ESpellType ST;
	ST = GetSpellType(spellClass);

	if ( ST == SPELL_None )
	{
		ST = spellClass.Default.SpellType;
	}

	if ( ST != SPELL_None && (ST < MAX_NUM_SPELLS) && (SpellBook[ST] == None) )
	{
		SpellBook[ST] = spellClass;
	}
}

function SetNewMesh()
{
	// If harry, goyle
	if ( bIsGoyle && Mesh == MapDefault.Mesh )
	{
		Mesh = SkeletalMesh'skGoyleMesh';
		DrawScale = 1.15;
	}
	// If goyle, harry
	if ( !bIsGoyle && Mesh == SkeletalMesh'skGoyleMesh' )
	{
		Mesh = MapDefault.Mesh;
		DrawScale = 1.0;
	}
}

// TODO: Check if this is actually needed
function PickupActor(Actor Other)
{
	Super.PickupActor(Other);
	StopAimSoundFX();
}


//==========
// Helpers
//==========

function UpdateSpellbook()
{
	local int i;

	for ( i = 0; i < ArrayCount(SpellMapping); i++ )
	{
		local class<baseSpell> BS;
		BS = SpellMapping[i].SpellClass;

		if ( BS != None )
		{
			AddToSpellBook(BS);
			DebugLog(self $ " added spell " $ BS $ " of type " $ BS.Default.SpellType $ " to spellbook");
		}
	}
}

function ESpellType GetSpellType (class<baseSpell> TestSpell)
{
    local int i;

    for (i = 0; i < ArrayCount(SpellMapping); i++)
    {
        if (SpellMapping[i].SpellClass == TestSpell)
        {
            DebugLog("Found mapping at index " $ i $ " with slot " $ SpellMapping[i].SpellSlot);
            return SpellMapping[i].SpellSlot;
        }
    }

    DebugLog("No mapping found for " $ TestSpell);
    return SPELL_None;
}

function class<baseSpell> GetSpellClass (ESpellType SpellType)
{
    local int i;

    for (i = 0; i < ArrayCount(SpellMapping); i++)
    {
        if (SpellMapping[i].SpellSlot == SpellType)
        {
            return SpellMapping[i].SpellClass;
        }
    }

    return None;
}

function ESpellType GetSpellToReplicate (class<baseSpell> TestSpell)
{
    local int i;

    for (i = 0; i < ArrayCount(SpellMapping); i++)
    {
        if (SpellMapping[i].SpellClass == TestSpell)
        {
            DebugLog("Found mapping at index " $ i $ " with slot " $ SpellMapping[i].SpellToReplicate);
            return SpellMapping[i].SpellToReplicate;
        }
    }

    DebugLog("No mapping found for " $ TestSpell);
    return SPELL_None;
}

function SetWeaponBySlot(byte Slot)
{
	SwitchWeapon(Slot);
	ChangedWeapon();
	Weapon.GiveAmmo(self);
}

function SetRespawnPosition(Vector NewLocation, optional float NewYaw)
{
	local Rotator NewRotation;

	RespawnLocation = NewLocation;

	NewRotation.Yaw = NewYaw;
	RespawnRotation = NewRotation;
}

function SetAnimSet(enumHarryAnimSet NewSet)
{
	HarryAnimSet = NewSet;
}

function ScreenFade(float TargetOpacity, float FadeOutTime)
{
	local FadeViewController CamFade;
	CamFade = Spawn(Class'FadeViewController');
	CamFade.Init(TargetOpacity,0,0,0,FadeOutTime);
}


//========
// Debug
//========

function DebugLog(string Msg)
{
	if ( bDebugLogging )
	{
		Log(self $ ": " $ Msg);
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bUseMOCAWand=True
	SpellCursorClass=Class'MOCASpellCursor'

     SpellMapping(1)=(SpellSlot=SPELL_Alohomora,SpellClass=Class'HGame.spellAlohomora')
     SpellMapping(2)=(SpellSlot=SPELL_Incendio)
     SpellMapping(3)=(SpellSlot=SPELL_LocomotorWibbly,SpellClass=Class'MocaOmniPak.MOCAspellGlacius')
     SpellMapping(4)=(SpellSlot=SPELL_Lumos,SpellClass=Class'HGame.spellLumos')
     SpellMapping(5)=(SpellSlot=SPELL_Nox)
     SpellMapping(6)=(SpellSlot=SPELL_PetrificusTotalus)
     SpellMapping(7)=(SpellSlot=SPELL_WingardiumLeviosa)
     SpellMapping(8)=(SpellSlot=SPELL_Verdimillious)
     SpellMapping(9)=(SpellSlot=SPELL_Vermillious)
     SpellMapping(10)=(SpellSlot=SPELL_Flintifores)
     SpellMapping(11)=(SpellSlot=SPELL_Reparo)
     SpellMapping(12)=(SpellSlot=SPELL_MucorAdNauseum)
     SpellMapping(13)=(SpellSlot=SPELL_Flipendo,SpellClass=Class'HGame.spellFlipendo')
     SpellMapping(14)=(SpellSlot=SPELL_Ectomatic)
     SpellMapping(15)=(SpellSlot=SPELL_Avifores)
     SpellMapping(16)=(SpellSlot=SPELL_FireCracker)
     SpellMapping(17)=(SpellSlot=SPELL_Transfiguration)
     SpellMapping(18)=(SpellSlot=SPELL_WingSustain)
     SpellMapping(19)=(SpellSlot=SPELL_Diffindo,SpellClass=Class'HGame.spellDiffindo')
     SpellMapping(20)=(SpellSlot=SPELL_Skurge,SpellClass=Class'HGame.spellSkurge')
     SpellMapping(21)=(SpellSlot=SPELL_Spongify,SpellClass=Class'HGame.spellSpongify')
     SpellMapping(22)=(SpellSlot=SPELL_Rictusempra,SpellClass=Class'HGame.spellRictusempra')
     SpellMapping(23)=(SpellSlot=SPELL_Ecto)
     SpellMapping(24)=(SpellSlot=SPELL_Fire)
     SpellMapping(25)=(SpellSlot=SPELL_DuelRictusempra,SpellClass=Class'HGame.spellDuelRictusempra')
     SpellMapping(26)=(SpellSlot=SPELL_DuelMimblewimble,SpellClass=Class'HGame.spellDuelMimblewimble')
     SpellMapping(27)=(SpellSlot=SPELL_DuelExpelliarmus,SpellClass=Class'HGame.spellDuelExpelliarmus')

	Mesh=SkeletalMesh'skMocaHarry'
	Cutname="harry"
	RotationRate=(Pitch=20000,Yaw=87500,Roll=3072)
}