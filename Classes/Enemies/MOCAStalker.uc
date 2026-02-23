//================================================================================
// MOCAStalker.
//================================================================================
class MOCAStalker extends MOCAChar;

var() float AngerRate;		// Moca: How fast do we gain anger each second? Def: 3.0
var() float RelaxRate;		// Moca: How fast do we lose anger each second? Def: 1.5
var() float RequiredAnger;	// Moca: How angry do we need to be to attack? Def: 25.0
var() float ChaseSpeed;		// Moca: How fast do we move during a chase (aka attack)? Def: 400.0
var() float StalkCooldown;	// Moca: How long to wait before stalking again? Def: 10.0
var() float MinDot; 		// Moca: Minimum dot product to compare when determining if we're seen. Def: 0.25
var() float ActiveRadius;	// Moca: How close does Harry have to be for us to become active? Def: 163840.0 (aka "infinite")

// Sound vars
var Sound RetreatSound;	// Sound on retreat
var Sound AttackSound;	// Sound on attack
var Sound KillSound;	// Sound when killing Harry
var Sound DieSound;		// Sound when dying

// Anim vars
var name WaitAnim;		// Wait anim (idle)
var float WaitAnimRate;	// Wait anim rate

var name SneakAnim;		// Sneak anim (stalk mode)
var float SneakAnimRate;// Sneak anim rate

var name RetreatAnim;	// Retreat anim
var float RetreatAnimRate;	// Retreat anim rate

var name StareAnim;		// Stare anim (when building up anger)
var float StareAnimRate;// Star anim rate

var name AttackAnim;	// Attack anim (chasing)
var float AttackAnimRate;// Attack anim rate

var name KillAnim;		// Kill anim
var float KillAnimRate;	// Kill anim rate

var name DieAnim;		// Die anim
var float DieAnimRate;	// Die anim rate

var bool bIsStaring;	// Are we staring to build anger?

var int RandInt;		// Random int storage
var float CurrentAnger;	// Current anger level

var NavigationPoint RetreatNavP;	// navP to retreat to


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Turn to Harry
	EnableTurnTo(PlayerHarry);

	// If we don't have stalker nodes or MOCAharry, yell at mapper
	if ( !MOCAHelpers.DoesActorExist(class'MOCAStalkerNode') || !PlayerHarry.IsA('MOCAharry') )
	{
		MOCAHelpers.PushError("MOCAStalker actors (like MOCABracken) require MOCAStalkerNodes and MOCAharry. Make sure you have these implemented.");
	}
}

event Bump(Actor Other)
{
	Super.Bump(Other);

	// If we bumped into Harry and we aren't killing him, kill him
	if ( Other == PlayerHarry && !IsInState('stateKill') )
	{
		GotoState('stateKill');
	}
}

event HitWall(Vector HitNormal, Actor HitWall)
{
	Super.HitWall(HitNormal,HitWall);

	// If we hit a wall, retreat to be safe
	if ( ( !IsInState('stateStalkDerailed') || !IsInState('stateAttackDerailed') ) && !IsInState('stateRetreat') )
	{
		GotoState('stateRetreat','retreat');
	}
}

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	local bool bSeenByHarry;

	// Determine if Harry sees us
	bSeenByHarry = CanHarrySeeMe(MinDot);

	// If we're staring and Harry sees us, or Harry is too close to us
	if ( ( bIsStaring && bSeenByHarry ) || ( GetDistanceFromHarry() < 128.0 ) )
	{
		// Build anger and clamp it
		CurrentAnger += AngerRate * DeltaTime;
		CurrentAnger = FClamp(CurrentAnger,0.0,RequiredAnger);
	}
	// If we have anger and are not seen by Harry
	else if ( AngerValue > 0.0 && !bSeenByHarry )
	{
		// Lose anger and clamp it
		CurrentAnger -= RelaxRate * DeltaTime;
		CurrentAnger = FClamp(CurrentAnger,0.0,RequiredAnger);
	}

	// If seen by Harry and we should retreat, then retreat and stare
	if ( bSeenByHarry && ShouldRetreat() )
	{
		GotoState('stateRetreat','stare');
	}
}


//////////
// Magic
//////////

function ProcessSpell()
{
	// Increase hits taken
	HitsTaken++;

	// If we've taken enough hits, die
	if ( ShouldDie() )
	{
		GotoState('stateDie');
	}
}


////////////////////
// Helper Functions
////////////////////

