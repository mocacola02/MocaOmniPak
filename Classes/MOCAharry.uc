//================================================================================
// MOCAharry.
//================================================================================
class MOCAharry extends harry;

//= General Exports =//
var() bool bSaveOnLoad;		// Moca: Should the game save when we load in? Def: False

var(MOCAMagic) Class<SpellCursor> SpellCursorClass;

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

	// If we're set to save on load, then save
	if ( bSaveOnLoad )
	{
		SaveGame();
	}
}

event PreClientTravel()
{
	DebugLog("Resetting to baseWand so we don't break a non-MOCAharry map");
	SwitchWeapon(4);
	ChangedWeapon();
	Weapon.GiveAmmo(self);
}

event TravelPostAccept()
{
    local Weapon weap;

	Super.TravelPostAccept();

	if( FindInventoryType(Class'MOCAWand') == None )
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

	SwitchWeapon(2);
	ChangedWeapon();
	Weapon.GiveAmmo(self);
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

// function ToggleUseSword()
// {
// 	bHarryUsingSword = !bHarryUsingSword;

// 	if ( bHarryUsingSword )
// 	{
// 		SetWeaponBySlot(4);
// 		baseWand(Weapon).ToggleUseSword();
// 		HarryAnimSet = HARRY_ANIM_SET_SWORD;
// 	}
// 	else
// 	{
// 		baseWand(Weapon).ToggleUseSword();
// 		SetWeaponBySlot(PreviousSlot);
// 		HarryAnimSet = HARRY_ANIM_SET_MAIN;
// 	}
// }

function SetNewMesh()
{
	// If harry, goyle
	if ( bIsGoyle && Mesh == SkeletalMesh'MOCAharry' )
	{
		Mesh = SkeletalMesh'skGoyleMesh';
		DrawScale = 1.15;
	}
	// If goyle, harry
	if ( !bIsGoyle && Mesh == SkeletalMesh'skGoyleMesh' )
	{
		Mesh = SkeletalMesh'MOCAharry';
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
	SpellCursorClass=Class'MOCASpellCursor'

	Mesh=SkeletalMesh'MOCAHarry'
	Cutname="harry"
	RotationRate=(Pitch=20000,Yaw=87500,Roll=3072)
}