class MOCASpawner extends MOCAPawn;

struct SpawnedProperties
{
    var() string PropertyName;          // Moca: What property should be changed?
    var() string PropertyValue;         // Moca: What value to set for the property?
};

struct SpawnSettings
{
    var() Class<actor> actorToSpawn;    // Moca: What actor class to spawn
    var() Byte spawnChance;             // Moca: How likely is it to spawn if bUseSpawnChance == true? Higher number means more likely to spawn
    var() float spawnDelay;             // Moca: How much of a delay in seconds after spawning?
    var() vector spawnLocationOffset;   // Moca: Location offset to set to spawned actor and particle
    var() Rotator spawnRotation;        // Moca: Rotation of spawned actor
    var() float velocityMult;           // Moca: How much velocity to apply in the direction the spawner is facing? 0.0 = no velocity, 1.0 = default velocity, 2.0 = double velocity, and so on.
    var() Sound spawnSound;             // Moca: Sound to play when spawning this actor.
    var() class<ParticleFX> spawnParticle;  // Moca: Particle to use when spawning this actor
    var() array<SpawnedProperties> spawnProperties; // Moca: Properties to set on the spawned actor
};

var(MOCASpawnActors) array<SpawnSettings> listOfSpawns; // Moca: What should we spawn and what settings?
var(MOCASpawnActors) bool bRandomSpawnOrder;    // Moca: Should particles spawn in no particular order? Def: True
var(MOCASpawnActors) bool bUseSpawnChance;   // Moca: Should spawn chance be taken into consideration? Def: False
var(MOCASpawnActors) bool bVaryVelocity; // Moca: Should the velocity of spawn items be varied to avoid landing in the same place? Def: True
var(MOCASpawnActors) int maxVelocityVariance; // Moca: Maximum amount of variance to apply to spawn velocity. Def = 16

var(MOCASpawnAmount) int numberToSpawn;        // Moca: How many actors to spawn. Ignored if minAmountToSpawn and maxAmountToSpawn are set. If all are 0, this will be set to 4. Def: 4
var(MOCASpawnAmount) int minAmountToSpawn;     // Moca: Minimum amount of items to spawn. If both min and max values are 0, we will use a set amount. Def: 0
var(MOCASpawnAmount) int maxAmountToSpawn;     // Moca: Maximum amount of items to spawn. If both min and max values are 0, we will use a set amount. Def: 0
var(MOCASpawnAmount) int maxLives;          // Moca: How many times can the spawner be activated? Def: 4

var array<float> spawnWeights;

var bool bNoWeights;

var int maxIndex;
var int currentSpawnIndex;
var int numOfSpawns;
var int maxSpawns;

var ESpellType defaultSpell;

var ParticleFX particleOnSpawn;


event PostBeginPlay()
{
    Super.PostBeginPlay();

    defaultSpell = eVulnerableToSpell;

    if (listOfSpawns.Length == 0)
    {
        Log("There is nothing to spawn. Destroying self : " $ string(self));
        Destroy();
    }

    maxIndex = listOfSpawns.Length;

    if (bUseSpawnChance)
    {
        DetermineSpawnWeights();
    }

    if (maxAmountToSpawn > minAmountToSpawn)
    {
        maxSpawns = Clamp(Rand(maxAmountToSpawn), minAmountToSpawn, maxAmountToSpawn);
    }
    else
    {
        maxSpawns = numberToSpawn;
    }
}

event Trigger(Actor Other, Pawn Instigator)
{
    if (IsInState('stateDormant'))
    {
        GotoState('stateSpawn');
    }
}

function DetermineSpawnWeights()
{
    local int i;
    local int totalWeight;

    for (i = 0; i < maxIndex; i++)
    {
        totalWeight += int(listOfSpawns[i].spawnChance);
    }

    Log("totalWeight = " $ string(totalWeight));

    for (i = 0; i < maxIndex; i++)
    {
        spawnWeights[i] = float(listOfSpawns[i].spawnChance) / float(totalWeight);
    }
}