function bool ShouldRetreat()
{
	// If we aren't retreating, attacking, killing, or dying, then retreat!
	return !IsInState('stateRetreat') && !IsInState('stateAttack') && !IsInState('stateAttackDerailed') && !IsInState('stateKill') && !IsInState('stateDie');
}

function UpdateNodeViewDistance(float NewDistance)
{
	local MOCAStalkerNode A;
	
	// Set new view distance on all stalker nodes
	foreach AllActors(class'MOCAStalkerNode', A)
	{
		A.SetRequiredDistance(NewDistance);
	}
}


///////////
// States
///////////

auto state stateWait
{
	event BeginState()
	{
		// Loop wait anim
		LoopAnim(WaitAnim, WaitAnimRate);
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		// If Harry is within our active radius
		if ( IsHarryNear(ActiveRadius) )
		{
			// Find a path toward Harry
			navP = NavigationPoint(FindPathToward(PlayerHarry));
			// If we found a path, stalk him
			if ( navP != None )
			{
				GotoState('stateStalk','stalk');
			}
		}
	}

	begin:
		// Stop moving
		StopMoving();
}

state stateStalk
{
	event BeginState()
	{
		// Reset node view distance
		UpdateNodeViewDistance(MOCAStalkerNode.Default.RequiredDistance);
		// Loop sneak anim
		LoopAnim(SneakAnim,SneakAnimRate);
	}

	stalk:
		// Stop previous movement
		StopMoving();

		// While we have a valid navP and Harry is in active radius
		while ( navP != None && IsHarryNear(ActiveRadius) )
		{
			// If we see Harry, derail
			if ( CanISeeHarry(MinDot,True) )
			{
				GotoState('stateStalkDerailed');
			}

			// Strafe to Harry and face him
			StrafeFacing(navP.Location,PlayerHarry);

			// Find next path to Harry
			navP = NavigationPoint(FindPathToward(PlayerHarry));
			// Sleep for a tick
			SleepForTick();
		}

		// Go to wait
		GotoState('stateWait');
}

state stateStalkDerailed
{
	stalk:
		// Stop previous movement
		StopMoving();

		// While Harry is in our active radius and we see him
		while ( IsHarryNear(ActiveRadius) && CanISeeHarry(MinDot,True) )
		{
			// Strafe towards Harry directly
			StrafeFacing(PlayerHarry.Location,PlayerHarry);
			SleepForTick();
		}

		// Go back to stalk
		GotoState('stateStalk','stalk');
}

state stateRetreat
{
	event BeginState()
	{
		// Shorten node view distance
		UpdateNodeViewDistance(GetDistanceFromHarry() - 32.0);
		// Set to chase speed
		GroundSpeed = ChaseSpeed;
		// Play retreat sound
		PlaySound(RetreatSound,SLOT_Talk,1.0);
		// Find retreat destination
		RetreatNavP = GetFurthestNavPoint(PlayerHarry);
		// Find path to retreat
		navP = NavigationPoint(FindPathToward(RetreatNavP));
	}

	event EndState()
	{
		// No longer staring, go back to normal speed
		bIsStaring = False;
		GroundSpeed = MapDefault.GroundSpeed;
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		// 1/32 chance of staring
		RandInt = Rand(32);
		if ( RandInt == 0 )
		{
			// Stare at Harry to build up anger
			GotoState('stateRetreat','stare');
		}
	}

	retreat:
		// Loop retreat anim
		LoopAnim(RetreatAnim,RetreatAnimRate);

		// While valid navP
		while ( navP != None && navP != RetreatNavP )
		{
			// Strafe towards navP and face Harry
			StrafeFacing(navP.Location,PlayerHarry);

			// Find next path
			navP = NavigationPoint(FindPathToward(RetreatNavP));

			SleepForTick();
		}

		// If we're done retreating but Harry still sees us, attack
		if ( CanHarrySeeMe(MinDot) )
		{
			GotoState('stateAttack');
		}

		// Otherwise, enter cooldown
		GotoState('stateCooldown');
	
	stare:
		// We are staring
		bIsStaring = True;
		// Stop moving
		StopMoving();
		// Loop stare anim
		LoopAnim(StareAnim,StareAnimRate);

		// Get rand int, 1/24 chance of going back to retreat
		RandInt = Rand(24);

		// If we're angry enough, attack
		if ( CurrentAnger >= RequiredAnger )
		{
			GotoState('stateAttack');
		}
		// If we rolled a 0, retreat again
		else if ( RandInt == 0 )
		{
			bIsStaring = False;
			Goto('retreat');
		}
		// Otherwise, keep staring
		else
		{
			SleepForTick();
			Goto('stare');
		}
}

