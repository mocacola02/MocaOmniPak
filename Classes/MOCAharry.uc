//================================================================================
// MOCAharry. because regular harry is BUSTED and so will mine be
//================================================================================

// NOTE: yes this code is a mess yes i am aware
class MOCAharry extends harry;

struct SpellMap
{
  var() ESpellType SpellSlot;
  var() class<baseSpell> SpellToAssign;
};

var() class<Weapon> DefaultWeapon;
var() bool saveOnLoad;

var(MOCASpellbook) Array<Class<baseSpell>> DefaultSpellbook;

var(MOCASpellbook) SpellMap SpellMapping[28];
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
var bool inWater;


////////////////
// EVENTS
////////////////

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

  if (Weapon.IsA('MOCAWand'))
  {
    SpellCursor.Destroy();
    SpellCursor = Spawn(class'MOCASpellCursor');
  }

  Log("We are using weapon " $ string(Weapon) $ " with the cursor " $ string(SpellCursor));
}

event PostBeginPlay()
{
  super.PostBeginPlay();
  if (saveOnLoad)
  {
    SaveGame();
  }


  local int i;

  for (i=0; i < DefaultSpellbook.Length; i++)
  {
    AddToModdedSpellBook(DefaultSpellbook[i]);
  }
}

function AddToModdedSpellBook (Class<baseSpell> spellClass)
{

  local ESpellType typeToAdd;

  typeToAdd = DetermineSpellType(spellClass,self);

  if ( (typeToAdd < MAX_NUM_SPELLS) && (SpellBook[typeToAdd] == None) )
  {
    SpellBook[typeToAdd] = spellClass;
  }
}

