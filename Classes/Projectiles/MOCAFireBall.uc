//============================================================
// MOCAFireBall.
//============================================================

class MOCAFireBall extends MOCAProjectile;

defaultproperties
{
	LaunchSpeed=700
    Damage=30
    LifeSpan=6.0
    LightType=LT_Steady
    bReallyDynamicLight=True
    LightBrightness=192
    LightHue=18
    LightSaturation=0
    ParticleClass=Class'HPParticle.Crabfire'
	GravityScale=2.0
	bUseSpawnRotation=true
    bHomingTowardTarget=true
	LandedClass=Class'MOCAFireSpot'
}