state stateAttack
{
	event BeginState()
	{
		// Make node view irrelevant
		UpdateNodeViewDistance(0.0);
		// Use chase speed
		GroundSpeed = ChaseSpeed;
		// Play attack sound
		PlaySound(AttackSound,SLOT_Talk,1.0);
		// Loop attack anim
		LoopAnim(AttackAnim,AttackAnimRate);
	}

	event EndState()
	{
		// Reset movement speed
		GroundSpeed = MapDefault.GroundSpeed;
	}

	begin:
		// Stop previous movement
		StopMoving();

		// While anger is over a third of requried anger and we have valid navP
		while ( CurrentAnger > (RequiredAnger / 3) && navP != None )
		{
			// If we see Harry, derail
			if ( CanISeeHarry(MinDot,True) )
			{
				GotoState('stateAttackDerailed');
			}

			// Strafe to navP
			StrafeFacing(navP.Location,PlayerHarry);

			// Get next navP
			navP = NavigationPoint(FindPathToward(PlayerHarry));

			SleepForTick();
		}

		// Retreat again
		GotoState('stateRetreat','retreat');
}

state stateAttackDerailed
{
	event BeginState()
	{
		// Make sure we are using chase speed
		GroundSpeed = ChaseSpeed;
		// Play attack sound
		PlaySound(AttackSound,SLOT_Talk,1.0);
		// Loop attack anim
		LoopAnim(AttackAnim,AttackAnimRate);
	}

	event EndState()
	{
		// Reset speed
		GroundSpeed = MapDefault.GroundSpeed;
	}

	begin:
		// While we see Harry and anger is over one third of required anger
		while ( CanISeeHarry(MinDot,True) && CurrentAnger > (RequiredAnger / 3) )
		{
			// Strafe towards Harry
			StrafeFacing(PlayerHarry.Location,PlayerHarry);
			SleepForTick();
		}

		// If anger has lowered, go to retreat
		if ( CurrentAnger <= (RequiredAnger / 3) )
		{
			GotoState('stateRetreat','retreat');
		}

		// Otherwise, return to path-based attack
		SleepForTick();
		GotoState('stateAttack');
}

state stateKill
{
	begin:
		// Stop moving
		StopMoving();

		// Keep Harry still
		PlayerHarry.bKeepStationary = True;

		// Get in kill position
		StrafeTo(Location - Vector(Rotation) * (PlayerHarry.CollisionRadius / 2), PlayerHarry.Location);

		// Play kill anim & sound
		PlayAnim(KillAnim,KillAnimRate);
		PlaySound(KillSound,SLOT_Interact,1.0,,TransientSoundRadius);

		// Wait briefly
		Sleep(0.8);
		// Fade to black
		MOCAharry(PlayerHarry).ScreenFade(1.0,0.02);
		Sleep(2.0);
		// Wait 2 seconds and reload save
		ConsoleCommand("LoadGame 0");
}

state stateDie
{
	begin:
		// Stop moving
		StopMoving();
		// Turn to Harry
		TurnToward(PlayerHarry);
		// Play death anim &  sound
		PlayAnim(DieAnim,DieAnimRate);
		PlaySound(DieSound,SLOT_Talk,1.0,,TransientSoundRadius);
		FinishAnim();
		Sleep(0.2);
		// Destroy
		Destroy();
}

state stateCooldown
{
	begin:
		// Stop moving
		StopMoving();
		// Wait for our cooldown
		Sleep(StalkCooldown);
		// Return to wait
		GotoState('stateWait');
}


defaultproperties
{
	AngerRate=3.0
	RelaxRate=1.5
	RequiredAnger=25.0
	ChaseSpeed=400.0
	StalkCooldown=10.0
	MinDot=0.25
	ActiveRadius=163840.0

	ShadowClass=None
	SightRadius=512.0
	CollisionHeight=65.0
	bAdvancedTactics=True
	GroundSpeed=340.0
	MaxTravelDistance=163840.0
	WaitAnimRate=1.0
	SneakAnimRate=1.0
	RetreatAnimRate=1.0
	StareAnimRate=1.0
	AttackAnimRate=1.0
	KillAnimRate=1.0
	DieAnimRate=1.0
}