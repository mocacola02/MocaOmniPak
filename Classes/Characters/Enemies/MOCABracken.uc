//=============================================================================
// MOCABracken.
//=============================================================================
class MOCABracken extends MOCAStalker;


defaultproperties
{
	Mesh=SkeletalMesh'MocaOmniResources.skBracken'
	HitsToKill=10
	DrawScale=1.2
	AttackSound=Sound'MocaOmniResources.Creatures.bracken_angry'
	KillSound=Sound'MocaOmniResources.Creatures.bracken_kill'
	RetreatSound=Sound'MocaOmniResources.Creatures.bracken_retreat'
	WaitAnim=Sneak
	SneakAnim=Sneak
	retreatAnim=Backoff
	AttackAnim=AttackWalk
	StareAnim=Idle
	KillAnim=Kill
	DieAnim=Die
}