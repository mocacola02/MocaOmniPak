class MOCAChallengeShield extends MOCACollectible;

state PickupProp
{
	function BeginState()
	{
		Spawn(class'ShieldCollect',,,Location);
		Super.BeginState();
	}

	function EndState()
	{
		local ChallengeScoreManager managerChallenge;

		foreach AllActors(Class'ChallengeScoreManager',managerChallenge)
		{
			break;
		}

		managerChallenge.PickedUpStar();
	}
}

defaultproperties
{
    pickUpSound=Sound'HPSounds.Magic_sfx.pickup_star'

    classStatusGroup=Class'MOCAStatusGroupShield'

    classStatusItem=Class'MOCAStatusItemShield'

	Physics=PHYS_Rotating

	CollisionHeight=48

    Mesh=SkeletalMesh'MocaModelPak.skChallengeShield'
}