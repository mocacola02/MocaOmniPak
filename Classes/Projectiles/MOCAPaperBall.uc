class MOCAPaperBall extends MOCAProjectile;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	local int X,Y,Z;

	X = Round(RandRange(20000,50000));
	Y = Round(RandRange(20000,50000));
	Z = Round(RandRange(20000,50000));

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
	bFixedRotationDir=True
}
