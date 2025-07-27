class MOCAProjectile extends baseSpell;

var vector CurrentDirection;

function bounce (Vector HitNormal)
{
	SetLocation(OldLocation);
	Velocity *= 0.89999998;
	Velocity = MirrorVectorByNormal(Velocity,HitNormal);
	CurrentDirection = Vector(Rotation);
	CurrentDirection += HitNormal;
	SetRotation(rotator(CurrentDirection));
}