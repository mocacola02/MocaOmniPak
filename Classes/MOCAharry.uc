//================================================================================
// MOCAharry. because regular harry is BUSTED and so will mine be
//================================================================================

class MOCAharry extends harry;
var() class<Weapon> DefaultWeapon;
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

state teleportAway
{
  //WIP
  //mcFade = Spawn(Class'FadeActorController');
  //mcFade.Init(self, 0.0, 1.0);
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
  
  Log(string(DebugWeaponToggleCooldown));
  DebugWeaponToggleCooldown=False;
  Log(string(DebugWeaponToggleCooldown));

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
    if ((Weapon.Class == class'BaseWand') && (CarryingActor == None) && !bIsAiming)
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
            SetHarryWeapon(class'HGame.baseWand',1);
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
    DefaultWeapon=class'HGame.baseWand'
    Mesh=SkeletalMesh'MocaModelPak.MOCAHarry'
    Cutname="harry"
}