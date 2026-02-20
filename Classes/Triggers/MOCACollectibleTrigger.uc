class MOCACollectibleTrigger extends spellTrigger;

var() int NumberToGive;
var() int IncrementPerCollectible;
var() float TimeBetweenSpawns;
var() Vector SpawnLocationOffset;
var() Sound SpawnSound;

var() class<MOCACollectible> CollectibleGiven;

var Vector SpawnPoint;


event PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayerHarry = harry(Level.PlayerHarryActor);

	if ( SpawnSound == None )
	{
		SpawnSound = CollectibleGiven.Default.PickUpSound;
	}
}

event Activate(Actor Other, Pawn Instigator)
{
	ProcessTrigger();
}

function ProcessTrigger()
{
	GotoState('stateGiveCollectible');
}

function SpawnCollectible()
{
	local MOCACollectible NewCollectible;
	NewCollectible = Spawn(CollectibleGiven,,,SpawnPoint);
	PlaySound(SpawnSound);
	NewCollectible.nPickupIncrement = IncrementPerCollectible;
	NewCollectible.DoPickupProp();
}

state stateGiveCollectible
{
	event BeginState()
	{
		SpawnPoint = Location + SpawnLocationOffset;
		CollectibleSG = PlayerHarry.managerStatus.GetStatusGroup(CollectibleGiven.Default.classStatusGroup);
		CollectibleSI = CollectibleSG.GetStatusItem(CollectibleGiven.Default.classStatusItem);
	}

	begin:
		if ( NumberGiven <= 0 )
		{
			GotoState(LastValidState);
		}

		SpawnCollectible();
		NumberGiven--;
		Sleep(TimeBetweenSpawns);
		Goto('begin');
}

defaultproperties
{
	NumberToGive=8
	IncrementPerCollectible=1
	TimeBetweenSpawns=0.1
}