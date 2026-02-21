//================================================================================
// MOCAharry. because regular harry is BUSTED and so will mine be. now slightly less bad in v3.0
//================================================================================

class MOCAharry extends harry;

struct SpellMap
{
	var() const editconst ESpellType SpellSlot; 				// What spell slot to assign the spell to?
	var() class<baseSpell> SpellToAssign; 					// What custom spell class to assign to the slot?
	var() ESpellType SpellToActAs;  							// What spell to act as? For example, if you set this as SPELL_Rictusempra, it will activate actors designed for Rictusempra.
																// By default, it will act as the assigned spell slot if blank.
};

var() bool bSaveOnLoad;

var(MOCAMagic) bool bLoadWithAllSpells;						// Moca: Add all spells to spellbook on load
var(MOCAMagic) bool bUseDefaultSpellbook;					// Moca: Whether or not the custom default spellbook will be applied. Def: False
var(MOCAMagic) Array<Class<baseSpell>> DefaultSpellbook;	// Moca: What default spells do we have?
var(MOCAMagic) SpellMap SpellMapping[28];					// Moca: What spells are mapped to each spell slot?

var(MOCAMagic) class<ParticleFX> WandParticleFX;			// Moca: Particle class to use for wand
var(MOCAMagic) Color DefaultWandParticleColor;				// Moca: Default color of wand particles

var(MOCAMagic) bool bInvisibleWeapon;						// Moca: Makes MOCAwand invisible and spawns spells from the hand's weapon bone.
var(MOCAMagic) float WandGlowRange;							// Moca: How far does the wand glow reach? Def: 6.0

var Weapon PreviousWeapon;		// Previous weapon actor equipped
var travel byte PreviousSlot;	// Previous weapon slot

var Vector RespawnLocation;		// Location to "respawn" harry at
var Rotator RespawnRotation;	// Rotation to set on "respawn"

var SpellCursor StockCursor;	// Ref to stock SpellCursor
var MOCASpellCursor MocaCursor;	// Ref to MOCASpellCursor

var MOCAChar CaughtByActor;
var name PostCaughtEvent;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Set default respawn position (aka starting position)
	SetRespawnPosition(Location,Rotation);

	// If we're set to save on load, then save
	if ( bSaveOnLoad )
	{
		SaveGame();
	}

	if ( bUseDefaultSpellbook )
	{
		local int i;

		for ( i = 0; i < DefaultSpellbook.Length; i++ )
		{
			AddToModdedSpellBook(DefaultSpellbook[i]);
		}
	}

	bNoSpellBookCheck = bLoadWithAllSpells;
}

event PreClientTravel()
{
	// To prevent issues with switching to a map with stock Harry, switch back to baseWand
	SetWeaponBySlot(4);
	Super.PreClientTravel();
}

event TravelPostAccept()
{
	Super.TravelPostAccept();

	// Set up weapons after travel (aka switch back to our pre-travel weapon)
	SetupWeapons();
}

event BaseChanged(Actor OldBase, Actor NewBase)
{
	Super.BaseChanged(OldBase, NewBase);

	if ( NewBase.IsA('MOCABundimun') )
	{
		local MOCABundimun Bundi;
		Bundi = MOCABundimun(NewBase);

		DoBundiJump(Bundi);
	}
}

event Touch(Actor Other)
{
	Super.Touch(Other);
	PickupActor(Other);
}


////////////////////
// Weapon Handling
////////////////////

// Not the cleanest but I feel like it's much better than the previous version

function SetupWeapons()
{
	// Create SpellCursor & MOCASpellCursor if we don't have them
	CreateCursors();

	if ( PreviousSlot == 0 || ( PreviousSlot == 4 && !bHarryUsingSword ) ) // If we don't know our previous weapon or we're using baseWand, switch to MOCAWand for feature compatibility
	{
		SetWeaponByClass( class'MOCAWand', True );
	}
	else	// Otherwise, use our previous weapon
	{
		SetWeaponBySlot(PreviousSlot);
	}
}

