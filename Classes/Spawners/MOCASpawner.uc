class MOCASpawner extends MOCAPawn;

struct SpawnedProperties
{
    var() string PropertyName;
    var() string PropertyValue;
};

struct SpawnSettings
{
    var() Class<actor> actorToSpawn;
    var() Byte spawnChance;
    var() float spawnDelay;
    var() vector spawnLocationOffset;
    var() Rotator spawnRotation;
    var() float velocityMult;
    var() Sound spawnSound;
    var() class<ParticleFX> spawnParticle;
    var() array<SpawnedProperties> spawnProperties;
};

var(MOCASpawnActors) array<SpawnSettings> listOfSpawns;
var(MOCASpawnActors) bool bRandomSpawnOrder;
var(MOCASpawnActors) bool bUseSpawnChance;
var(MOCASpawnActors) bool bVaryVelocity;
var(MOCASpawnActors) int maxVelocityVariance;
var(MOCASpawnActors) bool bTurnSpawnerTowardsHarry;

var(MOCASpawnAmount) int numberToSpawn;
var(MOCASpawnAmount) int minAmountToSpawn;
var(MOCASpawnAmount) int maxAmountToSpawn;
var(MOCASpawnAmount) int maxLives;

var array<float> spawnWeights;
var bool bNoWeights;

var int maxIndex;
var int currentSpawnIndex;
var int numOfSpawns;
var int maxSpawns;

var ESpellType defaultSpell;
var ParticleFX particleOnSpawn;

var(MOCASpawnGlobal) bool bUseGlobalSpawnSettings;
var(MOCASpawnGlobal) vector GlobalSpawnOffset;
var(MOCASpawnGlobal) rotator GlobalSpawnDirection;
var(MOCASpawnGlobal) vector GlobalSpawnAngle;

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

    for (i = 0; i < maxIndex; i++)
    {
        spawnWeights[i] = float(listOfSpawns[i].spawnChance) / float(totalWeight);
    }
}

function Sound GetSpawnSound()
{
    return listOfSpawns[currentSpawnIndex].spawnSound;
}

function class<ParticleFX> GetSpawnParticle()
{
    return listOfSpawns[currentSpawnIndex].spawnParticle;
}

function vector GetRandomizedDirection()
{
    local vector Dir;
    local float u, v, theta, phi;
    local float RandPitch, RandYaw;
    local rotator Offset;
    local float DegToUnr;

    DegToUnr = 65536.0 / 360.0;

    if (GlobalSpawnAngle.Y >= 180.0 && GlobalSpawnAngle.X >= 180.0)
    {
        u = FRand();
        v = FRand();

        theta = 2.0 * PI * u;
        phi   = Acos(2.0 * v - 1.0);

        Dir.X = Sin(phi) * Cos(theta);
        Dir.Y = Sin(phi) * Sin(theta);
        Dir.Z = Cos(phi);

        return Normal(Dir);
    }

    RandPitch = (FRand() * 2.0 - 1.0) * GlobalSpawnAngle.X;
    RandYaw   = (FRand() * 2.0 - 1.0) * GlobalSpawnAngle.Y;

    Offset.Pitch = int(RandPitch * DegToUnr);
    Offset.Yaw   = int(RandYaw   * DegToUnr);
    Offset.Roll  = 0;

    Dir = Vector(GlobalSpawnDirection + Offset);

    return Normal(Dir);
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
    local rotator FinalRot;

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

    if (bUseGlobalSpawnSettings)
    {
        spawnLocation = Location + GlobalSpawnOffset + listOfSpawns[currentSpawnIndex].spawnLocationOffset;
    }
    else
    {
        spawnLocation = Location + listOfSpawns[currentSpawnIndex].spawnLocationOffset;
    }

    spawnedParticle = Spawn(GetSpawnParticle(),,,spawnLocation);

    if (spawnedParticle != None)
    {
        spawnedParticle.PlaySound(GetSpawnSound());
    }

    if (bUseGlobalSpawnSettings)
    {
        Dir = GetRandomizedDirection();
        FinalRot = rotator(Dir);
    }
    else
    {
        FinalRot = Rotation + listOfSpawns[currentSpawnIndex].spawnRotation;
        Dir = Vector(FinalRot);
    }

    spawnedActor = Spawn(listOfSpawns[currentSpawnIndex].actorToSpawn,,,spawnLocation, FinalRot);

    if (bVaryVelocity)
    {
        RandAmountMult = Clamp(Rand(maxVelocityVariance),2,maxVelocityVariance);
        RandAmount = FRand() * RandAmountMult;

        RandOffset.X = (FRand() * 2.0 - 1.0) * RandAmount;
        RandOffset.Y = (FRand() * 2.0 - 1.0) * RandAmount;
        RandOffset.Z = (FRand() * 2.0 - 1.0) * RandAmount;
    }
    else
    {
        RandOffset = vect(0,0,0);
    }

    Dir = Normal(Dir + RandOffset);

    spawnedActor.Velocity = Dir * ((128 + Rand((maxVelocityVariance * 8))) * listOfSpawns[currentSpawnIndex].velocityMult);

    if (listOfSpawns[currentSpawnIndex].spawnProperties.Length != 0)
    {
        for(i = 0; i < listOfSpawns[currentSpawnIndex].spawnProperties.Length; i++)
        {
            if (listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyName != "" && listOfSpawns[currentSpawnIndex].spawnProperties[i].PropertyValue != "")
            {
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
	event BeginState()
	{
		if (bTurnSpawnerTowardsHarry)
		{
			EnableTurnTo(PlayerHarry);
		}
	}

	event EndState()
	{
		if (bTurnSpawnerTowardsHarry)
		{
			DisableTurnTo();
		}
	}

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

    GlobalSpawnOffset=(X=0,Y=0,Z=0)
    GlobalSpawnDirection=(Pitch=0,Yaw=0,Roll=0)
    GlobalSpawnAngle=(X=20,Y=20,Z=0)
}
