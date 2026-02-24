//================================================================================
// MOCAWatcher. One of my oldest classes finally rewritten
//================================================================================
class MOCAWatcher extends MOCAChar;

var const Texture TransparentTexture;	// Constant transparent texture

var() bool bAwakeOnSpawn;	// Should we be awake on spawn? Def: False

var() Range LookTime;		// Range to determine time spent looking in a direction. Def: Min 1.5 Max 5.0
var() Range TurnSpeed;		// Range to determine how quickly we look side to side. Def: Min 0.667 Max 1.667

var name IdleAnim;			// Idle anim
var name TurnLeftAnim;		// Turn left anim
var name TurnRightAnim;		// Turn right anim
var name CatchAnim;			// Catch anim
var name TriggerBoneName;	// Name of bone to attach StealthTrigger to

var Texture BeamTexture;	// Texture for search beam
var Sound SqueakSound;		// Squeak sound
var Sound ClangSound;		// Clang sound
var Sound HeadTurnSound;	// Head turn sound
var MOCAStealthTrigger CatchTrigger;	// Ref to StealthTrigger


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// If Harry is not a MOCAharry, yell at mapper
	if ( !PlayerHarry.IsA('MOCAharry') )
	{
		PushError("MOCAWatcher requires MOCAharry. Please replace harry with MOCAharry.");
	}
}

event Bump(Actor Other)
{
	// If we can catch Harry and other is Harry, catch him
	if ( CanCatchHarry() && Other == PlayerHarry )
	{
		MOCAharry(PlayerHarry).GetCaught(Self,Event);
		GotoState('stateCatch');
	}
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	// If asleep, awaken
	if ( IsInState('stateAsleep') )
	{
		Awaken();
	}
	// Otherwise, go to sleep
	else
	{
		UnAwaken();
	}
}


///////////////////
// Main Functions
///////////////////

function bool CanCatchHarry()
{
	// Return true if not asleep and harry isn't already caught
	return !IsInState('stateAsleep') && !PlayerHarry.IsInState('stateCaught');
}

function float GetLookTime()
{
	return RandRange(LookTime.Min,LookTime.Max);
}

function float GetTurnSpeed()
{
	return RandRange(TurnSpeed.Min,TurnSpeed.Max);
}

function Awaken(optional bool bNoSound)
{
	// Unhide beam
	ShowBeam();

	//  If not bNoSound, Play armor clang wake up sound
	if ( !bNoSound )
	{
		PlayArmorSound(ClangSound,0.667,1.334);
	}

	// Go to idle
	GotoState('stateIdle');
}

function UnAwaken(optional bool bNoSound)
{
	// Hide beam
	HideBeam();

	// If not bNoSound, play armor clang asleep sound
	if ( !bNoSound )
	{
		PlayArmorSound(ClangSound,0.667,1.334);
	}

	// Go to sleep
	GotoState('stateAsleep');
}

function ShowBeam()
{
	// Set beam texture
	Skins[1] = BeamTexture;
	
	// If CatchTrigger is not set
	if ( CatchTrigger == None )
	{
		// Spawn catch trigger
		CatchTrigger = Spawn(class'MOCAStealthTrigger',Self,,BonePos(TriggerBoneName));
		// Attach it to us
		CatchTrigger.AttachToBone(Self,TriggerBoneName);
		// Make the beam glow
		CatchTrigger.LightBrightness = 128;
		CatchTrigger.LightHue = 128;
		CatchTrigger.LightSaturation = 128;
		CatchTrigger.bDynamicLight = True;
		CatchTrigger.LightRadius = 8;
		CatchTrigger.LightType = LT_Steady;
	}
}

function HideBeam()
{
	// Set beam to transparent
	Skins[1] = TransparentTexture;

	// If we have a trigger, destroy it
	if ( CatchTrigger != None )
	{
		CatchTrigger.Destroy();
	}
}

function PlayArmorSound(Sound SoundToPlay, float MinPitch, float MaxPitch)
{
	// Play sound with pitch variance
	local float RandPitch;
	RandPitch = RandRange(MinPitch,MaxPitch);
	PlaySound(SoundToPlay,SLOT_Interact,,,,RandPitch);
}

function TurnHead(name TurnAnimation, float TweenRate)
{
	// Turn head and play armor sound
	PlayAnim(TurnAnimation,,TweenRate);
	PlayArmorSound(SqueakSound,0.667,1.334);
}

function Reset()
{
	// Reset our catch trigger and go to idle
	CatchTrigger.Reset();
	GotoState('stateIdle');
}


///////////
// States
///////////

auto state stateAsleep
{
	event BeginState()
	{
		// If should be awake on spawn, awaken without sound
		if ( bAwakeOnSpawn )
		{
			Awaken(True);
		}
		// Otherwise, loop idle anim
		else
		{
			LoopAnim('Idle');
		}
	}
}

state stateIdle
{
	begin:
		// Loop idle anim and wait for look time
		LoopAnim('Idle');
		Sleep(GetLookTime());

		// Choose left or right
		if ( Rand(1) == 0 )
		{
			TurnHead(TurnLeftAnim,GetTurnSpeed());	// IdleLeft
			FinishAnim();
		}
		else
		{
			TurnHead(TurnRightAnim,GetTurnSpeed()); // IdleRight
			FinishAnim();
		}
		
		// Wait for sleep time
		Sleep(GetLookTime());
		// Turn back to idle position
		TurnHead(IdleAnim,0.75);
		// When done, do this all again
		FinishAnim();
		goto('begin');
}

state stateCatch
{
	begin:
		// Loop catch anim
		LoopAnim(CatchAnim);
		// Play clang sound
		PlayArmorSound(ClangSound,0.667,1.334);
}


defaultproperties
{
	TransparentTexture=Texture'MocaTexturePak.Misc.transparent'

	LookTime=(Min=1.5,Max=5.0)
	TurnSpeed=(Min=0.667,Max=1.667)

	IdleAnim=Idle
	TurnLeftAnim=IdleLeft
	TurnRightAnim=IdleRight
	CatchAnim=StandHit

	TriggerBoneName=TriggerPoint

	BeamTexture=Texture'MocaTexturePak.Skins.beam'
	SqueakSound=MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move'
	ClangSound=MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks'
	HeadTurnSound=MultiSound'MocaSoundPak.Creatures.Multi_armor_head_move'

	Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
	CollisionHeight=58.0
	ShadowScale=0.5
	TransientSoundRadius=1024.0
}