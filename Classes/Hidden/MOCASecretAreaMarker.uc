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
	// If we have sounds in the sound pool
	if ( SoundPool.Length > 0 )
	{
		// Return a random sound
		local int RandIdx;
		RandIdx = Rand(SoundPool.Length);
		return SoundPool[RandIdx];
	}
	// Otherwise, default to the stock sound
	else
	{
		return Sound'HPSounds.Music_Events.Found_Secret_Music';
	}
}

function OnFound()
{
	// If not found yet
	if ( !bFound )
	{
		// We're now found
		bFound = True;

		// The message of all time
		cm("Secret Area Found!  Oh most glorious delight and joy!!!");

		// Get and play sound
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