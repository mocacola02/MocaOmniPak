//================================================================================
// MOCACake.
//================================================================================
class MOCACake extends MOCABabbler;

var (MOCABabbler) bool bRandomTalkAnim; // Moca: Randomize talk animation. Def: True
var Color DieColor;						// Moca: Color to use when die


//////////
// Magic
//////////

function ProcessSpell()
{
	// Save state
	SavedPreBumpState = GetStateName();

	// Increase hits taken
	HitsTaken++;

	// If we should die, die
	if ( ShouldDie() )
	{
		GotoState('stateCakeDie');
	}
	// Otherwise, speen
	else
	{
		GotoState('stateCakeSpin');
	}
}


////////////////////
// Misc. Functions
////////////////////

function name GetBabbleAnim()
{
	// If not random talk anim, return BabbleAnim
	if ( !bRandomTalkAnim )
	{
		return BabbleAnim;
	}

	// Get random int
	local int RandAnim;
	RandAnim = Rand(2);

	// If 1, do anim 'EmoteHappy'
	if ( RandAnim == 1 )
	{
		return 'EmoteHappy';
	}

	// Otherwise, 'EmoteNod'
	return 'EmoteNod';
}

function MakeAngry()
{
	// Set skins to appropriate angry ones
	Skins[0] = Texture'MocaTexturePak.AngryCake.Angry_Top';
	Skins[1] = Texture'MocaTexturePak.AngryCake.Angry_Side';
	Skins[2] = Texture'MocaTexturePak.AngryCake.Angry_InSide';
	Skins[3] = Texture'MocaTexturePak.AngryCake.Angry_crown_shine';
	Skins[4] = Texture'MocaTexturePak.AngryCake.Angry_eyes';
	Skins[5] = Texture'MocaTexturePak.AngryCake.Angry_jewel';
}

function SpawnFire()
{
	// Spawn fire particles
	local ParticleFX Fire;
	Fire = spawn(class'HPParticle.FSPlantFire');

	// Set owner to self and attach to root bone
	Fire.SetOwner(Self);
	Fire.AttachToOwner('Root');
}


///////////
// States
///////////

state stateCakeSpin
{
	begin:
		// Play spin animation
		PlayAnim('EmoteTwirl');
		FinishAnim();
		// Return to last state
		GotoState(SavedPreBumpState);
}

state stateCakeDie
{
	begin:
		// Start blinking
		eVulnerableToSpell = SPELL_None;
		LoopAnim('Rest');
		sleep(2.0);
		AmbientGlowColor = dieColor;
		PlaySound(Sound'HPSounds.menu_sfx.timer_1',SLOT_Talk);
		sleep(1.0);
		AmbientGlowColor = MapDefault.AmbientGlowColor;
		sleep(1.0);
		PlaySound(Sound'HPSounds.menu_sfx.timer_2',SLOT_Talk);
		AmbientGlowColor = dieColor;
		sleep(1.0);
		AmbientGlowColor = MapDefault.AmbientGlowColor;
		sleep(1.0);
		PlaySound(Sound'HPSounds.menu_sfx.timer_3',SLOT_Talk);
		AmbientGlowColor = dieColor;
		sleep(1.0);
		AmbientGlowColor = MapDefault.AmbientGlowColor;
		// Turn angry
		MakeAngry();
		sleep(3.0);
		// Fly away
		bAnimMove = True;
		SpawnFire();
		PlaySound(Sound'HPSounds.Critters_sfx.Basilisk_scream_death',SLOT_Talk,[Pitch]0.5);
		PlayAnim('FlyAway');
		FinishAnim();
		Destroy();
}


defaultproperties
{
	bRandomTalkAnim=True
	DieColor=(R=255,G=26,B=26,A=255)

	TimeBetweenBabble=0.1
	BabbleAnim=Idle
	DelayBeforeEnding=2.0
	bTurnToHarry=False
	
	bUseBumpLine=True
	HitsToKill=5

	AmbientGlow=128
	Mesh=SkeletalMesh'MocaModelPak.skCake'
	eVulnerableToSpell=SPELL_Flipendo
}