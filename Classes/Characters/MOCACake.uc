//================================================================================
// MOCACake.
//================================================================================

class MOCACake extends MOCABabbler;

var (MOCABabbler) bool bRandomTalkAnim; // Moca: Randomize talk animation. Def: true
var Color PrevColor;
var Color DieColor;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();
	PrevColor = AmbientGlowColor;
}


//////////
// Magic
//////////

function ProcessSpell()
{
	SavedPreBumpState = GetStateName();

	HitsTaken++;

	if ( ShouldDie() )
	{
		GotoState('stateCakeDie');
	}
	else
	{
		GotoState('stateCakeSpin');
	}
}


///////////
// States
///////////

state stateCakeSpin
{
	begin:
		PlayAnim('EmoteTwirl');
		FinishAnim();
		GotoState(SavedPreBumpState);
}

state stateCakeDie
{
	begin:
		eVulnerableToSpell = SPELL_None;
		LoopAnim('Rest');
		sleep(2.0);
		AmbientGlowColor = dieColor;
		PlaySound(Sound'HPSounds.menu_sfx.timer_1',SLOT_Talk,voiceVolume,,voiceRadius,1.0,True);
		sleep(1.0);
		AmbientGlowColor = prevColor;
		sleep(1.0);
		PlaySound(Sound'HPSounds.menu_sfx.timer_2',SLOT_Talk,voiceVolume,,voiceRadius,1.0,True);
		AmbientGlowColor = dieColor;
		sleep(1.0);
		AmbientGlowColor = prevColor;
		sleep(1.0);
		PlaySound(Sound'HPSounds.menu_sfx.timer_3',SLOT_Talk,voiceVolume,,voiceRadius,1.0,True);
		AmbientGlowColor = dieColor;
		sleep(1.0);
		AmbientGlowColor = prevColor;
		MakeAngry();
		sleep(3.0);
		bAnimMove = True;
		SpawnFire();
		PlaySound(Sound'HPSounds.Critters_sfx.Basilisk_scream_death',SLOT_Talk,voiceVolume,,voiceRadius,0.5,false);
		PlayAnim('FlyAway');
		FinishAnim();
		Destroy();
}


////////////////////
// Misc. Functions
////////////////////

function name GetBabbleAnim()
{
	if ( !bRandomTalkAnim )
	{
		return BabbleAnim;
	}

	local int RandAnim;
	RandAnim = Rand(2);

	if ( RandAnim == 1 )
	{
		return 'EmoteHappy';
	}

	return 'EmoteNod';
}

function MakeAngry()
{
	Skins[0] = Texture'MocaTexturePak.AngryCake.Angry_Top';
	Skins[1] = Texture'MocaTexturePak.AngryCake.Angry_Side';
	Skins[2] = Texture'MocaTexturePak.AngryCake.Angry_InSide';
	Skins[3] = Texture'MocaTexturePak.AngryCake.Angry_crown_shine';
	Skins[4] = Texture'MocaTexturePak.AngryCake.Angry_eyes';
	Skins[5] = Texture'MocaTexturePak.AngryCake.Angry_jewel';
}

function SpawnFire()
{
	local ParticleFX Fire;

	Fire = spawn(class'HPParticle.FSPlantFire');
	Fire.SetOwner(Self);
	Fire.AttachToOwner('Root');
}


defaultproperties
{
	bRandomTalkAnim=True
	DieColor=(R=255,G=26,B=26,A=255)

	TimeBetweenBabble=0.1
	BabbleAnim=Idle
	DelayBeforeEnding=2.0
	BabbleVoicePitch=128
	BabbleVoiceRadius=100000.0
	bTurnToHarry=False
	
	bUseBumpLine=True
	HitsToKill=5

	AmbientGlow=128
	Mesh=SkeletalMesh'MocaModelPak.skCake'
	eVulnerableToSpell=SPELL_Flipendo
}