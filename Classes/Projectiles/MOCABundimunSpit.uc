//============================================================
// MOCABundimunSpit
//============================================================

class MOCABundimunSpit extends MOCAProjectile;

var float DamageToDeal;

function OnLand(vector HitNormal)
{
    local BundimunSpray BS;

    if (HitNormal.Z > 0.7)  // Hitting floor or a flat-enough slope
    {
        BS = Spawn(class'BundimunSpray',,, Location);
        if (BS != None)
        {
            BS.SetOwner(Owner);
            BS.DamageToDeal = DamageToDeal;
			NoDespawnEmit = True;
        }
    }
    KillProjectile();
}

defaultproperties
{
    Damage=10
    DamageToDeal=15
    LaunchSpeed=100
    LightType=LT_None
    ParticleClass=Class'BundimunSpitFX'
	DespawnEmitter=Class'BundimunHit'
	DamageName=BundimunSpit
}
