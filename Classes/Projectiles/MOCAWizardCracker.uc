//================================================================================
// MOCAWizardCracker.
//================================================================================
class MOCAWizardCracker extends MOCAPawn;

var() bool bActAsSpell;				// Moca: Act as a spell (similar to sword beams). Def: False
var() bool bBurstFalloff;			// Moca: Apply falloff to burst damage. Def: True
var() bool bExplodeOnTouch;			// Moca: Should it explode when touched at all? Def: False

var() float BurstDamage;			// Moca: How much damage to deal when bursting? Def: 15.0
var() float DirectHitDamage;		// Moca: How much damage to deal on a direct hit? Def: 20.0
var() float BurstRadius;			// Moca: How far does the burst reach? Def: 128.0
var() float BurstDelay;				// Moca: How long does it take after swelling to burst? Def: 5.0
var() float CameraShakeIntensity;	// Moca: Intensity of burst camera shake. Def: 100.0
var() float CameraShakeDuration;	// Moca: Duration of burst camera shake. Def: 0.75


var bool bCanHitHarry;	// Can we hit harry right now?
var bool bDirectHit;	// Was hit a direct hit?
var bool bIsSwelling;	// Are we swelling right now?

var Sound LandSound;	// Sound to play when landing on ground
var Sound SwellSound;	// Sound to play when swelling
var Sound PulseSound;	// Sound to play when pulsing post-swell
var Sound PopSound;		// Sound to play on burst


///////////
// Events
///////////

event FellOutOfWorld()
{
	// Reset location to Harry's hand instead of falling OOB
	SetLocation(PlayerHarry.BonePos('bip01 R Hand'));
}

event Timer()
{
	// Explode the cracker
	GotoState('stateBurst');
}

function Burst()
{
	local float DistanceFromHarry;

	// Stop swelling & pulsing sound
	StopSound(SwellSound);
	StopSound(PulseSound);

	// If bActAsSpell, do the spell effect
	if ( bActAsSpell )
	{
		AutoHitAreaEffect(BurstRadius);
	}

	// Get distance from Harry
	DistanceFromHarry = VSize(Location - PlayerHarry.Location);

	// If Harry is within our radius
	if ( DistanceFromHarry < BurstRadius )
	{
		local float DamageToDeal;
		local float ShakeAmount;
		// Determine damage based on Harry's distance to cracker
		DamageToDeal = DetermineDamage(DistanceFromHarry);
		// Deal damage
		PlayerHarry.TakeDamage(DamageToDeal,Self,Location,Velocity,'WizardCracker');

		// Determine shake amount based on damage
		ShakeAmount = DamageToDeal / BurstDamage;
		// Add intensity mult
		ShakeAmount *= CameraShakeIntensity;
		// Shake cam
		PlayerHarry.ShakeView(CameraShakeDuration,ShakeAmount,ShakeAmount);
	}

	// Play pop sound
	PlaySound(PopSound,SLOT_Interact);
	// Spawn burst particles
	Spawn(class'Firecracker_Burst',,,Location);
	// Destroy self
	GotoState('stateKill');
}

function AutoHitAreaEffect(float Radius)
{
	local HPawn Pawn;
	local spellTrigger spTrigger;

	// For all HPawns
	foreach AllActors(Class'HPawn',Pawn)
	{
		// If within radius
		if ( VSize(Pawn.Location - Location) < Radius )
		{
			// If it has a spell vulnerability
			if ( Pawn.eVulnerableToSpell != SPELL_None )
			{
				// Handle spell
				Pawn.CallHandleSpellBySpellType(Pawn.eVulnerableToSpell,Pawn.Location);
			}
			// If a bean or wizard card, bounce them (unless being collected)
			if ( (Pawn.Owner == None) && (Pawn.IsA('Jellybean') || Pawn.IsA('WizardCardIcon')) )
			{
				Pawn.SetPhysics(PHYS_Falling);
				Pawn.Velocity = Vec(0.0,0.0,300.0) + Normal(Pawn.Location - Location) * 100 * FRand();
			}
		}	
	}
	// For all spell triggers
	foreach AllActors(Class'spellTrigger',spTrigger)
	{
		// If vulnerable to spell and within range
		if ( spTrigger.eVulnerableToSpell != SPELL_None && (VSize(spTrigger.Location - Location) < Radius) )
		{
			// Activate them
			spTrigger.Activate(Self,Self);
		}
	}
}

