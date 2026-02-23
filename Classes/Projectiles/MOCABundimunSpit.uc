//============================================================
// MOCABundimunSpit
//============================================================

class MOCABundimunSpit extends MOCAProjectile;


function OnLand(Vector HitNormal)
{
	local MOCABundimunSpray BundiSpray;

	// If ground is mostly flat, spawn bundi spray
	if ( HitNormal.Z > 0.7 )
	{
		BundiSpray = Spawn(class'MOCABundimunSpray',Self,,Location);

		if ( BundiSpray != None )
		{
			BundiSpray.DamageToDeal = DamageToDeal;
			bNoDespawnEmit = True;
		}
	}

	// Destroy self
	KillProjectile();
}


defaultproperties
{
	DamageToDeal=15.0
	LaunchSpeed=100.0
	TargetInaccuracy=0.0
	DamageName=BundimunSpit

	ParticleClass=Class'BundimunSpitFX'
	DespawnEmitter=Class'BundimunHit'
}