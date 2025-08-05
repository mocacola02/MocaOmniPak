//================================================================================
// MOCAharry. because regular harry is BUSTED and so will mine be
//================================================================================

class MOCAharry extends harry;
var() class<Weapon> DefaultWeapon;
var() bool saveOnLoad;
var int DefaultWeaponSlot;
var Weapon weap;
var Vector respawnLoc;
var Rotator respawnRot;
var FadeActorController mcFade;
var int currentWeapon;
var bool bWallJumped;
var vector HitNormal;
var Actor LastStoredBase;
var bool DebugWeaponToggleCooldown;
var array<class<baseSpell>> defaultSpells;
var class<SpellCursor> desiredSpellCursor;


event PreBeginPlay()
{
  Super.PreBeginPlay();
  respawnLoc = Location;
  respawnRot = Rotation;
  if (DefaultWeapon == class'MocaOmniPak.MOCAbaseHands')
  {
    DefaultWeaponSlot = 0;
  }
  else {
    DefaultWeaponSlot = 1;
  }
  SetHarryWeapon(DefaultWeapon, DefaultWeaponSlot);

  if (SpellCursor != None)
  {
    SpellCursor.Destroy();
  }
  SpellCursor = Spawn(desiredSpellCursor);

  ClearSpellBook();
  AddSpellsToSpellbook(defaultSpells);
}

event PostBeginPlay()
{
  super.PostBeginPlay();
  if (saveOnLoad)
  {
    SaveGame();
  }

  Log("Calling all spells");
  AddAllSpellsToSpellBook();
}

event BaseChanged(Actor OldBase, Actor NewBase)
{
  local MOCABundimun Bundi;

  Super.BaseChanged(OldBase, NewBase);
  if (NewBase.IsA('MOCABundimun'))
  {
    Bundi = MOCABundimun(NewBase);
    Bundi.ProcessStomp();
  }
}

function AddSpellsToSpellbook(array<class<baseSpell>> spellsToAdd)
{
  local int	i;
  for (i = 0; i < spellsToAdd.Length; i++)
  {
    AddToSpellBook(spellsToAdd[i]);
  }
}

function name GetCurrIdleAnimName()
{
  local string AnimName;
  local name nm;
  local int iIndex;
  if (/*(IsInState('PlayerWalking') || IsInState('stateIdle')) &&*/ currentWeapon == 0)
  {
      AnimName = "IdleWandless";
      nm = StringToAnimName(AnimName);
      return nm;
  }
  else {
      iIndex = 1 + Rand(IdleNums);
      AnimName = "idle_" $iIndex;
      nm = StringToAnimName(AnimName);
      return nm;
  }
}

function screenFade (float fadeOpacity, float fadeOutTime)
{
  local FadeViewController mcCamFade;
  mcCamFade = Spawn(Class'FadeViewController');
  mcCamFade.Init (fadeOpacity, 0, 0, 0, fadeOutTime);
}

event TravelPostAccept()
{
  local SmartStart StartPoint;
  local Characters Ch;
  local bool bFoundSmartStart;

	if ( Health <= 0 )
		Health = Default.Health;
	
	iGamestate = ConvertGameStateToNumber();
	
	Log("weapon is" $ string(Weapon));
	if ( Inventory == None )
	{
		weap = Spawn(DefaultWeapon,self);
		weap.BecomeItem();
		AddInventory(weap);
		weap.WeaponSet(self);
		weap.GiveAmmo(self);
		Log(string(self) $ " spawning weap " $ string(weap));
	} 
	else 
	{
		Log("not spawning weap");
	}
	CopyAllStatusFromHarryToManager();
	StatusGroupWizardCards(managerStatus.GetStatusGroup(Class'StatusGroupWizardCards')).RemoveHarryOwnedCardsFromLevel(None);
	if ( Director != None )
	{
		Director.OnPlayerTravelPostAccept();
	}
	foreach AllActors(Class'Characters',Ch)
	{
		Ch.SetEverythingForTheDuel();
	}
	if ( PreviousLevelName != "" )
	{
		bFoundSmartStart = False;
		foreach AllActors(Class'SmartStart',StartPoint)
		{
			if ( (StartPoint.PreviousLevelName != "") && (StartPoint.PreviousLevelName ~= PreviousLevelName) )
			{
				SetLocation(StartPoint.Location);
				SetRotation(StartPoint.Rotation);
				if ( StartPoint.bDoLevelSave )
				{
					harry(Level.PlayerHarryActor).SaveGame();
				}
				cm("***Found SmartStart from:" $ PreviousLevelName);
				Log("***Found SmartStart from:" $ PreviousLevelName);
				bFoundSmartStart = True;
				break;
			} 
		}
	}
	if (  !bFoundSmartStart )
	{
		cm("***Failed to find SmartStart from:" $ PreviousLevelName);
		Log("***Failed to find SmartStart from:" $ PreviousLevelName);
	}
	if ( bQueuedToSaveGame )
	{
		cm(" *-*-* Keep the loading screen ON because we *ARE* QueuedToSaveGame. At least until we are done saving.");
		Log(" *-*-* Keep the loading screen ON because we *ARE* QueuedToSaveGame. At least until we are done saving.");
		bShowLoadingScreen = True;
	} 
	else 
	{
		cm(" *-*-* Turn OFF the loading screen because we are *NOT* QueuedToSaveGame.");
		Log(" *-*-* Turn OFF the loading screen because we are *NOT* QueuedToSaveGame.");
		bShowLoadingScreen = False;
		
		// Omega: Fix the cutscene skip state desyncing when loading into a save that was skipping
		Log("Loading into save with cutscene skip state: " $HPHud(MyHud).managerCutScene.bShowFF);
		if(HPHud(MyHud).managerCutScene.bShowFF)
		{
			HPConsole(Player.Console).StartFastForward();
		}
	}
	
	// Omega: FOV CHANGES
	Cam.FOVChanged();
}