function bool IsValidPawn(Actor Other)
{
	// Return true if Other is a HPawn or Harry
	return Other.IsA('HPawn') || Other.IsA('harry');
}

function float DetermineDamage(float Distance)
{
	// If direct hit, do direct hit damage
	if ( bDirectHit )
	{
		return DirectHitDamage;
	}

	// If no burst falloff, apply full burst damage
	if ( !bBurstFalloff )
	{
		return BurstDamage;
	}

	// Otherwise, calculte burst damage with falloff
	return BurstDamage * ((BurstRadius - Distance) / BurstRadius);
}

auto state stateIdle
{
	event BeginState()
	{
		LoopAnim('Idle');
		// If not explode on touch, we can pick it up
		bObjectCanBePickedUp = !bExplodeOnTouch;
	}

	event EndState()
	{
		// Only allow pickup in idle
		bObjectCanBePickedUp = False;
	}

	event Touch(Actor Other)
	{
		// If explode on touch & other is valid pawn
		if ( bExplodeOnTouch && IsValidPawn(Other) )
		{
			// Direct hit if other is harry! & burst
			bDirectHit = Other.IsA('harry');
			GotoState('stateBurst');
		}
	}
}

state stateBurst
{
	event BeginState()
	{
		// If Harry is carrying us, make him drop us
		if ( PlayerHarry.ActorToCarry == Self )
		{
			PlayerHarry.DropCarryingActor(True);
		}
		// Burst
		Burst();
	}
}

state stateBeingThrown
{
	event BeginState()
	{
		// Enable cooldown for hitting harry so it doesn't explode on throw
		bCanHitHarry = False;
		// Enable collision, but don't block
		SetCollision(True,False,False);
	}

	event Touch(Actor Other)
	{
		// If other is valid pawn and we can hit Harry
		if ( IsValidPawn(Other) && bCanHitHarry )
		{
			// Direct hit if other is harry! & burst
			bDirectHit = Other.IsA('harry');
			GotoState('stateBurst');
		}
	}

	event Landed(Vector HitNormal)
	{
		// If landed, start swelling
		PlaySound(LandSound,SLOT_Interact);
		GotoState('stateSwell');
	}

	begin:
		// Wait for cooldown, then enable hits
		Sleep(0.25);
		bCanHitHarry = True;
}

state stateSwell
{
	begin:
		// Enable collision but don't block
		SetCollision(True,False,False);
		// Enable pick up
		bObjectCanBePickedUp = True;

		// If not swelling already, start swelling
		if ( !bIsSwelling )
		{
			bIsSwelling = True;
			SetTimer(BurstDelay,False);
			PlaySound(SwellSound,SLOT_Misc);
			PlayAnim('swell');
			FinishAnim();
			PlaySound(PulseSound,SLOT_Misc,[Loop] True);
			LoopAnim('shake');
		}
}

state stateKill
{
	begin:
		// Destroy self
		SleepForTick();
		Destroy();
}


defaultproperties
{
	bBurstFalloff=True
	BurstDamage=15.0
	DirectHitDamage=20.0
	BurstRadius=128.0
	BurstDelay=5.0
	CameraShakeIntensity=100.0
	CameraShakeDuration=0.75

	SwellSound=Sound'wizard_cracker_swell_multi'
	PopSound=Sound'wizard_cracker_pop'
	LandSound=Sound'wizard_cracker_land_multi'
	PulseSound=Sound'wizard_cracker_pulse'

	bBlockActors=False
	bBlockPlayers=False
	bBlockCamera=False
	bObjectCanBePickedUp=True
	CollideType=CT_Box
	CollisionHeight=6
	CollisionRadius=6
	CollisionWidth=20
	attachedParticleClass(0)=Class'HPParticle.WizCrackSparkle'
	Mesh=SkeletalMesh'MocaModelPak.skwizardcrackerMesh'
}