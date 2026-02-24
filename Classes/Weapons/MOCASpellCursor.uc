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

function UpdateCursor(optional bool bJustStopAtClosestPawnOrWall)
{
	// If not emitting and we're not an invisible cursor, return
	if ( bEmit == False && !bInvisibleCursor )
	{
		return;
	}

	// We haven't hit anything yet
	bHitSomething = False;
	aPossibleTarget = None;

	local Vector TraceStart,TraceEnd;
	local BaseCam PlayerCam;
	// Get player cam
	PlayerCam = PlayerHarry.Cam;
	// Get trace start from cam location
	TraceStart = PlayerCam.CamTarget.Location;
	// Get trace end from in front of trace start multiplied by fLOS_Distance
	TraceEnd = TraceStart + Vector(PlayerCam.CamTarget.Rotation) * fLOS_Distance;

	local bool bHitActor;
	local Actor HitActor;
	local Vector HitLocation,HitNormal;
	// Trace for actors
	foreach TraceActors(Class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart)
	{
		// If actor is our owner, or harry, or isn't bProjTarget, or is hidden, ignore this actor
		if ( HitActor == Owner || HitActor.IsA('harry') || !HitActor.bProjTarget || HitActor.bHidden )
		{
			continue;
		}

		// We hit something, so yes
		bHitActor = True;
		bHitSomething = True;

		// Set hit location
		vHitLocation = HitLocation;

		// If actor isn't vulnerable to a spell, ignore this actor
		if ( HitActor.eVulnerableToSpell == SPELL_None )
		{
			continue;
		}

		// If we have that spell
		if ( PlayerHarry.IsInSpellBook(HitActor.eVulnerableToSpell) || (bJustStopAtClosestPawnOrWall) )
		{
			// If it's a spell trigger
			if ( HitActor.IsA('spellTrigger') )
			{
				// If not active, ignore it
				if( !spellTrigger(HitActor).bInitiallyActive )
				{
					continue;
				}
				// If we aren't in front of it, ignore it
				if ( spellTrigger(HitActor).bHitJustFromFront && !IsHarryFacingTarget(HitActor) )
				{
					continue;
				} 
			}
			// If not bJustStopAtClosestPawnOrWall, set our target
			if ( !bJustStopAtClosestPawnOrWall )
			{
				aPossibleTarget = HitActor;
				vTargetOffset = vHitLocation - aPossibleTarget.Location;
			}
			// Set last valid hit pos
			vLastValidHitPos = vHitLocation;
		}
		// Stop trace
		break;
	}

	// If we didn't have a target, set LOS end to hit location
	if ( aPossibleTarget == None && bHitActor )
	{
		vLOS_End = HitLocation;
	}

	// If we hit nothing, move cursor smoothly
	if ( aCurrentTarget == None )
	{
		MoveSmooth((vLOS_End - (vLOS_Dir * 8.0)) - Location);

		// If we have a possible target, set gesture location
		if ( aPossibleTarget != None )
		{
			SpellGesture.SetLocation(vLOS_End);
		}
	}
}

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