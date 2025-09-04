// cracker without the barrel
class MOCAWizardCracker extends HPawn;

var() float SwellRate; //Moca: How long does it take for the cracker to swell up? 1.0 is regular speed, 2.0 is 2x speed, etc. Def: 1.5
var() float BurstDelay; //Moca: How long to wait after done swelling to burst? Def: 2.0
var() float BurstRadius; //Moca: How far does the burst reach?
var() float BurstDamage; //Moca: How much damage does the burst do? This represents the maximum damage if BurstFalloff=True. Def: 15.0
var() float DirectHitDamage; //Moca: How much damage should a direct hit on Harry do? Def: 20.0

var() bool ActAsSpell; //Moca: Should the fire cracker act as a spell? Works similarly to SwordMode activating spell functions. Def: False
var() bool BurstFalloff; //Moca: Should less damage be done the further away from the burst Harry is? Def: True
var() bool ExplodeOnTouch; //Moca: Should the wizard cracker explode on touch? Aka it cannot be picked up. Def: False
var() bool WaitForSwell; //Moca: Should we wait for the swelling to finish before starting BurstDelay? Def: True

var bool IsSwelling;
var bool DirectHit;
var bool CanHitHarry;

function Burst();
function float DetermineDamage(float Distance);

function PrepareTimer()
{
    local float FinalWaitTime;
    if (WaitForSwell)
    {
        FinalWaitTime = BurstDelay + (3.0 * SwellRate);
    }
    else
    {
        FinalWaitTime = BurstDelay;
    }

    SetTimer(FinalWaitTime,false,'DoBurst');
}

function DoBurst()
{
    GotoState('stateBurst');
}

auto state stateDormant
{
    event BeginState()
    {
        LoopAnim('idle');

        if (ExplodeOnTouch)
        {
            bObjectCanBePickedUp = False;
        }
    }

    event Touch (Actor Other)
    {
        if (ExplodeOnTouch && (Other.IsA('HChar') || Other.IsA('harry')))
        {
            Log(string(self) $ " hit HChar " $ string(Other));
            DirectHit = Other.IsA('harry');
            GotoState('stateBurst');
        }
        else
        {
            bObjectCanBePickedUp = False;
        }
    }
}

state stateBeingThrown
{
    event BeginState()
    {
        CanHitHarry = false;
        SetCollision(true,false,false);
    }

    event Touch (Actor Other)
    {
        if (Other.IsA('HChar') || (Other.IsA('harry') && CanHitHarry))
        {
            Log(string(self) $ " hit HChar " $ string(Other));
            DirectHit = Other.IsA('harry');
            GotoState('stateBurst');
        }
    }

    event Landed(vector HitNormal)
    {
        GotoState('stateSwell');
    }

    begin:
        sleep(0.25);
        CanHitHarry = true;
        
}

state stateSwell
{
    begin:
        SetCollision(true,false,false);
        bObjectCanBePickedUp = True;
        if (!IsSwelling)
        {
            IsSwelling = True;
            PrepareTimer();
            PlayAnim('swell',SwellRate);
            FinishAnim();
            LoopAnim('shake');
        }
}

state stateBurst
{
    event BeginState()
    {
        PlayerHarry.DropCarryingActor(True);
        Burst();
    }

    function Burst()
    {
        local float DistanceFromHarry;

        if (ActAsSpell)
        {
            PlayerHarry.AutoHitAreaEffect(BurstRadius);
        }

        DistanceFromHarry = VSize(Location - PlayerHarry.Location);

        if (DistanceFromHarry < BurstRadius)
        {
            PlayerHarry.TakeDamage(DetermineDamage(DistanceFromHarry),self,Location,Velocity,'MOCAWizardCracker');
        }

        Spawn(class'Firecracker_Burst',,,Location);

        GotoState('stateKill');
    }

    function float DetermineDamage(float Distance)
    {
        if (DirectHit)
        {
            return DirectHitDamage;
        }

        if (!BurstFalloff)
        {
            return BurstDamage;
        }

        return BurstDamage * ((BurstRadius - Distance) / BurstRadius);
    }
}

state stateKill
{
    begin:
        SleepForTick();
        Destroy();
}

defaultproperties
{
    attachedParticleClass(0)=Class'HPParticle.WizCrackSparkle'
    bBlockActors=False
    bBlockPlayers=False
    bBlockCamera=False
    bObjectCanBePickedUp=True
    CollideType=CT_Box
    CollisionHeight=6
    CollisionRadius=6
    CollisionWidth=20
    Mesh=SkeletalMesh'MocaModelPak.skwizardcrackerMesh'

    SwellRate=1.5
    BurstDelay=2.0
    BurstRadius=128.0
    BurstDamage=15.0
    DirectHitDamage=20.0
    BurstFalloff=True
    WaitForSwell=True
}