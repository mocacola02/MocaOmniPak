class MOCASpellCursor extends SpellCursor;

function WetTexture GetGestureTexture (ESpellType SpellType)
{
	local baseWand PlayerWand;
	local class<baseSpell> SpellToCheck;

	// If not using a wand, return none
	if ( !PlayerHarry.Weapon.IsA('baseWand') )
	{
		return None;
	}

	// Get wand ref
	PlayerWand = baseWand(PlayerHarry.Weapon);
	// Get current spell
	SpellToCheck = PlayerWand.CurrentSpell;

	// If spell isn't a MOCAbaseSpell, match it to stock spell
	if ( !ClassIsChildOf(SpellToCheck, class'MOCAbaseSpell') )
	{
		Log("Our gesture isn't for a Moca spell! "$string(SpellToCheck));

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
	// Otherwise, get MOCAbaseSpell's gesture
	else
	{
		local class<MOCAbaseSpell> MocaSpell;

		MocaSpell = class<MOCAbaseSpell>(SpellToCheck);
		return MocaSpell.Default.SpellWetTexture;
	}
}

// function UpdateCursor(optional bool bJustStopAtClosestPawnOrWall)
// {
// 	local bool bHitActor;
// 	local float DotProduct;
// 	local Vector FirstHitPosition;
// 	local Actor HitActor;

// 	if ( bEmit == False && !bInvisibleCursor )
// 	{
// 		return;
// 	}

// 	aPossibleTarget = None;
// 	bHitSomething = False;
// 	vLOS_Start = PlayerHarry.Cam.CamTarget.Location;

// 	if ( PlayerHarry.bInDuelingMode )
// 	{
// 		vLOS_End = PlayerHarry.Location + (Vector(PlayerHarry.Cam.Rotation + PlayerHarry.AimRotOffset) * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
// 	}
// 	else
// 	{
// 		vLOS_End = PlayerHarry.Cam.Location + (PlayerHarry.Cam.vForward * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
// 	}

// 	vLOS_Dir = Normal(vLOS_End - vLOS_Start);
	
// 	foreach TraceActors(Class'Actor',HitActor,vHitLocation,vHitNormal,vLOS_End,vLOS_Start)
// 	{
// 		if ( HitActor != None || HitActor.IsA('harry') || (!HitActor.IsA('Pawn') && !HitActor.IsA('GridMover') && !HitActor.IsA('spellTrigger')) )
// 		{
// 			continue;
// 		}

// 		if ( !bHitActor && !HitActor.bHidden )
// 		{
// 			bHitSomething = True;
// 			bHitActor = True;
// 			FirstHitPosition = vHitLocation;
// 		}

// 		if ( HitActor.eVulnerableToSpell == SPELL_None )
// 		{
// 			continue;
// 		}

// 		if ( PlayerHarry.IsInSpellBook(HitActor.eVulnerableToSpell) || (bJustStopAtClosestPawnOrWall) )
// 		{
// 			if ( HitActor.IsA('spellTrigger') )
// 			{
// 				if ( !spellTrigger(HitActor).bInitiallyActive )
// 				{
// 					continue;
// 				}

// 				if  ( spellTrigger(HitActor).bHitJustFromFront && !IsHarryFacingTarget(HitActor) )
// 				{
// 					continue;
// 				}
// 			}

// 			if ( !bJustStopAtClosestPawnOrWall )
// 			{
// 				aPossibleTarget = HitActor;
// 				vTargetOffset = vHitLocation - aPossibleTarget.Location;
// 			}

// 			vLastValidHitPos = vHitLocation;
// 		}

// 		vLOS_End = vHitLocation;
// 		break;
// 	}

// 	if ( aPossibleTarget == None && bHitActor )
// 	{
// 		vLOS_End = FirstHitPosition;
// 	}

// 	if ( aCurrentTarget == None )
// 	{
// 		MoveSmooth((vLOS_End - (vLOS_Dir * 8.0)) - Location);
// 		if ( aPossibleTarget != None )
// 		{
// 			SpellGesture.SetLocation(vLOS_End);
// 		}
// 	}
// }

function StartLockedOnSoundLoop()
{
	// Play locked on sound
	PlaySound(Sound'spell_target_nl3',SLOT_Misc);
	PlaySound(Sound'spell_targetloop',SLOT_Interact,,,,,,True);
}

function StopLockedOnSoundLoop()
{
	// Stop locked on sound
	StopSound(Sound'spell_target_nl3',SLOT_Misc,0.5);
	StopSound(Sound'spell_targetloop',SLOT_Interact,1.0);
}