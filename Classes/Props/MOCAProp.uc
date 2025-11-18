class MOCAProp extends Actor;

var(Display) float DrawDistance; // Moca: From how far away can the actor be seen? If 0.0, this isn't applied. Disable bStatic in the Advanced properties for this to work! Def: 0.0

var harry PlayerHarry;

event PostBeginPlay()
{
	super.PostBeginPlay();

	PlayerHarry = harry(Level.PlayerHarryActor);

	if (DrawDistance <= 0)
	{
		return;
	}
	
	GetDetail();

	local float DetailTimer;

	SetTimer(3.0,true);
}

event Timer()
{
	super.Timer();

	GetDetail();
}

event Tick (float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (DrawDistance <= 0)
	{
		return;
	}

	if (VSize(Location - PlayerHarry.Location) > DrawDistance)
	{
		if (!bHidden)
		{
			bHidden = True;
		}
	}
	else if (bHidden)
	{
		bHidden = False;
	}
}

function GetDetail()
{
	switch(PlayerHarry.ObjectDetail)
	{
		case ObjectDetailVeryHigh: break;
		case ObjectDetailHigh: DrawDistance *= 0.95; break;
		case ObjectDetailMedium: DrawDistance *= 0.9; break;
		case ObjectDetailLow: DrawDistance *= 0.8; break;
		case ObjectDetailVeryLow: DrawDistance *= 0.7; break;
		default: break;
	}
}

defaultproperties
{
	DrawDistance=0.0
	bStatic=True
	DrawType=DT_Mesh
	Mesh=SkeletalMesh'skSundialMesh'
}