//================================================================================
// MOCASpellCursor.
//================================================================================
class MOCASpellCursor extends SpellCursor;

var array<name> BlacklistedClasses;

// Update the cursor position and trace for a target.
function UpdateCursor (optional bool bJustStopAtClosestPawnOrWall)
{
	local bool bHitActor;
	local float fDotProduct;
	local Vector vFirstHitPos;
	local Actor aHitActor;
	
	// If we're not emitting and we're not intended to be always invisible, do nothing and return.
	if ( bEmit == False &&  !bInvisibleCursor )
	{
		return;
	}

	// Reset the aPossibleTarget and bHitSomething
	aPossibleTarget = None;
	bHitSomething = False;

	// Note: LOS is more or less our line trace. vLOS_Start is where the line trace starts, vLOS_End is where the line trace ends.

	// Set trace start position at the cam target position.
	vLOS_Start = PlayerHarry.Cam.CamTarget.Location;

	// If Harry is dueling
	if ( PlayerHarry.bInDuelingMode )
	{
		// Set the end position so we trace directly in front of Harry with a length of fLOS_Distance
		vLOS_End = PlayerHarry.Location + (vector (PlayerHarry.Rotation) * fLOS_Distance);
	}
	// Otherwise, if Harry is using sword
	else if ( PlayerHarry.bHarryUsingSword )
	{
		// Set the end position so we trace in the direction the camera is looking plus Harry's AimRotOffset with a length of the camera set's fLookAtDistance plus fLOS_Distance
		vLOS_End = PlayerHarry.Cam.Location + (vector (PlayerHarry.Cam.Rotation + PlayerHarry.AimRotOffset) * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
	}
	// Otherwise
	else
	{
		// Set the end position so we trace in the direction the camera is looking with a length of the camera set's fLookAtDistance plus fLOS_Distance
		vLOS_End = PlayerHarry.Cam.Location + (PlayerHarry.Cam.vForward * (PlayerHarry.Cam.CurrentSet.fLookAtDistance + fLOS_Distance));
	}

	// Determine the trace direction vector by normalizing the direction from the trace start to the trace end
	vLOS_Dir = Normal(vLOS_End - vLOS_Start);

	// Trace for any actor between the camera position and trace end position, and store the actor, hit location, and hit normal
	aHitActor = Trace(vHitLocation,vHitNormal,vLOS_End,PlayerHarry.Cam.Location);

	// If we hit an actor AND the hit actor is not a BaseHarry (that's an HP1 class, so this always clears)
	if ( (aHitActor != None) && !aHitActor.IsA('BaseHarry') )
	{
		// Set that we hit something
		bHitSomething = True;
		// Determine the new trace end position from the hit location plus our trace direction multiplied by 5
		vLOS_End = vHitLocation + (vLOS_Dir * 5.0);
	}

	// Trace for any actors in our line of sight and do the following for each traced actor
	foreach TraceActors(Class'Actor',aHitActor,vHitLocation,vHitNormal,vLOS_End,vLOS_Start)
	{
		// If the hit actor is our owner OR is Harry OR is not a Pawn, GridMover, or spellTrigger
		if ( aHitActor == Owner || IsBlacklisted(aHitActor) || (!aHitActor.IsA('Pawn') &&  !aHitActor.IsA('GridMover') &&  !aHitActor.IsA('spellTrigger')) )
		{
			// Continue to the next traced actor, if any
			continue;
		}

		// If we're emitting and we're in debug mode, print what actor we hit
		if ( bEmit && bDebugMode )
		{
			PlayerHarry.ClientMessage(" TraceActors Hit actor -> " $ string(aHitActor));
		}

		// If we have not hit an actor yet, and the actor isn't hidden
		if (  !bHitActor &&  !aHitActor.bHidden )
		{
			// Set that we hit something and hit an actor
			bHitSomething = True;
			bHitActor = True;
			// Set the first hit position to the current hit position
			vFirstHitPos = vHitLocation;
		}

		// If the hit actor is not vulnerable to any spell
		if ( aHitActor.eVulnerableToSpell == SPELL_None )
		{
			// Continue to the next traced actor, if any
			continue;
		}

		// If Harry has the vulnerable spell OR bJustStopAtClosestPawnOrWall is true
		if ( PlayerHarry.IsInSpellBook(aHitActor.eVulnerableToSpell) || (bJustStopAtClosestPawnOrWall) )
		{
			// If the hit actor is a spellTrigger
			if ( aHitActor.IsA('spellTrigger') )
			{
				// If trigger is not initially active
				if( !spellTrigger(aHitActor).bInitiallyActive )
				{
					// Continue to the next traced actor, if any
					continue;
				}

				// If spellTrigger can only be hit from front AND Harry is not facing the spellTrigger
				if ( spellTrigger(aHitActor).bHitJustFromFront &&  !IsHarryFacingTarget(aHitActor) )
				{
					// Continue to the next traced actor, if any
					continue;
				}
			}

			// If bJustStopAtClosestPawnOrWall is false
			if ( !bJustStopAtClosestPawnOrWall )
			{
				// Set our possible target to the hit actor
				aPossibleTarget = aHitActor;
				// Set our target offset to the hit location minus the possible target's location
				vTargetOffset = vHitLocation - aPossibleTarget.Location;
			}

			// Set the last valid hit position to our current hit position
			vLastValidHitPos = vHitLocation;
		}

		// Set the end position of our LOS/trace to our current hit position
		vLOS_End = vHitLocation;

		// Exit the foreach loop
		break;
	}

	// If we don't have a possible target, but we hit an actor
	if ( aPossibleTarget == None && bHitActor )
	{
		// Set the end of our LOS to the first hit position
		vLOS_End = vFirstHitPos;
	}

	// If we don't have a current target
	if ( aCurrentTarget == None )
	{
		// Move the cursor to the end of our LOS minus the direction of our LOS multiplied by 8 minus the cursor's current position
		MoveSmooth((vLOS_End - (vLOS_Dir * 8.0)) - Location);
		
		// If we have a possible target
		if ( aPossibleTarget != None )
		{
			// Set the spell gesture's location to the end of our LOS
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

function bool IsBlacklisted(Actor HitActor)
{
	local int i;

	for( i = 0; i < BlacklistedClasses.Length; i++ )
	{
		if( HitActor.IsA(BlacklistedClasses[i]) )
		{
			return True;
		}
	}

	return False;
}


defaultproperties
{
	BlacklistedClasses(0)="harry"
	BlacklistedClasses(1)="MOCACollectible"
}