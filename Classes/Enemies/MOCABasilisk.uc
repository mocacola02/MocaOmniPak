class MOCABasilisk extends Basilisk;

// DELETEME

var() int DeathHoleIndex;

var array<MOCABasiliskNode> HoleMarks;

function PostBeginPlay()
{
	local int I;
	local MOCABasiliskNode A;

	Super.PostBeginPlay();
	WaitingState = 'stateWait1';
	_AnimChannel = BasiliskAnimChannel(CreateAnimChannel(Class'BasiliskAnimChannel',AT_Replace,MainBoneName));
	_AnimChannel._SetOwner(self);
	MakeBasilHeadObj();
	MakeBasilBreastObj();
	_BlockPlayer = Spawn(Class'HPawn');
	// _BlockPlayer.SetPhysics(0);
	_BlockPlayer.SetPhysics(Phys_None);
	_BlockPlayer.SetCollision(True,False,True);
	_BlockPlayer.SetCollisionSize(40.0,50.0);
	_BlockPlayer.bHidden = True;
	foreach AllActors(Class'MOCABasiliskNode',A,'BasiliskHoleMarker')
	{
		break;
	}

	BasilStartPoint = A;
	FloorZ = A.Location.Z;

	AttackTimer = b1_TimeBetweenAttackStart;
	EyeGlowL = Spawn(Class'BasilEyeGlow',self);
	EyeGlowL.AttachToOwner('Bone144');
	EyeGlowL.EnableEmission(False);
	EyeGlowR = Spawn(Class'BasilEyeGlow',self);
	EyeGlowR.AttachToOwner('Bone118');
	EyeGlowR.EnableEmission(False);

	Log("BASILISK FOUND " $ string(NumHoles) $ " HOLES!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");

	HoleMarks.Empty();

	foreach AllActors(Class'MOCABasiliskNode',A)
	{
		NumHoles++;
		HoleMarks.AddItem(A);
		Log("Adding " $ string(A) $ " to list of hole markers.");
	}

	NumHoles = HoleMarks.Length;

	AcidSpitPeriod = 1.0 / AcidSpitFreq;
}

function BasilHitBySpell (baseSpell spell, Vector HitLocation)
{
	local int DamageAmount;
	local bool bDoStateHit;

	if ( spellSwordFire(spell) == None )
	{
		return;
	}
	bDoStateHit = True;
	if ( bIdleState )
	{
		return;
	}
	DamageAmount = spellSwordFire(spell).Damage;
	DamageAmount *= GetBasilDamageScalar();
	if ( bDidFirstBattle )
	{
		DamageAmount *= 0.5;
	}
	if ( PlayerHarry.Difficulty == DifficultyMedium )
	{
		DamageAmount *= 0.75;
	} else //{
		if ( PlayerHarry.Difficulty == DifficultyHard )
		{
		DamageAmount *= 0.5;
		}
	//}
	Health -= DamageAmount;
	if ( Health <= 0 )
	{
		if ( bDidFirstBattle && (aLastHole != HoleMarks[DeathHoleIndex]) )
		{
		bTookFirstDeathBlow = True;
		Health = 1;
		} else {
		Health = 0;
		BeatBoss();
		}
	}
	if ( Health > 0 )
	{
		if ( BasilAcksHit(spell) )
		{
		GotoState('stateHit');
		} else {
		if (  !bDidFirstBattle )
		{
			switch (Rand(3))
			{
			case 0:
			tempSound = Sound'Basilisk_ouch1';
			break;
			case 1:
			tempSound = Sound'Basilisk_ouch2';
			break;
			case 2:
			tempSound = Sound'Basilisk_ouch3';
			break;
			default:
			}
			PlaySound(tempSound,Slot_None,BasilSoundVolume,,BasilSoundRadius);
		}
		}
	}
	PlayerHarry.ClientMessage(" Basil Health:" $ string(Health));
	return;
}

function MoveToNewHole()
{
	local int NumVisibleHoles;
	local Vector vDir;
	local Actor A;
	local float ClosestHoleDist;
	local int iClosestHole;
	local int I;
	local Rotator R;

	if ( bTookFirstDeathBlow )
	{
		iClosestHole = 1;
	} else {
		ClosestHoleDist = 1000000.0;
		// I = 0;
		//a for loop -AdamJD
		for ( I = 0;  I < NumHoles; I++ )
		{
		if ( (HoleMarks[I] != aLastHole) && (VSize2D(HoleMarks[I].Location - PlayerHarry.Location) < ClosestHoleDist) )
		{
			ClosestHoleDist = VSize2D(HoleMarks[I].Location - PlayerHarry.Location);
			iClosestHole = I;
		}
		// I++;
		// goto JL0025;
		}
	}
	aLastHole = HoleMarks[iClosestHole];
	CurrentHole = iClosestHole;
	SetLocation(HoleMarks[CurrentHole].Location);
	R = rotator((PlayerHarry.Location - Location) * vect(1.00,1.00,0.00));
	R.Yaw += RandRange( -OutHoleMaxRandYaw, OutHoleMaxRandYaw );
	DesiredRotation = R;
	PlayerHarry.ClientMessage("Basil moved to hole:" $ string(CurrentHole));
	_BlockPlayer.SetLocation2(HoleMarks[CurrentHole].Location + vect(0.00,0.00,100.00));
	_BasilSmoke.SetLocation(HoleMarks[CurrentHole].Location + vect(0.00,0.00,10.00));
	_BasilSmoke.bEmit = True;
}

defaultproperties
{
	DeathHoleIndex=1
}