state stateInteract
{
  begin:
    PlayAnim('PickBitOfGoyle',3,3);
    sleep(0.6);
    GotoState('PlayerWalking');
}



state caught
{
  begin:
    PlayAnim('webmove',1,1);
    PlaySound(Sound'MocaSoundPak.Music_Cues.stealthCaught_hp3', SLOT_None);
    PlaySound(Sound'HPSounds.Magic_sfx.Dueling_MIM_self_lucky', SLOT_Misc, 1);
    bKeepStationary = True;
    sleep(1.0);
    screenFade(1.0, 2.0);
    sleep(2.5);
    SetLocation(respawnLoc);
    SetRotation(respawnRot);
    //Cam.SetRotation(respawnRot);   Find actually functioning way to do this
    sleep(0.5);
    screenFade(0.0, 2.0);
    bKeepStationary = False;
    GotoState('PlayerWalking');
}

exec function AltFire (optional float f)
{
  local Vector V;
  local Rotator R;
  local Vector TraceStart;
  local Vector TraceDirection;
  local Vector TraceEnd;
  
  //Log(string(DebugWeaponToggleCooldown));
  DebugWeaponToggleCooldown=False;
  //Log(string(DebugWeaponToggleCooldown));

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
    if ( Weapon.IsA('baseWand') && (CarryingActor == None) && !bIsAiming)
    {
      Weapon.bPointing = True;
      StartAiming(bHarryUsingSword);
    }
  if ((Weapon.Class == class'MOCAbaseHands'))
  {
    TraceStart = Cam.Location;
    TraceDirection = vector(Cam.Rotation);
    TraceEnd = TraceStart + TraceDirection * 250.0;
    MOCAbaseHands(weapon).TraceForInteracts(TraceEnd, TraceStart);
  }
  }
}

event PlayerInput (float DeltaTime)
{
  local StatusItem SI;
  local StatusGroup SG;
  local string NCountAsString;
  local int i;

  Super.PlayerInput(DeltaTime);
  if ( bSkipCutScene == 1 )
  {
    if (HPHud(myHUD).bCutSceneMode)
    {
      HPConsole(Player.Console).StartFastForward();
    }
    else
    {
      if (HPConsole(Player.Console).bDebugMode)
      {
        if (!DebugWeaponToggleCooldown)
        {
          if ( currentWeapon == 0 )
          {
            SetHarryWeapon(class'MocaOmniPak.MOCAWand',1);
          }
          else
          {
            SetHarryWeapon(class'MocaOmniPak.MOCAbaseHands',0);  
          }
          DebugWeaponToggleCooldown=True;
        }
      }
    }
  }
}

function SetHarryWeapon (class<Weapon> WeaponToSpawn, int WeaponSlot)
{
    weap.Destroy();
    Log('Switching Weapon');
    weap = Spawn(WeaponToSpawn, self); // Cast the spawned actor to Weapon
    AddInventory(weap); // Add the weapon to the player's inventory
    weap.WeaponSet(self); // Set the weapon       
    weap.GiveAmmo(self); // Give ammo to the weapon if needed
    SwitchWeapon(WeaponSlot);
    currentWeapon = WeaponSlot;
}

defaultproperties
{
    DefaultWeapon=class'MocaOmniPak.MOCAWand'
    Mesh=SkeletalMesh'MocaModelPak.MOCAHarry'
    Cutname="harry"
    desiredSpellCursor=class'SpellCursor'
}