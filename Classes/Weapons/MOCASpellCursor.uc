class MOCASpellCursor extends SpellCursor;

event Tick (float DeltaTime)
{
    Super.Tick(DeltaTime);
    Log(aPossibleTarget);
}

function WetTexture GetGestureTexture (ESpellType SpellType)
{
    local baseWand PlayerWand;
    local class<baseSpell> SpellToCheck;

    if (PlayerHarry.Weapon.IsA('baseWand'))
    {
        PlayerWand = baseWand(PlayerHarry.Weapon);
    }
    else
    {
        return None;
    }

    SpellToCheck = PlayerWand.CurrentSpell;

    Log("For our gesture, the current spell is " $ string(SpellToCheck));

    if (!ClassIsChildOf(SpellToCheck, class'MOCAbaseSpell'))
    {
        Log("Our gesture isn't for a Moca spell! " $ string(SpellToCheck));
        switch (SpellType)
        {
            case SPELL_None:			return None;
            case SPELL_Flipendo:		return FlipendoWetTexture;
            case SPELL_Lumos:			return LumosWetTexture;
            case SPELL_Alohomora:		return AlohomoraWetTexture;
            case SPELL_Skurge:			return SkurgeWetTexture;
            case SPELL_Rictusempra:		return RictusempraWetTexture;
            case SPELL_Diffindo:		return DiffindoWetTexture;
            case SPELL_Spongify:		return SpongifyWetTexture;
        }
    }
    else
    {
        Log("Our gesture is for a Moca spell.");
        local class<MOCAbaseSpell> MocaSpell;

        MocaSpell = class<MOCAbaseSpell>(SpellToCheck);

        local WetTexture newGesture;

        newGesture = MocaSpell.Default.SpellWetTexture;

        Log("The gesture for " $ string(MocaSpell) $ " gave us " $ string(newGesture));

        return newGesture;
    }
}

function UpdateCursor (optional bool bJustStopAtClosestPawnOrWall)
{
  //local Actor HitActor;
  local Actor aHitActor;
  local bool bHitActor;
  local Vector vFirstHitPos;
  local float fDotProduct;

  if ( bEmit == False &&  !bInvisibleCursor )
  {
    return;
  }
  aPossibleTarget = None;
  bHitSomething = False;
  vLOS_Start = PlayerHarry.Cam.CamTarget.Location;
  if ( PlayerHarry.bInDuelingMode )
  {
    vLOS_End = PlayerHarry.Location + (vector (PlayerHarry.Rotation) * fLOS_Distance);
  } else //{
    if ( PlayerHarry.bHarryUsingSword )
    {
      vLOS_End = PlayerHarry.Cam.Location + (vector (PlayerHarry.Cam.Rotation + PlayerHarry.AimRotOffset) * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
    } else {
      vLOS_End = PlayerHarry.Cam.Location + (PlayerHarry.Cam.vForward * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
    }
  //}
  vLOS_Dir = Normal(vLOS_End - vLOS_Start);
  aHitActor = Trace(vHitLocation,vHitNormal,vLOS_End,PlayerHarry.Cam.Location);

  if ( (aHitActor != None) &&  !aHitActor.IsA('BaseHarry') )
  {
    bHitSomething = True;
    vLOS_End = vHitLocation + (vLOS_Dir * 5.0);
  }
  foreach TraceActors(Class'Actor',aHitActor,vHitLocation,vHitNormal,vLOS_End,vLOS_Start)
  {
    if ( aHitActor == Owner || aHitActor.IsA('harry') ||  (!aHitActor.IsA('Pawn') &&  !aHitActor.IsA('GridMover') &&  !aHitActor.IsA('spellTrigger')) )
    {
      continue;
    } 
    if ( bEmit && bDebugMode )
    {
      PlayerHarry.ClientMessage(" TraceActors Hit actor -> " $ string(aHitActor));
    }
    if (  !bHitActor &&  !aHitActor.bHidden )
    {
      bHitSomething = True;
      bHitActor = True;
      vFirstHitPos = vHitLocation;
    }
    if ( aHitActor.eVulnerableToSpell == SPELL_None )
    {
      continue;
    } 
    if ( PlayerHarry.IsInSpellBook(aHitActor.eVulnerableToSpell) || (bJustStopAtClosestPawnOrWall) )
    {
       if ( aHitActor.IsA('spellTrigger') )
       {
	     if( !spellTrigger(aHitActor).bInitiallyActive )
		 {
		   continue;
		 }
         if ( spellTrigger(aHitActor).bHitJustFromFront &&  !IsHarryFacingTarget(aHitActor) )
         {
           continue;
         } 
	   }
       if (  !bJustStopAtClosestPawnOrWall )
       {
          aPossibleTarget = aHitActor;
          vTargetOffset = vHitLocation - aPossibleTarget.Location;
       }
       vLastValidHitPos = vHitLocation;
    }
	vLOS_End = vHitLocation;
	break;
  }
  if ( aPossibleTarget == None && bHitActor )
  {
    vLOS_End = vFirstHitPos;
  }
  if ( aCurrentTarget == None )
  {
    MoveSmooth((vLOS_End - (vLOS_Dir * 8.0)) - Location);
    if ( aPossibleTarget != None )
    {
      SpellGesture.SetLocation(vLOS_End);
    }
  }
}

function StartLockedOnSoundLoop()
{
  PlaySound(Sound'spell_target_nl3',SLOT_Misc);
  PlaySound(Sound'spell_targetloop',SLOT_Interact,,,,,,true);
}

function StopLockedOnSoundLoop()
{
  StopSound(Sound'spell_target_nl3',SLOT_Misc,0.5);
  StopSound(Sound'spell_targetloop',SLOT_Interact,1.0);
}