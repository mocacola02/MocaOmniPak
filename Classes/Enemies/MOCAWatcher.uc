//================================================================================
// MOCAWatcher. One of my oldest classes finally rewritten
//================================================================================

class MOCAWatcher extends MOCAChar;

var const Texture TransparentTexture;

var() bool bAwakeOnSpawn;

var() float MinLookTime;
var() float MaxLookTime;
var() float MinTurnSpeed;
var() float MaxTurnSpeed;

var() name IdleAnim;
var() name TurnLeftAnim;
var() name TurnRightAnim;
var() name CatchAnim;

var() name TriggerBoneName;

var() Texture BeamTexture;
var() Sound SqueakSound;
var() Sound ClangSound;
var() Sound HeadTurnSound;

var MOCAStealthTrigger CatchTrigger;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( !PlayerHarry.IsA('MOCAharry') )
	{
		EnterErrorMode("MOCAWatcher requires MOCAharry. Please replace harry with MOCAharry.");
	}
}

event Bump(Actor Other)
{
	if ( CanCatchHarry() && Other == PlayerHarry )
	{
		PlayerHarry.GetCaught();
		GotoState('stateCatch');
	}
}

event Trigger(Actor Other, Pawn EventInstigator)
{
	if ( IsInState('stateAsleep') )
	{
		Awaken();
	}
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
	return !IsInState('stateAsleep') && !PlayerHarry.IsInState('stateCaught');
}

function float GetLookTime()
{
	return RandRange(MinLookTime,MaxLookTime);
}

function float GetTurnSpeed()
{
	return RandRange(MinTurnSpeed,MaxTurnSpeed);
}

function Awaken(optional bool bNoSound)
{
	ShowBeam();

	if ( !bNoSound )
	{
		PlayArmorSound(ClangSound,0.667,1.334);
	}

	GotoState('stateIdle');
}

function UnAwaken(optional bool bNoSound)
{
	HideBeam();

	if ( !bNoSound )
	{
		PlayArmorSound(ClangSound,0.667,1.334);
	}

	GotoState('stateAsleep');
}

function ShowBeam()
{
	Skins[1] = BeamTexture;
	
	if ( CatchTrigger == None )
	{
		CatchTrigger = Spawn(class'MOCAStealthTrigger',Self,,BonePos(TriggerBoneName));
		CatchTrigger.AttachToBone(Self,TriggerBoneName);
	}
}

function HideBeam()
{
	Skins[1] = TransparentTexture;

	if ( CatchTrigger != None )
	{
		CatchTrigger.Destroy();
	}
}

function PlayArmorSound(Sound SoundToPlay, float MinPitch, float MaxPitch)
{
	local float RandPitch;
	RandPitch = RandRange(MinPitch,MaxPitch);
	PlaySound(SoundToPlay,SLOT_Interact,,,,RandPitch);
}

function TurnHead(name TurnAnimation, float TweenRate)
{
	PlayAnim(TurnAnimation,,TweenRate);
	PlayArmorSound(SqueakSound,0.667,1.334);
}

function Reset()
{
	GotoState('stateIdle');
}


///////////
// States
///////////

auto state stateAsleep
{
	event BeginState()
	{
		if ( bAwakeOnSpawn )
		{
			Awaken(True);
		}
		else
		{
			LoopAnim('Idle');
		}
	}
}

state stateIdle
{
	begin:
		LoopAnim('Idle');
		Sleep(GetLookTime());

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
		
		Sleep(GetLookTime());
		TurnHead(IdleAnim,0.75); // Idle
		FinishAnim();
		Goto('begin');
}

state stateCatch
{
	begin:
		LoopAnim(CatchAnim);
		PlayArmorSound(ClangSound,0.667,1.334);
}


defaultproperties
{
	TransparentTexture=Texture'MocaTexturePak.Misc.transparent'

	MinLookTime=1.5
	MaxLookTime=5.0

	MinTurnSpeed=0.334
	MaxTurnSpeed=0.75

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