function SetWeaponByClass(class<Weapon> DesiredWeapon, bool bForceSet)	// If bForceSet, create the weapon before setting
{
	// Store previous weapon actor
	SetPreviousWeaponActor(Weapon);

	local Weapon NewWeapon;
	NewWeapon = GetWeaponActorByClass(DesiredWeapon,bForceSet);

	if ( NewWeapon != None )
	{
		// Get target weapon slot
		local byte NewSlot;
		NewSlot = NewWeapon.InventoryGroup;

		// Set our weapon using the slot
		SetWeaponBySlot(NewSlot);
	}
	else
	{
		Log("Could not set weapon as we do not have it in our inventory.");
	}
}

function SetWeaponBySlot(byte DesiredSlot)
{
	// Store previous weapon slot
	SetPreviousSlot(Weapon.InventoryGroup);

	Log("Switching to Weapon "$string(DesiredWeapon)$" in slot "$string(DesiredSlot));

	// Switch our weapon and give ammo
	SwitchWeapon(DesiredSlot);
	ChangedWeapon();
	Weapon.GiveAmmo(Self);

	// If we were using a Wand, make sure it is inactive
	if ( PreviousWeapon.IsA('baseWand') )
	{
		DeactivateWand(baseWand(PreviousWeapon));
	}

	// Make sure our SpellCursors are in order
	ValidateCursor();
}

function Weapon GetWeaponActorByClass(class<Weapon> DesiredWeapon, optional bool bForceGet) //bForceGet will create the weapon if it doesn't exist
{
	// Get the weapon from our inventory
	local Weapon FoundWeapon;
	FoundWeapon = FindInventoryType(DesiredWeapon);

	// If we didn't find it and we're force getting, spawn the weapon
	if ( FoundWeapon == None && bForceGet )
	{
		FoundWeapon = SpawnWeaponActor(DesiredWeapon);
	}

	return FoundWeapon;
}

function Weapon SpawnWeaponActor(class<Weapon> WeaponToSpawn)
{
	// Create weapon actor and make it an item
	local Weapon WeaponActor;
	WeaponActor = Spawn((WeaponToSpawn, Self));
	WeaponActor.BecomeItem();

	if ( AddInventory(WeaponActor) )	// If successfully added, return the weapon
	{
		Log("Added Weapon "$string(WeaponActor)$" to Inventory");
		return WeaponActor;
	}
	else	// Otherwise, destroy what we made and return nothing
	{
		Log("Could not add Weapon"$string(WeaponActor)$"to Inventory. It may already exist");
		WeaponActor.Destroy();
		return None;
	}
}

function SetPreviousWeaponActor(Weapon DesiredWeapon)
{
	// Set our previous weapon
	PreviousWeapon = DesiredWeapon;
}

function SetPreviousSlot(byte DesiredSlot)
{
	// Set our previous weapon slot
	PreviousSlot = DesiredSlot;
}

function ValidateCursor()
{
	// "Reset" the cursor. We don't want it active or visible.
	SpellCursor.bSpellCursorAlwaysOn = False;
	SpellCursor.EnableEmission(False);
	TurnOffSpellCursor();

	// Set the correct cursor
	SetCursor(Weapon.Class);
}

function CreateCursors()
{
	local bool FoundCursor;

	if ( StockCursor == None )	// If we don't have our StockCursor
	{
		local SpellCursor A;
		
		// Find SpellCursor
		foreach AllActors(class'SpellCursor', A)
		{
			if ( !A.IsA('MOCASpellCursor') )	// If not a MOCASpellCursor
			{
				// Set StockCursor to found SpellCursor
				StockCursor = A;
				FoundCursor = True;
				break;
			}
		}

		if ( !FoundCursor )	// If we didn't find it
		{
			// Spawn new SpellCursor
			StockCursor = Spawn(class'SpellCursor');
		}
	}

	FoundCursor = False;

	if ( MocaCursor == None )	// If we don't have our MocaCursor
	{
		local MOCASpellCursor B;
		
		// Find MOCACursor
		foreach AllActors(class'MOCASpellCursor', B)
		{
			// Set MocaCursor to found MOCASpellCursor
			MocaCursor = B;
			FoundCursor = True;
		}

		if ( !FoundCursor )	// If we didn't find it
		{
			// Spawn new MOCASpellCursor
			MocaCursor = Spawn(class'MOCASpellCursor');
		}
	}
}