function ESpellType DetermineSpellType (class<baseSpell> TestSpell, MOCAharry MocaPlayerHarry)
{
    local int i;

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

event BaseChanged(Actor OldBase, Actor NewBase)
{
  local MOCABundimun Bundi;

  Super.BaseChanged(OldBase, NewBase);
  if (NewBase.IsA('MOCABundimun'))
  {
    Bundi = MOCABundimun(NewBase);
    Bundi.ProcessStomp();
    GotoState('stateStomping');
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

////////////////
// FUNCTIONS
////////////////

function SetAnimSet(int newSet)
{
  Log("Changing anim set to " $ string(newSet));
  HarryAnimSet = enumHarryAnimSet(newSet);
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
    Log("Current weapon is " $ string(Weapon) $ " with owner " $ string(Weapon.Owner));
}

////////////////
// STATES
////////////////

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

state stateBroomFlying
{
	event BeginState()
	{
		local BroomQudditch broomstickHandle; //OBJECTS I'VE SHOVED UP MY ARSE
		SetPhysics(PHYS_Flying);
	}
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

state PlayerWalking
{
  ignores SeePlayer, HearNoise;
  
  event Touch( Actor Other )
  {
    Super.Touch(Other);
  }

  event UnTouch( Actor Other )
  {
    Super.UnTouch(Other);
  }

  event Bump( Actor Other )
  {
    Super.Bump(Other);
  }
  
  event HitWall( vector vHitNormal, Actor Wall )
  {
    Super.HitWall(vHitNormal,Wall);
  }
  
  event TakeDamage (int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
  {
    Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType);
  }
  
  function ZoneChange (ZoneInfo NewZone)
  {
    if (NewZone.bWaterZone)
    {
      GotoState('PlayerSwimming');
    }
  }

  function AnimEnd()
  {
    Super.AnimEnd();
  }
  
  function StartAiming (bool in_bHarryUsingSword)
  {
    Super.StartAiming(in_bHarryUsingSword);
  }
  
  function Landed(vector vHitNormal)
  {
    Super.Landed(vHitNormal);
  }
  
  event PlayerTick( float DeltaTime )
  {
    Super.PlayerTick(DeltaTime);
  }

  function ProcessFalling( float DeltaTime )
  {
    Super.ProcessFalling(DeltaTime);
  }
  
  function JumpOffPawn()
  {
    Super.JumpOffPawn();
  }
  
  function PlayerMove (float DeltaTime)
  {
    Super.PlayerMove(DeltaTime);
  }
  
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
  {
    Super.ProcessMove(DeltaTime,NewAccel,DodgeMove,DeltaRot);
  }
  
  function BeginState()
  {
    Super.BeginState();
    GroundSpeed = Default.GroundSpeed;
    AirSpeed = Default.AirSpeed;
    AirControl = Default.AirControl;
  }
  
  function EndState()
  {
    Super.EndState();
  }
}

state PlayerSwimming
{
  ignores SeePlayer, HearNoise;
  
  event Touch( Actor Other )
  {
	if ( Director != None )
		Director.OnTouchEvent( Self, Other );

	Global.Touch( Other );
  }

  event UnTouch( Actor Other )
  {
	if ( Director != None )
		Director.OnUnTouchEvent( Self, Other );

	Global.UnTouch( Other );
  }

  event Bump( Actor Other )
  {
	if ( Director != None )
		Director.OnBumpEvent( Self, Other );

	Global.Bump( Other );
  }
  
  event HitWall( vector vHitNormal, Actor Wall )
  {
	if ( Director != None )
		Director.OnHitEvent( Self );

	Global.HitWall( vHitNormal, Wall );
  }
  
  event TakeDamage (int Damage, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, name DamageType)
  {
	if ( Director != None )
	{
		Director.OnTakeDamage( Self, Damage, InstigatedBy, DamageType );
	}
	
	Global.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType);
  }
  
  function ZoneChange (ZoneInfo NewZone)
  {
    /*
    if ( !NewZone.bWaterZone )
    {
      SetPhysics(PHYS_Walking);
      GotoState('PlayerWalking');
    }
    */
  }
  
  event PlayerTick( float DeltaTime )
  {
	local actor a;
	local float d;
	local actor ca;

	Global.PlayerTick( DeltaTime );

	if (  !IsA('BroomHarry') && Physics == PHYS_Walking )
	{
		DesiredRotation.Pitch = 0;
	}
	
	if( GetHealthCount() <= 0 
		&& !IsInState('stateDead'))
	{
		KillHarry(true);
		return;
	}

	if ( NoFallingDamageTimer > 0 )
    {
       NoFallingDamageTimer -= DeltaTime;
	   
	   if ( NoFallingDamageTimer < 0 )
	   {
		  NoFallingDamageTimer = 0.0;
	   }
	}

	PlayerMove(DeltaTime);

	if( CarryingActor != none )
	{
		//r = weaponRot;
		//v = vect(0,0,1);
		//v = v >> r;
		CarryingActor.setLocation( weaponLoc );//- vect(0,0,1 );
		CarryingActor.SetRotation( weaponRot );

		//Also, look for a spacebar throw
		if( hpconsole(player.console).bSpacePressed )
		{
			hpconsole(player.console).bSpacePressed = false;
			AltFire(0);
		}
	}
		
	// If we landed on a spongify pad then bounce harry
	if( HitSpongifyPad != None && HitSpongifyPad.IsEnabled() )
	{
		DoJump(0);
		HitSpongifyPad.OnBounce( self );
		AnimFalling = SpongifyFallAnim;
		PlayinAir();
		cam.SetPitch(-8000);
		HitSpongifyPad = None;
		CreateSpongifyEffects();
	}
		
	// HP2 cam
	if( cam.IsInState('StateStandardCam') )//|| cam.IsInState('StateBossCam') )
	{
		// Force our desired Yaw to what the camera's yaw is, in this way harry will
		// always "lookAt" what the camera is looking at.
			DesiredRotation.Yaw = cam.rotation.Yaw & 0xFFFF;
	}
}
  
  function JumpOffPawn()
  {
    fTimeInAir = 0.0;
    Super.JumpOffPawn();
  }
  
  function PlayerMove (float DeltaTime)
  {
    local Vector X;
    local Vector Y;
    local Vector Z;
    local Vector NewAccel;
    local EDodgeDir OldDodge;
    local EDodgeDir DodgeMove;
    local Rotator OldRotation;
    local Rotator CamRot;
    local float Speed2D;
    local bool bSaveJump;
    local name AnimGroupName;
  
	//log("Player move!");
  
    if ( bReverseInput )
    {
      aForward = Abs(aForward * 2);
      aTurn =  -aTurn;
      aStrafe =  -aStrafe;
    }
    aForward *= 0.08;
    if ( Physics == PHYS_Falling || bLockedOnTarget || bFixedFaceDirection ) 
    {
      aStrafe *= 0.08;
      aTurn = 0.0;
    } 
	else 
	{
      aStrafe *= 0.08;
      aTurn *= 0.24;
    }
    aLookUp *= 0;
    aSideMove *= 0.1;
    if ( Adv1TutManager != None )
    {
      if ( aForward > 0 )
      {
        Adv1TutManager.ForwardPushed();
      }
      if ( aForward < 0 )
      {
        Adv1TutManager.BackwardPushed();
      }
      if ( aStrafe < 0 )
      {
        Adv1TutManager.StrafeLeftPushed();
      }
      if ( aStrafe > 0 )
      {
        Adv1TutManager.StrafeRightPushed();
      }
    }
    if ( bKeepStationary )
    {
      aForward = 0.0;
      aStrafe = 0.0;
    }
    if ( bLockOutForward && (aForward > 0) || bLockOutBackward && (aForward < 0) )
    {
      aForward = 0.0;
    }
    if ( bLockOutStrafeLeft && (aStrafe < 0) || bLockOutStrafeRight && (aStrafe > 0) )
    {
      aStrafe = 0.0;
    }
    if ( bLockedOnTarget || bFixedFaceDirection )
    {
      NewAccel = ProcessAccel();
    } 
	else 
	{
      GetAxes(Rotation,X,Y,Z);
      if ( bScreenRelativeMovement )
      {
        GetAxes(Cam.Rotation,X,Y,Z);
        NewAccel = aForward * X + aSideMove * Y;
        if ( NewAccel != vect(0.00,0.00,0.00) )
        {
          CamRot = Cam.Rotation;
          CamRot.Pitch = 0;
          ScreenRelativeMovementYaw = (rotator(NewAccel)).Yaw;
        }
      } 
	  else 
	  {
        NewAccel = aForward * X + aStrafe * Y;
        if ( bInDuelingMode )
        {
          NewAccel *= 1000000;
        }
      }
    }
    if ( bHarryUsingSword )
    {
      GroundSpeed = GroundRunSpeed * (1.0 - 0.9 * baseWand(Weapon).ChargingLevel());
    }
    if ( (aForward != 0) &&  !bIsAiming )
    {
      bHarryMovingNotAiming = True;
    } 
	else 
	{
      bHarryMovingNotAiming = False;
    }
    NewAccel.Z = 0.0;
    AnimGroupName = GetAnimGroup(AnimSequence);
    OldRotation = Rotation;
    ProcessMove(DeltaTime,NewAccel,DodgeMove,OldRotation - Rotation);
    if ( Cam.IsInState('StateStandardCam') )
    {
      DesiredRotation.Yaw = Cam.Rotation.Yaw & 0xFFFF;
      if ( bHarryMovingNotAiming && bAutoCenterCamera &&  !bInDuelingMode )
      {
        if ( AnimFalling != SpongifyFallAnim )
        {
          Cam.SetPitch(-1500.0);
        }
      }
    }
  }
  
  function ProcessMove(float DeltaTime, vector NewAccel, eDodgeDir DodgeMove, rotator DeltaRot)	
  {
		local vector OldAccel;
		local float  Speed;
		
		//log("ProcessMove!");

		OldAccel = Acceleration;
		Acceleration = NewAccel;
		bIsTurning = ( Abs(DeltaRot.Yaw/DeltaTime) > 5000 );

		if(bJustAltFired || bJustFired)
		{
			Velocity = vect(0,0,0);
			return;
		}

		if ( bPressedJump )
		{
//			ClientMessage("Jump pressed");
			DoJump();			// jumping
			bPressedJump = false;
		}

		if ( (Physics == PHYS_Walking)  )
		{
			Speed = VSize2d( Velocity );

			if(   (!bAnimTransition || (AnimFrame > 0))
			   && !( AnimSequence == HarryAnims[HarryAnimSet].Land && (Speed < 5 || VSize2D(acceleration)==0) )  //You need to NOT be (landing and not-moving)    //(GetAnimGroup(AnimSequence) != 'Landing') )
			  )
			{
				//ClientMessage("AnimSequence:"$AnimSequence$" AnimGroup:"$GetAnimGroup(AnimSequence)$" Speed:"$Speed);

				if( Speed > 5 )
					fTimeWalking += DeltaTime;
				else
					fTimeWalking = 0;

				if(   Acceleration != vect(0,0,0)
				   && Speed > 1 //you need a little bit of motion 
				   //&& (    bMovingBackwards   && Speed > 30
				   //    || !bMovingBackwards   && Speed > 65
				   //    ||  fTimeWalking > 0.5 && Speed > 15
				   //   )
				  )
				{
						bAnimTransition = true;
						TweenToRunning(0.4);
				}
			 	else
			 	{
						bAnimTransition = true;
						TweenToWaiting(0.4);
				}
			}
		}
  }
  
  function BeginState()
  {
    DebugState();
    if ( Mesh == None )
    {
      SetMesh();
    }
    HarryAnims[0].Idle        = 'SwimIdle';
    HarryAnims[0].Walk        = 'Walk';
    HarryAnims[0].run         = 'SwimIdle';
    HarryAnims[0].WalkBack    = 'SwimIdle';
    HarryAnims[0].StrafeRight = 'Spongify';
    HarryAnims[0].StrafeLeft  = 'Spongify';
    HarryAnims[0].Jump        = 'Jump';
    HarryAnims[0].Jump2       = 'Jump2';
    HarryAnims[0].Fall        = 'Fall';
    HarryAnims[0].Land        = 'Land';
    Log("Changing to swim anims");
    SetAnimSet(0);
    GroundSpeed = 140.00;
    AirSpeed = 200.00;
    AirControl = 0.25;
    inWater = true;
    WalkBob = vect(0.00,0.00,0.00);
    DodgeDir = DODGE_None;
    bIsCrouching = False;
    bIsTurning = False;
    bPressedJump = False;
    SetPhysics(PHYS_Swimming);
	LoopAnim(CurrIdleAnimName,,[TweenTime]0.40,,[Type]HarryAnimType);
    if (  !IsAnimating() )
    {
      PlayWaiting();
    }
    foreach AllActors(Class'BaseCam',Cam)
    {
	  break;
    }
  }
  
  function EndState()
  {
    HarryAnims[0].Idle        = 'Idle';
    HarryAnims[0].Walk        = 'Walk';
    HarryAnims[0].run         = 'Run';
    HarryAnims[0].WalkBack    = 'RunBack';
    HarryAnims[0].StrafeRight = 'StrafeRight';
    HarryAnims[0].StrafeLeft  = 'StrafeLeft';
    HarryAnims[0].Jump        = 'Jump';
    HarryAnims[0].Jump2       = 'Jump2';
    HarryAnims[0].Fall        = 'Fall';
    HarryAnims[0].Land        = 'Land';
    SetAnimSet(0);
    inWater = false;
    WalkBob = vect(0.00,0.00,0.00);
    bIsCrouching = False;
    StopAiming();
    Acceleration = vect(0.00,0.00,0.00);
    Velocity = vect(0.00,0.00,0.00);
    CurrIdleAnimName = GetCurrIdleAnimName();
    LoopAnim(CurrIdleAnimName,,[TweenTime]0.40,,[Type]HarryAnimType);
    Log("NOT LONGER SWIMMING!!!!!!!!!!!!!!!!!!!!!");
  }
}



defaultproperties
{
    DefaultWeapon=class'MocaOmniPak.MOCAWand'
    Mesh=SkeletalMesh'MocaModelPak.MOCAHarry'
    Cutname="harry"
    AirControl=0.35

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
    DefaultSpellbook(3)=class'MOCAspellGlacius'
}