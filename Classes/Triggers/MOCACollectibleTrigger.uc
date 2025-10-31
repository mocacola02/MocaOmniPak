class MOCACollectibleTrigger extends spellTrigger;

var() int NumberGiven;
var() class<MOCACollectible> CollectibleGiven;
var() int IncrementPerCollectible;
var() Vector SpawnLocationOffset;
var() float TimeBetweenSpawns;
var() Sound SpawnSound; // Moca: Custom spawn sound. If none, uses the collectible's default sound.

var int DefaultNumberGiven;
var float DefaultTimeBetweenSpawns;
var Vector SpawnPoint;
var StatusGroup CollectibleSG;
var StatusItem CollectibleSI;
var harry PlayerHarry;

function BeginPlay()
{
	Super.BeginPlay();
	DefaultNumberGiven = NumberGiven;
	DefaultTimeBetweenSpawns = TimeBetweenSpawns;
	PlayerHarry = harry(Level.PlayerHarryActor);
	
	if (SpawnSound == None)
	{
		SpawnSound = CollectibleGiven.Default.pickUpSound;
	}
}

function Activate(actor Other, pawn Instigator)
{
	Super.Activate(Other,Instigator);
    ProcessTrigger();
}

function ProcessTrigger()
{
	GotoState('GiveHarryBeans');
}

auto state Idle
{
	event BeginState()
	{
		TimeBetweenSpawns = DefaultTimeBetweenSpawns;
		NumberGiven = DefaultNumberGiven;
	}
}

state GiveHarryBeans
{
	function BeginState()
	{
		SpawnPoint = Location + SpawnLocationOffset;

		CollectibleSG = PlayerHarry.managerStatus.GetStatusGroup(CollectibleGiven.Default.classStatusGroup);
		CollectibleSI = CollectibleSG.GetStatusItem(CollectibleGiven.Default.classStatusItem);
		CollectibleSG.SetEffectTypeToPermanent();
		CollectibleSG.SetCutSceneRenderMode(True);
	}

	function EndState()
	{
		if ( NumberGiven > 0 )
		{
			CollectibleSI.IncrementCount(NumberGiven);
		}

		CollectibleSG.SetEffectTypeToNormal();
		CollectibleSG.SetCutSceneRenderModeToNormal();
	}
	
	function Tick (float DeltaTime)
	{
		if ( NumberGiven > 0 )
		{
			if ( TimeBetweenSpawns >= DefaultTimeBetweenSpawns )
			{
				local MOCACollectible NewCollectible;
				TimeBetweenSpawns = 0.0;

				NewCollectible = Spawn(CollectibleGiven, [SpawnLocation] SpawnPoint);
				PlaySound(SpawnSound);
				NewCollectible.SetPhysics(PHYS_Walking);
				NewCollectible.nPickupIncrement = IncrementPerCollectible;
				NewCollectible.DoPickupProp();
				NumberGiven -= 1;
			}
			else
			{
				TimeBetweenSpawns += DeltaTime;
			}
		}
		else if ( bTriggerOnceOnly )
		{
			Destroy();
		}
		else
		{
			GotoState('Idle');
		}
	}
}

defaultproperties
{
	NumberGiven=8
	IncrementPerCollectible=1
	CollectibleGiven=class'MOCAJellybean'
	TimeBetweenSpawns=0.1

    // TriggerType=4
	TriggerType=TT_Shoot

    // Style=2
	Style=STY_Masked

    Texture=Texture'spell_trigger'

    bProjTarget=True

	eVulnerableToSpell=SPELL_Flipendo

	bTriggerOnceOnly=True
}