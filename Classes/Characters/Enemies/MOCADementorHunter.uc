//================================================================================
// MOCADementorHunter.
//
// Quick and dirty job, but it gets the job done.
//================================================================================
class MOCADementorHunter extends MOCAHunter;

var() int DamagePerSec;
var() float AttackRange;
var() float RequiredEscapeInput;
var() float StunDuration;
var() float MaxBWPct;

var name StunAnim;

var float CurrEscapeInput;
var float BWPct;

var Weapon PrevWeapon;
var MOCADementorAttack AttackParticles;


event Bump(Actor Other);

event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if ( !IsInState('stateAttack') && IsHarryNear(AttackRange) )
	{
		GotoState('stateAttack');
	}

	BWPct = FClamp(BWPct - DeltaTime * 2.0, 0.0, MaxBWPct);
	PlayerHarry.SetBWPercent(BWPct);
}


state stateChase
{
	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		Super.Tick(DeltaTime);
	}
}


state stateAttack
{
	event BeginState()
	{
		if ( AttackParticles != None )
		{
			AttackParticles.Shutdown();
		}

		AttackParticles = Spawn(Class'MOCADementorAttack', PlayerHarry);
		AttackParticles.Gravity = (Location - PlayerHarry.Location) * 2.0;

		PlayerHarry.bCorraledByMover = True;

		PrevWeapon = PlayerHarry.Weapon;

		PlayerHarry.StopAiming();
		PlayerHarry.Weapon = None;

		PlayerHarry.HarryAnimType = AT_Combine;
		PlayerHarry.HarryAnimChannel.LoopAnim('SleepyWalk', 1.5);

		PlayerHarry.ShakeView(9999.0, 42.0, 42.0);

		SetTimer(1.0, True);
	}

	event EndState()
	{
		if ( AttackParticles != None )
		{
			AttackParticles.Shutdown();
			AttackParticles = None;
		}

		CurrEscapeInput = 0.0;

		PlayerHarry.bCorraledByMover = False;
		PlayerHarry.Weapon = PrevWeapon;

		PlayerHarry.HarryAnimType = AT_Replace;
		PlayerHarry.HarryAnimChannel.GotoState('stateIdle');

		PlayerHarry.ShakeView(0.0, 0.0, 0.0);
	}

	event Tick(float DeltaTime)
	{
		HandleInput(DeltaTime);

		BWPct = FClamp(BWPct + DeltaTime * 2.0, 0.0, MaxBWPct);
		PlayerHarry.SetBWPercent(BWPct);
	}

	event Timer()
	{
		// Setting directly to avoid damage animation
		PlayerHarry.AddHealth(-DamagePerSec);
	}

	function HandleInput(float DeltaTime)
	{
		local float NewInput;

		// Getting the actual input wasn't working, so I'm working around that using velocity instead
		NewInput = VSize(Vec(PlayerHarry.Velocity.X, PlayerHarry.Velocity.Y, 0.0)) * DeltaTime;

		PlayerHarry.Velocity.X = 0;
		PlayerHarry.Velocity.Y = 0;

		CurrEscapeInput += NewInput;

		DebugLog("CurrEscapeInput: " $ CurrEscapeInput $ " vs " $ RequiredEscapeInput);

		if ( CurrEscapeInput >= RequiredEscapeInput )
		{
			GotoState('stateStunned');
		}
	}

	begin:
		StopMoving();
		TurnToward(PlayerHarry);
}


state stateStunned
{
	event Tick(float DeltaTime)
	{
		BWPct = FClamp(BWPct - DeltaTime * 2.0, 0.0, MaxBWPct);
		PlayerHarry.SetBWPercent(BWPct);
	}

	begin:
		PlayAnim(StunAnim);

		if ( StunDuration < 0.0 )
		{
			FinishAnim();
		}
		else
		{
			Sleep(StunDuration);
		}

		GotoState('stateIdle');
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bDebugLogging=True

	DamagePerSec=10
	AttackRange=256.0
	RequiredEscapeInput=28.0
	StunDuration=-1.0
	MaxBWPct=0.667

	StunAnim="ExitWardrobe"

	HuntIdleAnims(0)="Idle"
	HuntIdleAnims(1)="patrol"

	CatchAnim="IdleHit"
	WakeUpAnim="WakeUp"

	bAlignBottomAlways=True

	CollisionRadius=21
	CollisionHeight=54
	CollideType=CT_OrientedCylinder

	AmbientGlow=32
	Mesh=SkeletalMesh'MocaOmniResources.skDementorMesh'

	IdleAnimName="Idle"
	WalkAnimName="AttackApproachFly"
	RunAnimName="BlownBack"
}