//================================================================================
// MOCABundimun.
//================================================================================

class MOCABundimun extends MOCAChar;

var() bool bStayAboveGround;
var() float TriggerDistance;
var() float StunDuration;
var() float SpinRate;
var() float BumpDamage;
var() float PukeDamage;

var bool bCanHit;

var BundimunDeath KillEmit;
var BundimunDig DigEmit;
var BundimunShrink ShrinkEmit;


event PostBeginPlay()
{
	Super.PostBeginPlay();

	local Vector DigLocation;
	local Rotator DigRotation;

	DigLocation = Location;
	DigLocation.Z -= (CollisionHeight * 0.5) + 1;
	DigRotation.Pitch = 16384;

	DigEmit = Spawn(Class'BundimunDig',Self,,DigLocation,DigRotation);

	if ( !PlayerHarry.IsA('MOCAharry') )
	{
		EnterErrorMode("MOCABundimun requires MOCAharry. Please replace harry with MOCAharry.");
	}
}

event Bump(Actor Other)
{
	if ( Other == PlayerHarry && IsInState('stateSpitting') )
	{
		DoBumpDamage(Location,'BundiBody');
	}
}

function ProcessStomp()
{
	GotoState('stateDie');
}

function DoBumpDamage(Vector DamageLocation, name DamageName)
{
	if ( bCanHit )
	{
		PlayerHarry.TakeDamage(BumpDamage,Self,DamageLocation,Velocity,DamageName);
		bCanHit = False;
		SetTimer(1.0,False,'ResetBumpHit');
	}
}

function ResetBumpHit()
{
	bCanHit = True;
}

function ProcessSpell()
{
	GotoState('stateStunned');
}

function Puke()
{
	local Vector PukeLocation;
	local MOCABundimunSpit NewSpit;

	PukeLocation = BonePos('SnoutEnd');
	
	NewSpit = Spawn(Class'MocaOmniPak.MOCABundimunSpit',Self,,PukeLocation,Rotation);
	NewSpit.DamageToDeal = PukeDamage;
}

function SpawnKillParticles()
{
	local Rotator SpawnRotation;

	SpawnRotation.Pitch = 16384;
	SpawnRotation.Yaw = 0;
	SpawnRotation.Roll = 0;
	KillEmit = Spawn(class'MocaOmniPak.BundimunDeath',Self,,Location,SpawnRotation,True);
}

auto state stateIdle
{
	event BeginState()
	{
		if ( bStayAboveGround )
		{
			GotoState('stateDig','rise');
		}
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
		LoopAnim('Underground');
		bHidden = True;
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);

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
		DigEmit.bEmit = True;
		bHidden = False;
	}

	event EndState()
	{
		DigEmit.bEmit = False;
	}

	rise:
		SetCollision(True,True,True);
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_rise');
		PlayAnim('Rise');
		FinishAnim();
		GotoState('stateSpitting');
	
	sink:
		SetCollision(False,False,False);
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_sink');
		PlayAnim('Sink');
		FinishAnim();
		GotoState('stateUnderGround');
}

state stateSpitting
{
	event BeginState()
	{
		bCanHit = True;
		AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_shoot';
		eVulnerableToSpell = MapDefault.eVulnerableToSpell;
		LoopAnim('Attack');
	}

	event EndState()
	{
		AmbientSound = None;
		eVulnerableToSpell = None;
	}

	event Tick(float DeltaTime)
	{
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
		DigEmit.bEmit = False;
		bCantStandOnMe = False;
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_hit');
		AmbientSound = Sound'MocaSoundPak.Creatures.bundimun_dazed';
		LoopAnim('Dazed');
	}

	event EndState()
	{
		bCantStandOnMe = True;
	}

	begin:
		Sleep(StunDuration);
		GotoState('stateSpitting');
}

state stateDie
{
	event BeginState()
	{
		Disable('Tick');
		ShrinkEmit = Spawn(class'BundimunShrink',Self,,Location,,True);
		PlaySound(Sound'MocaSoundPak.Creatures.bundimun_smash');
		PlayAnim('Bounce');
		SpawnKillParticles();
	}

	event Tick (float DeltaTime)
	{
		DrawScale -= (1.0 * DeltaTime);
	}

	begin:
		Sleep(2.0);
		bCantStandOnMe = True;
		KillEmit.bEmit = False;
		FinishAnim();
		Goto('shrink');

	shrink:
		Enable('Tick');

		if (DrawScale <= 0.0)
		{
			Goto('kill');
		}
		else if (DrawScale < 0.25)
		{
			ShrinkEmit.bEmit = False;
		}

		SleepForTick();
		Goto('shrink');

	kill:
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
	PukeDamage=75.0

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