class MOCAGeyser extends MOCAFunctionalProp;

// TODO: Redo touched actor collection using a trace instead?

var() bool bUseTouch;			// Moca: Will touching our collision enable us to shoot? Otherwise, we must be triggered first. Def: True
var() bool bDisableFallDamage;	// Moca: Should we disable fall damage on Harry while shooting? Def: False
var() float Distance;			// Moca: How far up to shoot? Def: 128.0
var() float Force;				// Moca: How much force to apply. Def: 128.0
var() float BuildUpDuration;	// Moca: How long to wait when activated before shooting. Def: 2.0
var() float ShootDuration;		// Moca: How long to shoot for? Def: 3.0
var() float CooldownDuration;	// Moca: How long before we can be triggered again? Def: 2.0
var() Texture ParticleTexture;	// Moca: What texture to use for shoot particles? Def: Texture'HPParticle.Smoke5'
var() array<name> ClassesToAffect;	// Moca: What classes can be pushed?

var array<Actor> TouchedActors;

var float SteamGravity;
var MOCASteamGeyser SteamFX;


//=========
// Events
//=========

event PostBeginPlay()
{
	if ( bDebugLogging )
	{
		Spawn(Class'DebugSprite', self,, Location + Vec(0.0, 0.0, Distance),, True);
	}

	if ( SteamFX == None )
	{
		SteamFX = Spawn(Class'MOCASteamGeyser',Self,,Location,,True);
		SteamFX.EnableEmission(False);
		SteamFX.Textures[0] = ParticleTexture;
		SteamGravity = SteamFX.Default.GravityModifier * (Distance / Default.Distance);
	}
}

event Touch(Actor Other)
{
	if ( OtherIsValid(Other) )
	{
		AddOtherToList(Other);
		
		if ( IsInState('stateIdle') )
		{
			GotoState('stateBuildUp');
		}
	}
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	if ( !IsInState('stateIdle') )
	{
		GotoState('stateCooldown');
	}
	else
	{
		GotoState('stateBuildUp');
	}
}

event Tick(float DeltaTime)
{
	local int i;

	for ( i = 0; i < TouchedActors.Length; i++ )
	{
		if ( !ActorIsInRange(TouchedActors[i]) )
		{
			RemoveOtherFromList(TouchedActors[i]);
		}
	}
}

//=========
// States
//=========

auto state stateIdle
{
}

state stateBuildUp
{
	event BeginState()
	{
		SteamFX.GravityModifier = -0.125;
		SteamFX.EnableEmission(True);
	}

	event EndState()
	{
		SteamFX.EnableEmission(False);
	}
	

	begin:
		Sleep(BuildUpDuration);
		GotoState('stateShoot');
}

state stateShoot
{
	event BeginState()
	{
		if ( SteamFX != None )
		{
			SteamFX.EnableEmission(True);
		}

		SteamFX.GravityModifier = SteamGravity;

		PrepAll();
	}

	event EndState()
	{
		if ( SteamFX != None )
		{
			SteamFX.EnableEmission(False);
		}

		UnPrepAll();
	}

	event Tick(float DeltaTime)
	{
		Global.Tick(DeltaTime);
		TraceForOthers();

		local int i;

		for ( i = 0; i < TouchedActors.Length; i++ )
		{
			local float FinalForce;
			FinalForce = CalculateForce(TouchedActors[i]);

			if ( FinalForce > 0.0 )
			{
				if ( TouchedActors[i].Physics == PHYS_Falling )
				{
					PrepOther(TouchedActors[i]);
					TouchedActors[i].Velocity.Z *= 0.75;
				}

				TouchedActors[i].Velocity.Z += CalculateForce(TouchedActors[i]) * DeltaTime;
			}
			else
			{
				UnPrepOther(TouchedActors[i]);
			}
		}
	}

	begin:
		Sleep(ShootDuration);
		GotoState('stateCooldown');
}

state stateCooldown
{
	begin:
		Sleep(CooldownDuration);
		GotoState('stateIdle');
}


//==========
// Helpers
//==========

function AddOtherToList(Actor Other)
{
	if ( !ActorIsInList(Other) )
	{
		DebugLog("Adding " $ Other $ " to my list.");

		TouchedActors.AddItem(Other);

		DebugLog("List size is now " $ TouchedActors.Length);
	}
}

function RemoveOtherFromList(Actor Other)
{
	if ( ActorIsInList(Other) )
	{
		DebugLog("Removing " $ Other $ " from my list.");

		TouchedActors.RemoveItem(Other);
		UnPrepOther(Other);

		DebugLog("List size is now " $ TouchedActors.Length);
	}
}

function PrepOther(Actor Other)
{
	Other.SetPhysics(PHYS_Flying);

	if ( Other == PlayerHarry )
	{
		PlayerHarry.LoopAnim('spongify');
	}
}

function PrepAll()
{
	local int i;

	for ( i = 0; i  < TouchedActors.Length; i++ )
	{
		PrepOther(TouchedActors[i]);
	}
}

function UnPrepOther(Actor Other)
{
	Other.SetPhysics(PHYS_Falling);
}

function UnPrepAll()
{
	local int i;

	for ( i = 0; i < TouchedActors.Length; i++ )
	{
		UnPrepOther(TouchedActors[i]);
	}
}

// Lazy check for an in-range actor
function TraceForOthers()
{
	local Vector TracePos, TraceN;
	local Actor TracedActor;

	foreach TraceActors(class'Actor', TracedActor, TracePos, TraceN, (Location) + Vec(0.0, 0.0, Distance), Location)
	{
		if ( OtherIsValid(TracedActor) && !ActorIsInList(TracedActor) )
		{
			TouchedActors.AddItem(TracedActor);
		}
	}
}

function bool OtherIsValid(Actor Other)
{
	local int i;

	for ( i = 0; i < ClassesToAffect.Length; i++ )
	{
		if ( Other.IsA(ClassesToAffect[i]) )
		{
			return True;
		}
	}

	return False;
}

function bool ActorIsInRange(Actor Other)
{
	local bool Check1, Check2;

	Check1 = Abs(Other.Location.X - Location.X) <= CollisionRadius * 2.0;
	Check2 = Abs(Other.Location.Y - Location.Y) <= CollisionRadius * 2.0;
	//DebugLog("Is " $ Other $ " X still in range: " $ Check1 $ " | Is Y: " $ Check2);
	return Check1 && Check2;
}

function bool ActorIsInList(Actor Other)
{
	local int i;

	for ( i = 0; i < TouchedActors.Length; i++ )
	{
		if ( TouchedActors[i] == Other )
		{
			return True;
		}
	}

	return False;
}

function float CalculateForce(Actor Other)
{
	local float CurrentDist, DistanceRatio;
	local Vector OtherPos;

	OtherPos = Other.Location;

	CurrentDist = VSize(OtherPos - Location);
	DistanceRatio = FClamp(1.0 - (CurrentDist / Distance), 0.0, 1.0);
	return (Force + Abs(Region.Zone.ZoneGravity.Z)) * DistanceRatio;
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	bUseTouch=True
	Distance=256.0
	Force=2048.0
	BuildUpDuration=2.0
	ShootDuration=3.0
	CooldownDuration=2.0
	ParticleTexture=Texture'HPParticle.Smoke5'
	ClassesToAffect(0)="Pawn"
	ClassesToAffect(1)="MOCAProp"

	bBlockActors=False
	bBlockCamera=False
	bBlockPlayers=False
}