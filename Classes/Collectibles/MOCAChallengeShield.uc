class MOCAChallengeShield extends MOCACollectible;

state PickupProp
{
	function BeginState()
	{
		Super.BeginState();
		Spawn(class'ShieldCollect',,,Location);
	}

	function EndState()
	{
		local ChallengeScoreManager ManagerChallenge;

		foreach AllActors(Class'ChallengeScoreManager',ManagerChallenge)
		{
			break;
		}

		ManagerChallenge.PickedUpStar();
	}
}

defaultproperties
{
	PickUpSound=Sound'HPSounds.Magic_sfx.pickup_star'

	classStatusGroup=Class'MOCAStatusGroupShield'

	classStatusItem=Class'MOCAStatusItemShield'

	Physics=PHYS_Rotating

	CollisionHeight=48

	Mesh=SkeletalMesh'MocaModelPak.skChallengeShield'
}