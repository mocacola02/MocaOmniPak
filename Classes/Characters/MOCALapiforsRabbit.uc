//================================================================================
// MOCALapiforsRabbit.
//================================================================================
class MOCALapiforsRabbit extends MOCABasicCharacter;

defaultproperties
{
	bAlignBottom=True
	CollisionHeight=11
	CollisionRadius=11

	Mesh=SkeletalMesh'skLapiforsRabbitMesh'

	IdleAnimName=Idle
	WalkAnimName=LoopingHop
	RunAnimName=LoopingHop
	TalkAnimName=fidget
	RotateLeftAnimName=TurnLeft
	RotateRightAnimName=TurnRight
}