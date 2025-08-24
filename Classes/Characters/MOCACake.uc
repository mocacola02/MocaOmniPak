//================================================================================
// MOCACake.
//================================================================================

class MOCACake extends MOCABabbler;

var (MOCABabbler) int hitsUntilDeath; //How many Flipendo hits until cake dies :(  If 0, never die.  Def: 0
var (MOCABabbler) bool randomTalkAnim; //Randomize talk animation. Def: true
var int currentHits;
var Color prevColor;
var Color dieColor;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	prevColor = AmbientGlowColor;
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
	SavedPreBumpState = GetStateName();
	currentHits++;
	if ((currentHits >= hitsUntilDeath) && (hitsUntilDeath != 0))
	{
		GotoState('CakeDie');
	}
	else
	{
		GotoState('CakeSpin');
	}
	return True;
}

state CakeSpin
{
	begin:
		PlayAnim('EmoteTwirl');
		FinishAnim();
		GotoState(SavedPreBumpState);
}

state CakeDie
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

function name GetBabbleAnim()
{
	if (!randomTalkAnim)
	{
		return babbleAnim;
	}

	local int randAnim;
	randAnim = Rand(2);

	if (randAnim == 1)
	{
		return 'EmoteHappy';
	}
	else
	{
		return 'EmoteNod';
	}
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
	local ParticleFX fire;

	fire = spawn(class'HPParticle.FSPlantFire');
	fire.SetOwner(self);
	fire.AttachToOwner('Root');
}

defaultproperties
{
	AmbientGlow=128
	timeBetweenBabble=0.1
    babbleAnim=Idle
	delayBeforeEnding=2.0
	bUseBumpLine=true
	voicePitch=128
	voiceRadius=100000.0
	turnToHarry=false
	hitsUntilDeath=5
	randomTalkAnim=true
	dieColor=(R=255,G=26,B=26,A=255)
	Mesh=SkeletalMesh'MocaModelPak.skCake'
	eVulnerableToSpell=SPELL_Flipendo
}