//================================================================================
// MOCADementorHunter.
//================================================================================
class MOCADementorHunter extends MOCAHunter;

defaultproperties
{
	HuntIdleAnims(0)="Idle"
	HuntIdleAnims(1)="patrol"
	CatchAnim="IdleHit"
	WakeUpAnim="WakeUp"

	bAlignBottomAlways=True
	CollisionRadius=21
	CollisionHeight=54
	CollideType=CT_OrientedCylinder

	AmbientGlow=32
	Mesh=SkeletalMesh'MocaOmniResources.skDementorMesh'

	IdleAnimName="Idle"
	WalkAnimName="AttackApproachFly"
	RunAnimName="BlownBack"
}
  