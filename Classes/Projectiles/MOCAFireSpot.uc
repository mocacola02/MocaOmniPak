class MOCAFireSpot extends HiddenHPawn;

var float fLifetime;
var int Damage;
//var groundfire GF;

event PostBeginPlay()
{
    Super.PostBeginPlay();

	fLifetime = RandRange(1.0,5.0);

    SetTimer(fLifetime,False);

    Log("Fire rotation:  " @ string(Rotation));
    //GF = Spawn(class'groundfire',,,Location,Rotation);
    //GF.SetOwner(self);

    Damage = Clamp(Rand(15),5,15);
}

event Destroyed()
{
    Super.Destroyed();
    //GF.Destroy();
}

event Timer()
{
	Destroy();
}

event Touch (Actor Other)
{
    if (Other.IsA('harry'))
    {
        PlayerHarry.TakeDamage(Damage,self,Location,vect(0,0,0),'FireSpot');
    }
}

event Bump (Actor Other)
{
	Touch(Other);
}

function playCloudSound()
{
	local Sound cloudSound;
	local int randNum;

	randNum = Rand(6);
	switch (randNum)
	{
		case 0:
			cloudSound = Sound'ss_COS_venomland_01E';
			break;
		case 1:
			cloudSound = Sound'ss_COS_venomland_02E';
			break;
		case 2:
			cloudSound = Sound'ss_COS_venomland_03E';
			break;
		case 3:
			cloudSound = Sound'ss_COS_venomland_04E';
			break;
		case 4:
			cloudSound = Sound'ss_COS_venomland_05E';
			break;
		case 5:
			cloudSound = Sound'ss_COS_venomland_06E';
			break;
		default:
			cloudSound = Sound'ss_COS_venomland_01E';
			break;
	}
	PlaySound(cloudSound,SLOT_None,RandRange(0.6,1.0),,3000.0,RandRange(0.5,1.6),,False);
}

auto state StartHere
{
	begin:
		playCloudSound();
}

defaultproperties
{
     fLifetime=1.5
     attachedParticleClass(0)=Class'MocaOmniPak.groundfire'
     bReallyDynamicLight=True
     DrawType=DT_None
     CollisionRadius=35
     CollisionHeight=8
     bCollideActors=True
     LightType=LT_Steady
     LightEffect=LE_FireWaver
     LightBrightness=192
     LightHue=18
     LightRadius=4
     LightSource=LD_Ambient
}
