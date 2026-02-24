//================================================================================
// MOCAExplodingSpawner.
//================================================================================
class MOCAExplodingSpawner extends MOCASpawner;

var() bool bShakeCamera;		// Moca: Should camera shake? Def: True
var() float ShakeRange;			// Moca: How far does the shake effect? Def: 1024.0
var() float ShakeIntensity;		// Moca: How intense is the shake? Def: 100.0
var() float ShakeDuration;		// Moca: How long is the shake? Def: 2.0

var() float FloatSpeed;			// Moca: How fast does it float up when touched? Def: 15.0
var() float FloatDuration;		// Moca: How long does it float up for? Def: 2.0

var Sound ExplodeSound;		// Sound to play on explode
var float ExplodeSoundPitch;// Explode sound pitch

var Sound BuildUpSound;		// Sound to play when starting to float
var float BuildUpSoundPitch;// Build up sound pitch

var class<ParticleFX> ExplodeParticle;	// Particle class for explosion


event Touch(Actor Other)
{
	// If other is Harry and we're not bursting already
	if ( Other == PlayerHarry && !IsInState('stateBurst') )
	{
		GotoState('stateBurst');
	}
}

function DoShake()
{
	// If we should shake camera
	if ( bShakeCamera )
	{
		local float FinalShakeIntensity;
		local float DistFromHarry;
		// Get distance from Harry
		DistFromHarry = GetDistanceBetweenActors(Self,PlayerHarry);
		// Calculate shake intensity based on distance from Harry
		FinalShakeIntensity = 1.0 - ( DistFromHarry / ShakeRange );
		// Multiply by our base intensity
		FinalShakeIntensity *= ShakeIntensity;
		// Clamp intensity to be above 0.0
		FinalShakeIntensity = FClamp(FinalShakeIntensity,0.0,99999.0);
		// Shake camera
		PlayerHarry.ShakeView(ShakeDuration,FinalShakeIntensity,FinalShakeIntensity);
	}
}

auto state stateIdle
{
}

state stateBurst
{
	event Tick(float DeltaTime)
	{
		local Vector DesiredLocation;
		// Calculate desired rotation by adding float speed to our current location
		DesiredLocation = Location;
		DesiredLocation.Z += (FloatSpeed * DeltaTime);
		// Set new location
		SetLocation(DesiredLocation);
	}

	begin:
		// Play build up sound
		PlaySound(BuildUpSound,[Pitch]BuildUpSoundPitch);
		// Wait for our float duration
		Sleep(FloatDuration);
		// Play explode sound
		PlaySound(ExplodeSound,[Pitch]ExplodeSoundPitch);
		// Spawn explode particles
		Spawn(ExplodeParticle);
		// Shake camera
		DoShake();
		// Kill attached particles
		KillAttachedParticleFX(0.0);
		// Spawn items
		GotoState('stateSpawn');
}


defaultproperties
{
	bShakeCamera=True
	ShakeRange=1024
	ShakeIntensity=100.0
	ShakeDuration=2.0

	FloatSpeed=15.0
	FloatDuration=5.75

	ExplodeSound=Sound'HPSounds.Magic_sfx.pickup_WC_silver'
	ExplodeSoundPitch=1.0
	BuildUpSound=Sound'HPSounds.Magic_sfx.pickup_wizardcard'
	BuildUpSoundPitch=0.5

	ExplodeParticle=class'HPParticle.BronzePickup'

	ListOfSpawns(0)=(ActorToSpawn=class'Jellybean',SpawnParticles=class'Spawn_flash_1',SpawnSound=Sound'spawn_bean01',SpawnChance=255,SpawnDelay=0.01,SpawnVelocityMult=1.0)

	bHidden=True
	bPersistent=True
	bBlockActors=False
	bBlockPlayers=False
	bProjTarget=False
	AmbientGlow=200
	SoundRadius=8.0
	SoundVolume=255.0
	CollisionRadius=16.0
	CollisionHeight=24.0
	Rotation=(Pitch=16384,Yaw=0,Roll=0)
	attachedParticleClass(0)=Class'HPParticle.SpellTarget_Lock'
	attachedParticleClass(1)=Class'HPParticle.TargetGlow'
	AmbientSound=Sound'HPSounds.Magic_sfx.wizardcard_rotate'
	Texture=Texture'HPParticle.hp_fx.Particles.swirl001'
	DrawType=DT_Sprite
	eVulnerableToSpell=SPELL_None
}