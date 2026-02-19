//============================================================
// MOCAFireBall.
//============================================================

class MOCAFireBall extends MOCAProjectile;

defaultproperties
{
	LaunchSpeed=700
	DamageToDeal=30
	LifeSpan=6.0
	LightType=LT_Steady
	bReallyDynamicLight=True
	LightBrightness=192
	LightHue=18
	LightSaturation=0
	ParticleClass=Class'HPParticle.Crabfire'
	GravityScale=2.0
	bUseSpawnRotation=True
	bHomingTowardTarget=True
	LandedClass=Class'MOCAFireSpot'
}
