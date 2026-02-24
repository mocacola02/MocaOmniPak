class MOCAIceSpot extends MOCAPawn;

var() bool bDisableCollision;		// Moca: Should actor collision always be off? Use this if you plan on using a mover. Def: False
var() float Lifetime;				// Moca: How long should iceberg last before melting? Def: 15.0
var() float GrowthTime;				// Moca: How long does it take for iceberg to form? Def: 3.0
var() float Cooldown;				// Moca: How long does it take for the ice spot to reappear? Def: 1.0
var() ESpellType ShatterSpell;		// Moca: What spell to use to shatter the iceberg? Def: SPELL_Flipendo


var Sound FreezeSound;			// Sound to play when freezing
var Sound ShatterSound;			// Sound to play when shattering
var Sound MeltSound;			// Sound to play when melting

var class<ParticleFX> IdleFX;	// ParticleFX when an idle ice spot
var class<ParticleFX> FreezeFX;	// ParticleFX when freezing
var class<ParticleFX> ShatterFX;// ParticleFX when shattering
var class<ParticleFX> MeltFX;	// ParticleFX when melting

var float CurrentGrowthTime;	// Current growth time
var ParticleFX FreezeParticles;	// Freeze particle actor ref
var ParticleFX IdleParticles;	// Idle particle actor ref
var ParticleFX MeltParticles;	// Melt particle actor ref


///////////////////
// Main Functions
///////////////////

function Reset()
{
	// Spawn idle particles and make them emit
	IdleParticles = Spawn(IdleFX,Self,,Location,,True);
	IdleParticles.bEmit = True;
	// Reset spell vulnerability to map default
	eVulnerableToSpell = MapDefault.eVulnerableToSpell;
	// Make us "invisible"
	DrawScale = 0.0;
	// Set collision size to 0.0
	SetCollisionSize(0.0,0.0,0.0);
	// Set our collision to no collision
	SetCollision(False,False,False);
}

function SetBergSize(float DeltaTime, Vector StartSize, Vector EndSize, float StartScale, float EndScale)
{
	// Increment growth time
	CurrentGrowthTime += DeltaTime;

	local float Alpha;
	local float NewRad,NewHgt,NewWid;
	// Get alpha from current growth time over full growth time
	Alpha = CurrentGrowthTime / GrowthTime;

	// If collision isn't disabled
	if ( !bDisableCollision )
	{
		// Get new collision dimensions from lerping our start size to end size using time alpha
		NewRad = Lerp(Alpha,StartSize.X,EndSize.X);
		NewHgt = Lerp(Alpha,StartSize.Y,EndSize.Y);
		NewWid = Lerp(Alpha,StartSize.Z,EndSize.Z);
		// Set new dimensions
		SetCollisionSize(NewRad,NewHgt,NewWid);
	}
	// Change iceberg model size
	DrawScale = Lerp(Alpha,StartScale,EndScale);
}


///////////
// States
///////////

auto state stateIdle
{
	event BeginState()
	{
		// Always reset when we're idle
		Reset();
	}

	event EndState()
	{
		// Shutdown idle particles
		IdleParticles.Shutdown();
		// Make us uncastable
		eVulnerableToSpell = SPELL_None;
	}

	function ProcessSpell()
	{
		// When hit by spell, freeze
		GotoState('stateFreeze');
	}
}

state stateFreeze
{
	event BeginState()
	{
		// Spawn and emit freeze particles
		FreezeParticles = Spawn(FreezeFX,Self,,Location,,True);
		FreezeParticles.bEmit = True;
		// Play freeze sound
		PlaySound(FreezeSound);
		// Emit event, if we have one
		TriggerEvent(Event,Self,Self);
		// If not disabled, enable collision
		if ( !bDisableCollision )
		{
			SetCollision(True,True,True);
		}
	}

	event EndState()
	{
		// Shutdown freeze particles
		FreezeParticles.Shutdown();
		// Stop freeze sound
		StopSound(FreezeSound);
		// Reset growth time
		CurrentGrowthTime = 0.0;
	}

	event Tick(float DeltaTime)
	{
		// If we haven't reached growth time, set berg size from 0 to intended size
		if ( CurrentGrowthTime < GrowthTime )
		{
			SetBergSize(DeltaTime,Vec(0,0,0),Vec(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth),0.0,MapDefault.DrawScale);
		}
		// Otherwise, go to frozen state
		else
		{
			GotoState('stateFrozen');
		}
	}
}

state stateMelt
{
	event BeginState()
	{
		// Spawn and emit melt particles
		MeltParticles = Spawn(MeltFX,Self,,Location,,True);
		MeltParticles.bEmit = True;
		// Play melting sound
		PlaySound(MeltSound);
	}

	event EndState()
	{
		// Shutdown melt particles
		MeltParticles.Shutdown();
		// Stop melting sound
		StopSound(MeltSound);
		// Reset growth time
		CurrentGrowthTime = 0.0;
	}

	event Tick(float DeltaTime)
	{
		// If we haven't reached growth time, set berg size from frozen size to 0
		if ( CurrentGrowthTime < GrowthTime )
		{
			SetBergSize(DeltaTime,Vec(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth),Vec(0,0,0),MapDefault.DrawScale,0.0);
		}
		// Otherwise, go to idle
		else
		{
			GotoState('stateIdle');
		}
	}
}

state stateFrozen
{
	event BeginState()
	{
		// Make sure our drawscale is correct
		DrawScale = MapDefault.DrawScale;
		// If not disabled collision, make sure size is correct
		if ( !bDisableCollision )
		{
			SetCollisionSize(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth);
		}
		// Change spell vulnerability to shatter spell
		eVulnerableToSpell = ShatterSpell;
	}
	
	event EndState()
	{
		// Make us uncastable
		eVulnerableToSpell = SPELL_None;
	}

	function ProcessSpell()
	{
		// Go to shatter state
		GotoState('stateShatter');
	}

	begin:
		// Sleep for our lifetime, then melt
		Sleep(Lifetime);
		GotoState('stateMelt');
}

state stateShatter
{
	event BeginState()
	{
		// Play shatter sound
		PlaySound(ShatterSound);
		// Spawn shatter particles
		Spawn(ShatterFX);
		// Set drawscale to 0
		DrawScale = 0.0;
		// If not disabled collision, reset collision
		if ( !bDisableCollision )
		{
			SetCollisionSize(0,0,0);
			SetCollision(False,False,False);
		}
	}

	begin:
		// Wait for our cooldown and go back to idle
		Sleep(Cooldown);
		GotoState('stateIdle');
}


defaultproperties
{
	Lifetime=15.0
	GrowthTime=3.0
	Cooldown=1.0

	FreezeSound=Sound'MocaSoundPak.ice_freeze'
	ShatterSound=Sound'MocaSoundPak.salamander_explode'

	IdleFX=class'IceBerg_Spot'
	FreezeFX=class'Iceberg_Grow'
	ShatterFX=class'Ice_Break'
	MeltFX=class'BasilEyeSmoke'

	ShatterSpell=SPELL_Flipendo
	bGestureFaceHorizOnly=False
	CollisionHeight=8.0
	CollisionRadius=150.0
	CollisionWidth=0.0
	PrePivot=(X=0,Y=0,Z=0)
	eVulnerableToSpell=SPELL_LocomotorWibbly
	Mesh=SkeletalMesh'MocaModelPak.skIceberg1'
}