function SetCursor(name WeaponClass) // Breaking this into its own function so it can easily be extended with new classes
{
	// Assign the correct cursor, if any
	switch (WeaponClass)
	{
		case 'baseWand':
			SpellCursor = StockCursor;
		case 'MOCAWand':
			SpellCursor = MocaCursor;
			// Throwing these in here just cuz its convenient
			MOCAWand(WeaponActor).DefaultColorToUse = DefaultWandParticleColor;
			MOCAWand(WeaponActor).fxChargeParticleFXClass = WandParticleFX;
		default:
			SpellCursor = None;
	}
}

function DeactivateWand(baseWand DesiredWand)
{
	// Disable wand and particles
	DesiredWand.bGlowingWand = False;
	DesiredWand.StopGlowingWand();
	DesiredWand.StopChargingSpell();
}

function ToggleUseSword()
{
	bHarryUsingSword = !bHarryUsingSword;

	if ( bHarryUsingSword )
	{
		SetWeaponBySlot(4);
		baseWand(Weapon).ToggleUseSword();
		HarryAnimSet = HARRY_ANIM_SET_SWORD;
	}
	else
	{
		baseWand(Weapon).ToggleUseSword();
		SetWeaponBySlot(PreviousSlot);
		HarryAnimSet = HARRY_ANIM_SET_MAIN;
	}
}


//////////////
// Magic
//////////////

// I'm keeping spellbook stuff as is for now. You can't make me improve this game's awful spell system through a harry extension
function AddToModdedSpellBook (Class<baseSpell> spellClass)
{
	local ESpellType typeToAdd;

	typeToAdd = DetermineSpellType(spellClass);

	if ( ( typeToAdd < MAX_NUM_SPELLS ) && ( SpellBook[typeToAdd] == None ) )
	{
		SpellBook[typeToAdd] = spellClass;
	}
}

function ESpellType DetermineSpellType (class<baseSpell> TestSpell)
{
	local int i;

	for ( i = 0; i < ArrayCount(SpellMapping); i++ )
	{
		if ( SpellMapping[i].SpellToAssign == TestSpell )
		{
			Log("Found mapping at index "$i$" with slot "$SpellMapping[i].SpellSlot);
			return SpellMapping[i].SpellToActAs;
		}
	}

	Log("No mapping found for "$string(TestSpell));
	return SPELL_None;
}

function AddToMocaSpellbook(class<baseClass> SpellToAdd)
{
	if ( !IsSpellInMocaSpellbook(SpellToAdd) )
	{
		MocaSpellbook.AddItem(SpellToAdd);
	}
}

function ClearMocaSpellbook()
{
	MocaSpellbook.Empty();
}

function bool IsSpellInMocaSpellbook(class<baseClass> SpellToTest)
{
	local int i;

	for ( i = 0; i < MocaSpellbook.Length; i++ )
	{
		if ( MocaSpellbook[i] == SpellToTest )
		{
			return True;
		}
	}

	return False;
}

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
	Super.PlaySpellCastSound(SpellType);

	local Sound SpellSound;

	if ( SpellSound == None )
	{
		local class curSpell;
		curSpell = baseWand(Weapon).CurrentSpell;
		SpellSound = class<baseSpell>(curSpell).Default.CastSound;
	}

	if ( SpellSound != None )
	{
		PlaySound(SpellSound,SLOT_None);
	}
}


////////////
// Respawn
////////////

function SetRespawnPosition(Vector NewLocation, Rotator NewRotation)
{
	// Set respawn location and rotation
	RespawnLocation = NewLocation;
	RespawnRotation = NewRotation;
}


///////////////////
// Exec Functions
///////////////////

exec function JackOMode()
{
	if ( Mesh == SkeletalMesh'skPumpkinHarry' )
	{
		Mesh = SkeletalMesh'MOCAharry';
	}
	else
	{
		Mesh = SkeletalMesh'skPumpkinHarry';
	}
}

// I don't like this, if possible I want to find a cleaner way to show all instead of a set list
exec function ShowCollectibles()
{
	local int nCount;
	nCount = 0;
	managerStatus.IncrementCount(Class'StatusGroupJellybeans',Class'StatusItemJellybeans',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupAir',Class'MOCAStatusItemAir',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupCake',Class'MOCAStatusItemCake',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupEarth',Class'MOCAStatusItemEarth',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupEssence',Class'MOCAStatusItemEssence',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupDiscovery',Class'MOCAStatusItemDiscovery',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupFire',Class'MOCAStatusItemFire',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupPasty',Class'MOCAStatusItemPasty',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupPotato',Class'MOCAStatusItemPotato',nCount);
	managerStatus.IncrementCount(Class'MOCAStatusGroupWater',Class'MOCAStatusItemWater',nCount);
}

