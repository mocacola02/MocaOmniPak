//================================================================================
// MOCAExplodingSpawner.
//================================================================================
class MOCAExplodingSpawner extends MOCASpawner;

var() bool bShakeCamera;
var() float ShakeRange;
var() float ShakeIntensity;
var() float ShakeDuration;

var() float FloatSpeed;
var() float FloatDuration;

var() Sound ExplodeSound;
var() float ExplodeSoundPitch;

var() Sound BuildUpSound;
var() Sound BuildUpSoundPitch;

var() class<ParticleFX> ExplodeParticle;


event Touch(Actor Other)
{
	if ( Other == PlayerHarry && !IsInState('stateBurst') )
	{
		GotoState('stateBurst');
	}
}

function DoShake()
{
	if ( bShakeCamera )
	{
		local float FinalShakeIntensity;
		local float DistFromHarry;

		DistFromHarry = MOCAHelpers.GetDistanceBetweenActors(Self,PlayerHarry);
		FinalShakeIntensity = 1.0 - ( DistFromHarry / ShakeRange );
		FinalShakeIntensity = FClamp(FinalShakeIntensity,0.0,99999.0);

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
		DesiredLocation = Location;
		DesiredLocation.Z += (FloatSpeed * DeltaTime);
		SetLocation(DesiredLocation);
	}

	begin:
		PlaySound(BuildUpSound,,BuildUpSoundPitch);
		Sleep(FloatDuration);
		PlaySound(ExplodeSound,,ExplodeSoundPitch);
		Spawn(ExplodeParticle);
		DoShake();
		KillAttachedParticleFX(0.0);
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