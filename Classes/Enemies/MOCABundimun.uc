//================================================================================
// MOCABundimun.
//================================================================================
class MOCABundimun extends MOCAChar;

var() bool bStayAboveGround;	// Moca: Should Bundi always stay above ground? Def: False
var() float TriggerDistance;	// Moca: How close does Harry need to be for Bundi to appear? Def: 500.0
var() float StunDuration;		// Moca: How long do we stay stunned for when hit? Def: 5.0
var() float SpinRate;			// Moca: How fast do we spin? Def: 5500.0
var() float BumpDamage;			// Moca: How much damage do we deal on a bump? Def: 15.0
var() float PukeDamage;			// Moca: How much damage does puke do? Def: 7.5


var bool bCanHit;				// Can we hit Harry right now

var BundimunDeath KillEmit;		// Particles for kill
var BundimunDig DigEmit;		// Particles for dig
var BundimunShrink ShrinkEmit;	// Particles for shrink


event PostBeginPlay()
{
	Super.PostBeginPlay();

	local Vector DigLocation;
	local Rotator DigRotation;

	// Dig location is our current position
	DigLocation = Location;
	// Subtract half height plus 1 for clearance
	DigLocation.Z -= (CollisionHeight * 0.5) + 1;
	// Set correct dig rotation
	DigRotation.Pitch = 16384;

	// Create dig emitter
	DigEmit = Spawn(Class'BundimunDig',Self,,DigLocation,DigRotation);

	// If mapper didn't use MOCAharry, yell at them
	if ( !PlayerHarry.IsA('MOCAharry') )
	{
		EnterErrorMode("MOCABundimun requires MOCAharry. Please replace harry with MOCAharry.");
	}
}

event Bump(Actor Other)
{
	// If other is harry and we're not stunned or anything, deal bump damage
	if ( Other == PlayerHarry && IsInState('stateSpitting') )
	{
		DoBumpDamage(Location,'BundiBody');
	}
}

function ProcessStomp()
{
	// Die if stomped on
	GotoState('stateDie');
}

function DoBumpDamage(Vector DamageLocation, name DamageName)
{
	// If we're allowed to hit Harry
	if ( bCanHit )
	{
		// Deal damage
		PlayerHarry.TakeDamage(BumpDamage,Self,DamageLocation,Velocity,DamageName);
		// We can't hit Harry anymore right now
		bCanHit = False;
		// Set timer to reset bCanHit
		SetTimer(1.0,False,'ResetBumpHit');
	}
}

function ResetBumpHit()
{
	// We can hit Harry again
	bCanHit = True;
}

function ProcessSpell()
{
	// If hit, go to stunned
	GotoState('stateStunned');
}

function Puke()
{
	local Vector PukeLocation;
	local MOCABundimunSpit NewSpit;

	// Puke location start is at our snout
	PukeLocation = BonePos('SnoutEnd');
	
	// Spawn spit projectile
	NewSpit = Spawn(Class'MocaOmniPak.MOCABundimunSpit',Self,,PukeLocation,Rotation);
	// Set spit damage
	NewSpit.DamageToDeal = PukeDamage;
}

function SpawnKillParticles()
{
	local Rotator SpawnRotation;
	// Set spawn rotation to face correct way
	SpawnRotation.Pitch = 16384;
	SpawnRotation.Yaw = 0;
	SpawnRotation.Roll = 0;
	// Spawn emitter
	KillEmit = Spawn(class'MocaOmniPak.BundimunDeath',Self,,Location,SpawnRotation,True);
}

auto state stateIdle
{
	event BeginState()
	{
		// If stay above ground, go ahead and rise
		if ( bStayAboveGround )
		{
			GotoState('stateDig','rise');
		}
		// Otherwise go to underground state
		else
		{
			GotoState('stateUnderGround');
		}
	}
}

state stateUnderGround
{
	event BeginState()
	{
		// Loop underground anim
		LoopAnim('Underground');
		// Hide self
		bHidden = True;
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

		// If Harry is near, dig up
		if ( IsHarryNear(TriggerDistance) )
		{
			GotoState('stateDig','rise');
		}
	}
}