function Sound GetSpawnSound()
{
    local Sound currentSpawnSound;

    currentSpawnSound = listOfSpawns[currentSpawnIndex].spawnSound;

    return currentSpawnSound;
}

function class<ParticleFX> GetSpawnParticle()
{
    local class<ParticleFX> currentParticle;

    currentParticle = listOfSpawns[currentSpawnIndex].spawnParticle;

    return currentParticle;
}

function SpawnItem()
{
    local ParticleFX spawnedParticle;
    local Actor spawnedActor;
    local Vector spawnLocation;
    local int i;
    local vector Dir;
    local vector RandOffset;
    local float RandAmount;
    local int RandAmountMult;

    if (bRandomSpawnOrder)
    {
        currentSpawnIndex = Rand(listOfSpawns.Length);
    }
    else
    {
        currentSpawnIndex = numOfSpawns;
        if (currentSpawnIndex > listOfSpawns.Length)
        {
            currentSpawnIndex = 0;
        }
    }

    spawnLocation = Location + listOfSpawns[currentSpawnIndex].spawnLocationOffset;

    spawnedParticle = Spawn(GetSpawnParticle(),,,spawnLocation);

    spawnedParticle.PlaySound(GetSpawnSound());

    spawnedActor = Spawn(listOfSpawns[currentSpawnIndex].actorToSpawn,,,spawnLocation, listOfSpawns[currentSpawnIndex].spawnRotation);
    
    Dir = Vector(Rotation);

    if (bVaryVelocity)
    {
        RandAmountMult = Clamp(Rand(maxVelocityVariance),2,maxVelocityVariance);
        RandAmount = FRand() * RandAmountMult;
        
        RandOffset.X = RandAmount * FRand();
        RandOffset.Y = RandAmount * FRand();
        RandOffset.Z = RandAmount * FRand();
    }

    Dir = Normal(Dir + RandOffset);
    
    spawnedActor.Velocity = Dir * ((128 + Rand((maxVelocityVariance * 8))) * listOfSpawns[currentSpawnIndex].velocityMult);

    if (listOfSpawns[currentSpawnIndex].spawnProperties.Length != 0)
    {
        for(i = 0; i < listOfSpawns[currentSpawnIndex].spawnProperties.Length; i++)
        {
            if (listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyName != "" && listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyValue != "")
            {
                Log("Setting spawned actor's property " $ listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyName $ " to " $ listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyValue);
                spawnedActor.SetPropertyText(listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyName, listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyValue);
            }
        }
    }

    numOfSpawns++;
}

auto state stateDormant
{
    event BeginState()
    {
        numOfSpawns = 0;
        eVulnerableToSpell = defaultSpell;
    }

    event EndState()
    {
        maxLives--;
        eVulnerableToSpell = SPELL_None;
    }
}


state stateSpawn
{
    begin:
        SpawnItem();
        sleep(listOfSpawns[currentSpawnIndex].spawnDelay);
        if (numOfSpawns >= maxSpawns)
        {
            GotoState('stateDone');
        }

        goto('begin');
}

state stateDone
{
    begin:
        if (maxLives <= 0)
        {
            sleep(5.0);
            Log("Destroying MOCASpawner: " $ string(self));
            Destroy();
        }
        else
        {
            sleep(1.0);
            GotoState('stateDormant');
        }
}

function ProcessSpell()
{
    GotoState('stateSpawn');
}


defaultproperties
{
    listOfSpawns(0)=(actorToSpawn=Class'Jellybean',spawnChance=255,spawnDelay=1.0,spawnSound=Sound'spawn_bean01',spawnParticle=Class'Spawn_flash_1',velocityMult=1.0)
    eVulnerableToSpell=SPELL_Flipendo
    bRandomSpawnOrder=true
    numberToSpawn=4
    maxLives=4
    DrawType=DT_Sprite
    Texture=Texture'MocaTexturePak.EditorIco.MOCASpawnerIcon'
    bHidden=True
    bVaryVelocity=True
    maxVelocityVariance=4
    bBlockPlayers=false
}