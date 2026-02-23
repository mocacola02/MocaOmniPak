class MOCAFireSpot extends HiddenHPawn;

var int DamageToDeal;

var array<Sound> CloudSounds;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	PlayCloudSound();
}

event Touch(Actor Other)
{
	// If other is Harry, damage him
	if ( Other == PlayerHarry )
	{
		local int RandDamage;
		RandDamage = Round(RandRange(5.0,15.0));
		PlayerHarry.TakeDamage(RandDamage,Self,Location,Vect(0,0,0),'FireSpot');
		KillProjectile();
	}
}


///////////////////
// Main Functions
///////////////////

function PlayCloudSound()
{
	// Play random sound on spawn
	local int RandIdx;
	RandIdx = Rand(CloudSounds.Length);
	
	PlaySound(CloudSounds[RandIdx],SLOT_Interact);
}


defaultproperties
{
	CloudSounds(0)=Sound'ss_COS_venomland_01E'
	CloudSounds(1)=Sound'ss_COS_venomland_02E'
	CloudSounds(2)=Sound'ss_COS_venomland_03E'
	CloudSounds(3)=Sound'ss_COS_venomland_04E'
	CloudSounds(4)=Sound'ss_COS_venomland_05E'
	CloudSounds(5)=Sound'ss_COS_venomland_06E'

	LifeSpan=1.5
	TransientSoundRadius=4096.0
	attachedParticleClass(0)=Class'MocaOmniPak.groundfire'
	bReallyDynamicLight=True
	DrawType=DT_None
	CollisionRadius=35
	CollisionHeight=8
	bCollideActors=True
	LightType=LT_Steady
	LightEffect=LE_FireWaver
	LightBrightness=192
	LightHue=18
	LightRadius=4
	LightSource=LD_Ambient
}