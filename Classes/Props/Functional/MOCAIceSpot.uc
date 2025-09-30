class MOCAIceSpot extends MOCAPawn;

var() float TimeToLive; 		// Moca: How long should ice remain? Def: 60.0
var() float GrowthTime; 		// Moca: How long should it take for the ice to grow in seconds? Def: 5.0
var() ESpellType ShatterSpell; 	// Moca: What spell, if any, should shatter the ice if cast on? Def: SPELL_Flipendo
var() bool bUseMoverCollision;   // Moca: If true, model collision will not be applied and instead will send an event (based on the Event property) to trigger a mover when freezing/melting/shattering. Intended to be used with an invisible mover for special poly collision. Def: False

var float CurrentGrowthTime;
var Iceberg_Grow FreezeParticles;
var IceBerg_Spot IdleParticles;

event PreBeginPlay()
{
    super.PreBeginPlay();
}

event PostBeginPlay()
{
    super.PostBeginPlay();
    FreezeParticles = Spawn(class'Iceberg_Grow',Self,,Location,,True);
    IdleParticles = Spawn(class'IceBerg_Spot',Self,,Location,,True);
}

function ChangeBergSize(float DeltaTime, optional bool Reverse)
{
    local float Alpha;

    CurrentGrowthTime += DeltaTime;

    if (CurrentGrowthTime > GrowthTime)
    {
        CurrentGrowthTime = GrowthTime;
    }
    
    if (Reverse)
    {
        Alpha = 1 - (CurrentGrowthTime / GrowthTime);
    }
    else
    {
        Alpha = CurrentGrowthTime / GrowthTime;
    }

    local float tempRadius;
    local float tempWidth;
    local float tempHeight;

    tempRadius = Lerp(Alpha, 0.0, MapDefault.CollisionRadius);
    tempWidth  = Lerp(Alpha,  0.0,  MapDefault.CollisionWidth);
    tempHeight = Lerp(Alpha, 0.0, MapDefault.CollisionHeight);

    SetCollisionSize(tempRadius,tempHeight,tempWidth);

    DrawScale = Lerp(Alpha, 0.0, MapDefault.DrawScale);
}

auto state stateDormant
{
    event BeginState()
    {
        eVulnerableToSpell = MapDefault.eVulnerableToSpell;
        DrawScale = 0.0;
        SetCollision(true,false,false);
        SetCollisionSize(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth);
        IdleParticles.bEmit = True;
    }

    event EndState()
    {
        IdleParticles.bEmit = False;
    }

    function ProcessSpell()
    {
        GotoState('stateFreeze');
    }
}

state stateFreeze
{
    event Tick(float DeltaTime)
    {
		Global.Tick(DeltaTime);

        if (CurrentGrowthTime < GrowthTime)
        {
            ChangeBergSize(DeltaTime);
        }
        else
        {
            GotoState('stateFrozen');
        }
    }

    event BeginState()
    {
        eVulnerableToSpell = SPELL_None;
        SetCollision(true,true,true);
        FreezeParticles.bEmit = true;
    }

    event EndState()
    {
        CurrentGrowthTime = 0;
        FreezeParticles.bEmit = false;
    }
}

state stateFrozen
{
    event BeginState()
    {
        DrawScale = MapDefault.DrawScale;
        SetCollisionSize(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth);
        eVulnerableToSpell = ShatterSpell;
    }

    function ProcessSpell()
    {
        GotoState('stateShatter');
    }
}

state stateShatter
{
    event BeginState()
    {
        eVulnerableToSpell = SPELL_None;
        Spawn(class'Ice_Break',self,,Location);
        DrawScale = 0.0;
        SetCollision(true,false,false);
        SetCollisionSize(MapDefault.CollisionRadius,MapDefault.CollisionHeight,MapDefault.CollisionWidth);
    }

    begin:
        sleep(1.0);
        GotoState('stateDormant');
        
}

defaultproperties
{
    TimeToLive=60.0
    GrowthTime=5.0
    eVulnerableToSpell=SPELL_LocomotorWibbly
    ShatterSpell=SPELL_Flipendo
    Mesh=SkeletalMesh'MocaModelPak.skIceberg1'

    CollisionHeight=8
    CollisionRadius=150
    CollisionWidth=0

    bGestureFaceHorizOnly=False

    PrePivot=(X=0,Y=0,Z=8)
}