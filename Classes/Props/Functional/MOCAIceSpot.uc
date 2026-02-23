class MOCAIceSpot extends MOCAPawn;

var() bool bDisableCollision;
var() float Lifetime;
var() float GrowthTime;
var() float Cooldown;

var() Sound FreezeSound;
var() Sound ShatterSound;
var() Sound MeltSound;

var() class<ParticleFX> IdleFX;
var() class<ParticleFX> FreezeFX;
var() class<ParticleFX> ShatterFX;
var() class<ParticleFX> MeltFX;

var() eVulnerableToSpell ShatterSpell;


var float CurrentGrowthTime;
var ParticleFX FreezeParticles;
var ParticleFX IdleParticles;
var ParticleFX MeltParticles;


function Reset()
{
	IdleParticles = Spawn(IdleFX,Self,,Location,,True);
	IdleParticles.bEmit = True;
	eVulnerableToSpell = MapDefault.eVulnerableToSpell;
	DrawScale = 0.0;
	SetCollisionSize(0.0,0.0,0.0);
}

function SetBergSize(float DeltaTime, Vector StartSize, Vector EndSize, float StartScale, float EndScale)
{
	CurrentGrowthTime += DeltaTime;

	local float Alpha;
	local float NewRad,NewHgt,NewWid;
	Alpha = CurrentGrowthTime / GrowthTime;

	NewRad = Lerp(Alpha,StartSize.X,EndSize.X);
	NewHgt = Lerp(Alpha,StartSize.Y,EndSize.Y);
	NewWid = Lerp(Alpha,StartSize.Z,EndSize.Z);

	SetCollisionSize(NewRad,NewHgt,NewWid);

	DrawScale = Lerp(Alpha,StartScale,EndScale);
}

auto state stateIdle
{
	event BeginState()
	{
		Reset();
	}

	event EndState()
	{
		IdleParticles.Shutdown();
		eVulnerableToSpell = SPELL_None;
	}

	function ProcessSpell()
	{
		GotoState('stateFreeze');
	}
}

state stateFreeze
{
	event BeginState()
	{
		FreezeParticles = Spawn(FreezeFX,Self,,Location,,True);
		FreezeParticles.bEmit = True;
		PlaySound(FreezeSound);
		TriggerEvent(Event,Self,Self);
	}

	event EndState()
	{
		FreezeParticles.Shutdown();
		StopSound(FreezeSound);
		CurrentGrowthTime = 0.0;
	}

	event Tick(float DeltaTime)
	{
		if ( CurrentGrowthTime < GrowthTime )
		{
			ChangeBergSize(DeltaTime,vect(0,0,0),vect(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth),0.0,MapDefault.DrawScale);
		}
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
		MeltParticles = Spawn(MeltFX,Self,,Location,,True);
		MeltParticles.bEmit = True;
		PlaySound(MeltSound);
	}

	event EndState()
	{
		MeltParticles.Shutdown();
		StopSound(MeltSound);
		CurrentGrowthTime = 0.0;
	}

	event Tick(float DeltaTime)
	{
		if ( CurrentGrowthTime < GrowthTime )
		{
			ChangeBergSize(DeltaTime,vect(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth),vect(0,0,0),MapDefault.DrawScale,0.0);
		}
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
		DrawScale = MapDefault.DrawScale;
		SetCollisionSize(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth);
		eVulnerableToSpell = ShatterSpell;
	}
	
	event EndState()
	{
		eVulnerableToSpell = SPELL_None;
	}

	function ProcessSpell()
	{
		GotoState('stateShatter');
	}

	begin:
		Sleep(Lifetime);
		GotoState('stateMelt');
}

state stateShatter
{
	event BeginState()
	{
		PlaySound(ShatterSound);
		Spawn(ShatterFX);
		DrawScale = 0.0;
		SetCollisionSize(0,0,0);
	}

	begin:
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