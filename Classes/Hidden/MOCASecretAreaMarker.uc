//================================================================================
// MOCASecretAreaMarker.
//================================================================================

class MOCASecretAreaMarker extends SecretAreaMarker;

var(SecretAreaMarker) array<Sound> soundPool; // Moca: List of possible reveal sounds
var(SecretAreaMarker) float FoundSoundVolume; // Moca: Volume of sound


event PostBeginPlay()
{
    if (soundPool.Length <= 0)
    {
        Log("No sound set to " $ string(self) $ ", defaulting to stock sound");
        FoundSound = Sound'HPSounds.Music_Events.Found_Secret_Music';
        return;
    }

    if (soundPool.Length == 1)
    {
        FoundSound = soundPool[0];
        return;
    }

    local int randomIndex;

    randomIndex = Rand(soundPool.Length);
    FoundSound = soundPool[randomIndex];
}

function OnFound()
{
	if (  !bFound )
	{
		cm("Secret Area Found!  Oh most glorious delight and joy!!!");
		if ( FoundSound != None )
		{
			PlaySound(FoundSound,,FoundSoundVolume);
		}
	}
	bFound = True;
}

defaultproperties
{
    soundPool(0)=Sound'HPSounds.Music_Events.Found_Secret_Music'
    soundPool(1)=Sound'MocaSoundPak.Magic.found_secret_window'
    soundPool(2)=Sound'MocaSoundPak.Magic.lumos_passthrough_sparkle'
    FoundSoundVolume=1.0
}