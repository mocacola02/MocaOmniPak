class MOCASpellCursor extends SpellCursor;


function WetTexture GetGestureTexture (ESpellType SpellType)
{
	local baseWand PlayerWand;
	local class<baseSpell> SpellToCheck;

	if ( !PlayerHarry.Weapon.IsA('baseWand') )
	{
		return None;
	}

	PlayerWand = baseWand(PlayerHarry.Weapon);

	SpellToCheck = PlayerWand.CurrentSpell;

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
	else
	{
		local class<MOCAbaseSpell> MocaSpell;

		MocaSpell = class<MOCAbaseSpell>(SpellToCheck);
		return MocaSpell.Default.SpellWetTexture;
	}
}

function UpdateCursor()
{
	if ( bEmit == False && !bInvisibleCursor )
	{
		return;
	}

	bHitSomething = False;
	aPossibleTarget = None;

	local Vector TraceStart,TraceEnd;
	local BaseCam PlayerCam;
	PlayerCam = PlayerHarry.Cam;
	TraceStart = PlayerCam.CamTarget.Location;
	TraceEnd = TraceStart + Vect(PlayerCam.CamTarget.Rotation) * fLOS_Distance;

	local bool bHitActor;
	local Actor HitActor;
	local Vector HitLocation,HitNormal;
	foreach TraceActors(Class'Actor', HitActor, HitLocation, HitNormal, TraceEnd, TraceStart)
	{
		if ( HitActor == Owner || HitActor.IsA('harry') || !HitActor.bProjTarget || HitActor.bHidden )
		{
			continue;
		}

		bHitActor = True;
		bHitSomething = True;

		vHitLocation = HitLocation;
		Location = vHitLocation;

		if ( HitActor.eVulnerableToSpell == SPELL_None )
		{
			continue;
		}

		if ( PlayerHarry.IsInSpellBook(HitActor.eVulnerableToSpell) || (bJustStopAtClosestPawnOrWall) )
		{
			if ( HitActor.IsA('spellTrigger') )
			{
				if( !spellTrigger(HitActor).bInitiallyActive )
				{
					continue;
				}
				if ( spellTrigger(HitActor).bHitJustFromFront && !IsHarryFacingTarget(HitActor) )
				{
					continue;
				} 
			}
			if ( !bJustStopAtClosestPawnOrWall )
			{
				aPossibleTarget = HitActor;
				vTargetOffset = vHitLocation - aPossibleTarget.Location;
			}

			vLastValidHitPos = vHitLocation;
		}

		break;
	}

	if ( aPossibleTarget == None && bHitActor )
	{
		vLOS_End = HitLocation;
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
	PlaySound(Sound'spell_targetloop',SLOT_Interact,,,,,,True);
}

function StopLockedOnSoundLoop()
{
	StopSound(Sound'spell_target_nl3',SLOT_Misc,0.5);
	StopSound(Sound'spell_targetloop',SLOT_Interact,1.0);
}