class MOCACollectibleTrigger extends spellTrigger;

var() int NumberToGive;				// Moca: How many of the collectible should be given? Def: 8
var() int IncrementPerCollectible;	// Moca: How much does each individual collectible count for? Def: 1
var() float TimeBetweenSpawns;		// Moca: How long to wait in between given collectibles? Def: 0.1
var() Vector SpawnLocationOffset;	// Moca: Offset to spawn location. Def: (0,0,0)
var() Sound SpawnSound;				// Moca: Sound to play on spawn. If none, uses default collectible sound. Def: None

var() class<MOCACollectible> CollectibleGiven;	// Moca: What collectible class should be given? Def: class'MOCAJellybean'

var Vector SpawnPoint;	// Spawn point of collectibles


///////////////////
// Main Functions
///////////////////

function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	// If spawn sound is none, use default sound
	if ( SpawnSound == None )
	{
		SpawnSound = CollectibleGiven.Default.PickUpSound;
	}
	// Give collectibles
	GotoState('stateGiveCollectible');
}

function SpawnCollectible()
{
	local MOCACollectible NewCollectible;
	// Spawn new collectibles
	NewCollectible = Spawn(CollectibleGiven,,,SpawnPoint);
	// Play spawn sound
	PlaySound(SpawnSound);
	// Set increment amount
	NewCollectible.nPickupIncrement = IncrementPerCollectible;
	// Pickup collectible
	NewCollectible.DoPickupProp();
}

state stateGiveCollectible
{
	event BeginState()
	{
		local StatusGroup CollectibleSG;
		local StatusItem CollectibleSI;
		// Calculate spawn point
		SpawnPoint = Location + SpawnLocationOffset;
		// Get collectible's status group and status item
		CollectibleSG = harry(Level.PlayerHarryActor).managerStatus.GetStatusGroup(CollectibleGiven.Default.classStatusGroup);
		CollectibleSI = CollectibleSG.GetStatusItem(CollectibleGiven.Default.classStatusItem);
	}

	begin:
		// If done giving collectibles, go to initial state
		if ( NumberToGive <= 0 )
		{
			GotoState(InitialState);
		}

		// Spawn collectible
		SpawnCollectible();
		// Decrease number to give
		NumberToGive--;
		// Wait
		Sleep(TimeBetweenSpawns);
		// Loop
		Goto('begin');
}

defaultproperties
{
	NumberToGive=8
	IncrementPerCollectible=1
	TimeBetweenSpawns=0.1
	CollectibleGiven=class'MOCAJellybean'
}