state stateDig
{
	event BeginState()
	{
		// Emit dig emitter
		DigEmit.bEmit = True;
		// Unhide self
		bHidden = False;
	}

	event EndState()
	{
		// Stop dig emitter
		DigEmit.bEmit = False;
	}

	rise:
		// Enable our collision
		SetCollision(True,True,True);
		// Play rise sound
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_rise');
		// Play rise anim and wait to finish it
		PlayAnim('Rise');
		FinishAnim();
		// Start spitting
		GotoState('stateSpitting');
	
	sink:
		// Disable our collision
		SetCollision(False,False,False);
		// Play sink sound
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_sink');
		// Play sink anim and wait to finish it
		PlayAnim('Sink');
		FinishAnim();
		// Go to underground state
		GotoState('stateUnderGround');
}

state stateSpitting
{
	event BeginState()
	{
		// Make sure we're allowed to hit Harry
		bCanHit = True;
		// Set ambient sound to spit sound
		AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_shoot';
		// Make us shootable
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
		// Loop attack anim
		LoopAnim('Attack');
	}

	event EndState()
	{
		// Disable sound and casting
		AmbientSound = None;
		eVulnerableToSpell = None;
	}

	event Tick(float DeltaTime)
	{
		// If Harry is no longer near and we don't stay above ground, sink
		if ( !IsHarryNear(TriggerDistance) && !bStayAboveGround )
		{
			GotoState('stateDig','sink');
		}

		//SPEEN
		DesiredRotation = Rotation;
		DesiredRotation.Yaw += (SpinRate * DeltaTime);
		SetRotation(DesiredRotation);
	}
}

state stateStunned
{
	event BeginState()
	{
		// Disable emitter
		DigEmit.bEmit = False;
		// Make us able to be stood on
		bCantStandOnMe = False;
		// Play hit sound
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_hit');
		// Loop dazed sound
		AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_dazed';
		// Loop dazed anim
		LoopAnim('Dazed');
	}

	event EndState()
	{
		// Make us unable to be stood on
		bCantStandOnMe = True;
	}

	begin:
		// Wait for the stun duration
		Sleep(StunDuration);
		// Start attacking again
		GotoState('stateSpitting');
}

state stateDie
{
	event BeginState()
	{
		// Disable tick event
		Disable('Tick');
		// Spawn shrink emitter
		ShrinkEmit = Spawn(class'BundimunShrink',Self,,Location,,True);
		// Play death sound
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_smash');
		// Play bounced on anim
		PlayAnim('Bounce');
		// Spawn kill particles
		SpawnKillParticles();
	}

	event Tick (float DeltaTime)
	{
		// Make us shrink
		DrawScale -= (1.0 * DeltaTime);
	}

	begin:
		// Delay for two seconds
		Sleep(2.0);
		// Can't stand on me anymore
		bCantStandOnMe = True;
		// Stop emitting
		KillEmit.bEmit = False;
		// Finish anim
		FinishAnim();
		// Go to shrink
		Goto('shrink');

	shrink:
		// Enable tick event so we shrink
		Enable('Tick');

		// If we're now invisible, kill
		if (DrawScale <= 0.0)
		{
			Goto('kill');
		}
		// If we're smalling than 0.25 scale, stop emitting
		else if (DrawScale < 0.25)
		{
			ShrinkEmit.bEmit = False;
		}

		// Sleep for tick and then loop to shrink label
		SleepForTick();
		Goto('shrink');

	kill:
		// Destroy all emitters and self
		ShrinkEmit.Destroy();
		KillEmit.Destroy();
		DigEmit.Destroy();
		Destroy();
}

defaultproperties
{
	TriggerDistance=500.0
	StunDuration=5.0
	SpinRate=5500.0
	BumpDamage=15.0
	PukeDamage=7.5

	bCantStandOnMe=True
	ShadowScale=0.0
	DrawScale=0.6
	SoundRadius=12
	SoundVolMult=1.3
	CollisionHeight=18
	CollisionRadius=30
	
	Mesh=SkeletalMesh'MocaModelPak.skBundimun'
	eVulnerableToSpell=SPELL_Rictusempra
}