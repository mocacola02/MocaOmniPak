class MOCAPaperBall extends MOCAProjectile;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	local int X,Y,Z;

	X = Round(RandRange(100,1000));
	Y = Round(RandRange(100,1000));
	Z = Round(RandRange(100,1000));

	RotationRate.Pitch = X;
	RotationRate.Roll = Y;
	RotationRate.Yaw = Z;
}

defaultproperties
{
	AmbientGlow=64
	DrawScale=0.8
    DamageToDeal=15
    LaunchSpeed=300
    ParticleClass=Class'Paper_Fly'
	DespawnEmitter=Class'Paper_Hit'
	DamageName=PaperBall
	Mesh=SkeletalMesh'MocaModelPak.skPaperBallMesh'
}