exec function AltFire (optional float f)
{
	local Vector TraceStart;
	local Vector TraceDirection;
	local Vector TraceEnd;

	if ( HarryAnimChannel.IsCarryingActor() )
	{
		if ( bThrow == False && IsInState('PlayerWalking') )
		{
			ClientMessage("Throw!");
			HarryAnimChannel.GotoStateThrow();
			bThrow = True;
		}
	} 
	else 
	{
		if ( Weapon.IsA('baseWand') && (CarryingActor == None) && !bIsAiming )
		{
			Weapon.bPointing = True;
			StartAiming(bHarryUsingSword);
		}

		if ( (Weapon.IsA('MOCAbaseHands')) )
		{
			InteractTrace(250.0);
		}
	}
}


////////////////////
// Misc. Functions
////////////////////

function InteractTrace(float TraceDistance)
{
	local Vector TraceStart;
	local Vector TraceDirection;
	local Vector TraceEnd;

	TraceStart = Cam.Location;
	TraceDirection = vector(Cam.Rotation);
	TraceEnd = TraceStart + TraceDirection * TraceDistance;

	MOCAbaseHands(Weapon).TraceForInteracts(TraceEnd, TraceStart);
}

function SetNewMesh()
{
	if ( bIsGoyle && Mesh == SkeletalMesh'MOCAharry' )
	{
		Mesh = SkeletalMesh'skGoyleMesh';
		DrawScale = 1.15;
	}
	
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

function DoBundiJump(MOCABundimun Bundi)
{
	if ( Bundi.IsInState('stateStunned') )
	{
		fTimeInAir = 0.0;
		Bundi.HandleStomp();
		GotoState('stateStomping');
	}
}

function SetAnimSet(enumHarryAnimSet NewSet)
{
	Log("Changing anim set to "$string(NewSet));
	HarryAnimSet = NewSet;
}

function name GetCurrIdleAnimName()
{
	local string AnimName;
	local name nm;
	local int iIndex;
	if ( Weapon.IsA('MOCAbaseHands') )
	{
		AnimName = "IdleWandless";
		nm = StringToAnimName(AnimName);
		return nm;
	}
	else
	{
		iIndex = 1 + Rand(IdleNums);
		AnimName = "idle_"$iIndex;
		nm = StringToAnimName(AnimName);
		return nm;
	}
}

function ScreenFade(float TargetOpacity, float FadeOutTime)
{
	local FadeViewController CamFade;
	CamFade = Spawn(Class'FadeViewController');
	CamFade.Init(TargetOpacity,0,0,0,FadeOutTime);
}

function TeleportHarry(Vector TPLocation, Rotator TPRotation)
{
	SetLocation(TPLocation);
	SetRotation(TPRotation);
}

function GetCaught(Actor Catcher, optional name CatchEvent)
{
	CaughtByActor = Catcher;
	PostCaughtEvent = CatchEvent;
	GotoState('stateCaught');
}


///////////
// States
///////////

state stateStomping
{
	begin:
		bStationary = True;
		LoopAnim('Land');
		Sleep(0.5);
		bStationary = False;
		DoJump();
		GotoState('PlayerWalking');
}

state stateInteract
{
	begin:
		PlayAnim('PickBitOfGoyle',3,3);
		Sleep(0.667);
		GotoState('PlayerWalking');
}

state stateCaught
{
	event BeginState()
	{
		PlayAnim('webmove');
		PlaySound(Sound'MocaSoundPak.Music_Cues.stealthCaught_hp3', SLOT_None);
		PlaySound(Sound'HPSounds.Magic_sfx.Dueling_MIM_self_lucky', SLOT_Misc);
		bKeepStationary = True;
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		if ( bSkipCutScene )
		{
			Goto('endcatch');
		}
	}

	begin:
		Sleep(1.0);
		ScreenFade(1.0, 2.0);
		Sleep(2.5);
		TeleportHarry(RespawnLocation,RespawnRotation);
		Sleep(0.5);

	endcatch:
		if ( CaughtByActor.IsA('MOCAWatcher') )
		{
			CaughtByActor.Reset();
		}

		ScreenFade(0.0, 2.0);
		bKeepStationary = False;

		if ( PostCaughtEvent != '' )
		{
			TriggerEvent(PostCaughtEvent,Self,Self);
		}

		GotoState('PlayerWalking');
}

defaultproperties
{
	DefaultWeapon=class'MOCAWand'
	Mesh=SkeletalMesh'MOCAHarry'
	Cutname="harry"
	RotationRate=(Pitch=20000,Yaw=100000,Roll=3072)

	SpellMapping(0)=(SpellSlot=SPELL_None,SpellToAssign=None)
	SpellMapping(1)=(SpellSlot=SPELL_Alohomora,SpellToAssign=class'spellAlohomora')
	SpellMapping(2)=(SpellSlot=SPELL_Incendio,SpellToAssign=None)
	SpellMapping(3)=(SpellSlot=SPELL_LocomotorWibbly,SpellToAssign=class'MOCAspellGlacius')
	SpellMapping(4)=(SpellSlot=SPELL_Lumos,SpellToAssign=class'spellLumos')
	SpellMapping(5)=(SpellSlot=SPELL_Nox,SpellToAssign=None)
	SpellMapping(6)=(SpellSlot=SPELL_PetrificusTotalus,SpellToAssign=None)
	SpellMapping(7)=(SpellSlot=SPELL_WingardiumLeviosa,SpellToAssign=None)
	SpellMapping(8)=(SpellSlot=SPELL_Verdimillious,SpellToAssign=None)
	SpellMapping(9)=(SpellSlot=SPELL_Vermillious,SpellToAssign=None)
	SpellMapping(10)=(SpellSlot=SPELL_Flintifores,SpellToAssign=None)
	SpellMapping(11)=(SpellSlot=SPELL_Reparo,SpellToAssign=None)
	SpellMapping(12)=(SpellSlot=SPELL_MucorAdNauseum,SpellToAssign=None)
	SpellMapping(13)=(SpellSlot=SPELL_Flipendo,SpellToAssign=class'spellFlipendo')
	SpellMapping(14)=(SpellSlot=SPELL_Ectomatic,SpellToAssign=None)
	SpellMapping(15)=(SpellSlot=SPELL_Avifores,SpellToAssign=None)
	SpellMapping(16)=(SpellSlot=SPELL_FireCracker,SpellToAssign=None)
	SpellMapping(17)=(SpellSlot=SPELL_Transfiguration,SpellToAssign=None)
	SpellMapping(18)=(SpellSlot=SPELL_WingSustain,SpellToAssign=None)
	SpellMapping(19)=(SpellSlot=SPELL_Diffindo,SpellToAssign=class'spellDiffindo')
	SpellMapping(20)=(SpellSlot=SPELL_Skurge,SpellToAssign=class'spellSkurge')
	SpellMapping(21)=(SpellSlot=SPELL_Spongify,SpellToAssign=class'spellSpongify')
	SpellMapping(22)=(SpellSlot=SPELL_Rictusempra,SpellToAssign=class'spellRictusempra')
	SpellMapping(23)=(SpellSlot=SPELL_Ecto,SpellToAssign=None)
	SpellMapping(24)=(SpellSlot=SPELL_Fire,SpellToAssign=None)
	SpellMapping(25)=(SpellSlot=SPELL_DuelRictusempra,SpellToAssign=class'spellDuelRictusempra')
	SpellMapping(26)=(SpellSlot=SPELL_DuelMimblewimble,SpellToAssign=class'spellDuelMimblewimble')
	SpellMapping(27)=(SpellSlot=SPELL_DuelExpelliarmus,SpellToAssign=class'spellDuelExpelliarmus')

	DefaultSpellbook(0)=class'spellFlipendo'
	DefaultSpellbook(1)=class'spellAlohomora'
	DefaultSpellbook(2)=class'spellLumos'
	DefaultSpellbook(3)=class'spellRictusempra'
	DefaultSpellbook(4)=class'spellSkurge'
	DefaultSpellbook(5)=class'spellDiffindo'
	DefaultSpellbook(6)=class'spellSpongify'
	DefaultSpellbook(7)=class'MOCAspellGlacius'

	WandParticleFX=Class'MocaOmniPak.MOCAWandParticles'
	WandGlowRange=6.0
	DefaultWandParticleColor=(R=255,G=255,B=255,A=0)
}