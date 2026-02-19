class MOCAHelpers extends Actor abstract;

static function float GetDistanceBetweenActors(Actor A, Actor B)
{
	return VSize(A.Location - B.Location);
}

static function bool DoesActorExist(Class<Actor> ActorToCheck)
{
	local Actor A;
	
	foreach AllActors(ActorToCheck, A)
	{
		return True;
	}

	return False;
}

static function NavigationPoint GetFurthestNavPFromActor(Actor ActorToCheck)
{
	local NavigationPoint TestNav;
	local NavigationPoint FurthestNav;
	local float TestDistance;
	local float FurthestDistance;
	
	foreach AllActors(class'NavigationPoint', TestNav)
	{
		TestDistance = GetDistanceBetweenActors(TestNav, ActorToCheck);

		if ( FurthestNav == None || ( TestDistance > FurthestDistance ) )
		{
			FurthestNav = TestNav;
			FurthestDistance = TestDistance;
		}
	}

	return FurthestNav;
}

function bool IsFacingOther(Actor SourceActor, Actor Other, float MinDot)
{
	local float DotProduct;
	DotProduct = Vector(Rotation) Dot Normal(Other.Location - Location);
	return DotProduct > MinDot;
}