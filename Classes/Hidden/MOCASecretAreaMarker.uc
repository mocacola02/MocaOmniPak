//================================================================================
// MOCASecretAreaMarker.
//================================================================================

class MOCASecretAreaMarker extends SecretAreaMarker;

var() array<Sound> SoundPool; // Moca: List of possible reveal sounds
var() float FoundSoundVolume; // Moca: Volume of sound


///////////////////
// Main Functions
///////////////////

function Sound GetRandomSound()
{
	if ( SoundPool.Length > 0 )
	{
		local int RandIdx;
		RandIdx = Rand(SoundPool.Length);
		return SoundPool[RandIdx];
	}
	else
	{
		return Sound'HPSounds.Music_Events.Found_Secret_Music';
	}
}

function OnFound()
{
	if ( !bFound )
	{
		bFound = True;

		cm("Secret Area Found!  Oh most glorious delight and joy!!!");

		FoundSound = GetRandomSound();
		PlaySound(FoundSound,,FoundSoundVolume);
	}
}

defaultproperties
{
	SoundPool(0)=Sound'HPSounds.Music_Events.Found_Secret_Music'
	SoundPool(1)=Sound'MocaSoundPak.Magic.found_secret_window'
	SoundPool(2)=Sound'MocaSoundPak.Magic.lumos_passthrough_sparkle'
	FoundSoundVolume=1.0
}