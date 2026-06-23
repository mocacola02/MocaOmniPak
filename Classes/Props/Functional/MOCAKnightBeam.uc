class MOCAKnightBeam extends Actor;

function Vector GetTriggerPosition()
{
	return BonePos('TriggerBone');
}


defaultproperties
{
	bCollideActors=True
	bCollideWorld=True
	bBlockActors=False
	bBlockCamera=False
	bBlockPlayers=False

	DrawType=DT_Mesh
	Mesh=SkeletalMesh'MocaOmniResources.skKnightBeam'
}