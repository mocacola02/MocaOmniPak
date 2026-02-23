class MOCAPaperBall extends MOCAProjectile;

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	local int X,Y,Z;

	// Rotate randomly
	X = Round(RandRange(20000,100000));
	Y = Round(RandRange(20000,100000));
	Z = Round(RandRange(20000,100000));

	RotationRate.Pitch = X;
	RotationRate.Roll = Y;
	RotationRate.Yaw = Z;

	// Randomize drawscale
	DrawScale = RandRange(0.34,0.67);
}

defaultproperties
{
	AmbientGlow=24
	DrawScale=0.8
    DamageToDeal=15
    LaunchSpeed=300
    ParticleClass=Class'Paper_Fly'
	DespawnEmitter=Class'Paper_Hit'
	DamageName=PaperBall
	Mesh=SkeletalMesh'MocaModelPak.skPaperBallMesh'
	bFixedRotationDir=True
	TargetInaccuracy=16.0
	LandedSound=Sound'MocaSoundPak.book_flap_Multi'
}