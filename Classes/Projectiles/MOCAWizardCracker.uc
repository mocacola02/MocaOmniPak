// cracker without the barrel
class MOCAWizardCracker extends MOCAPawn;

var() float SwellRate; 				//Moca: How long does it take for the cracker to swell up? 1.0 is regular speed, 2.0 is 2x speed, etc. Def: 1.5
var() float BurstDelay; 			//Moca: How long to wait after done swelling to burst? Def: 2.0
var() float BurstRadius; 			//Moca: How far does the burst reach?
var() float BurstDamage; 			//Moca: How much damage does the burst do? This represents the maximum damage if bBurstFalloff=True. Def: 15.0
var() float bDirectHitDamage; 		//Moca: How much damage should a direct hit on Harry do? Def: 20.0
var() float CameraShakeIntensity; 	//Moca: How much should the camera shake from bursts? Def: 100.0
var() float CameraShakeDuration; 	//Moca: How long should camera shake. Def: 0.75

var() bool bActAsSpell; 				//Moca: Should the fire cracker act as a spell? Works similarly to SwordMode activating spell functions. Def: False
var() bool bBurstFalloff; 			//Moca: Should less damage be done the further away from the burst Harry is? Def: True
var() bool bExplodeOnTouch; 			//Moca: Should the wizard cracker explode on touch? Aka it cannot be picked up. Def: False
var() bool bWaitForSwell; 			//Moca: Should we wait for the swelling to finish before starting BurstDelay? Def: True

var(MOCAWizardCrackerSounds) Sound SwellSound;	// Moca: What sound to play when swelling?
var(MOCAWizardCrackerSounds) Sound PopSound;	// Moca: What sound to play when bursting?
var(MOCAWizardCrackerSounds) Sound LandSound;	// Moca: What sound to play when landing on the ground?
var(MOCAWizardCrackerSounds) Sound PulseSound;	// Moca: What sound to play when pulsing?
var(MOCAWizardCrackerSounds) float MinPopPitch;	// Moca: Minimum burst sound pitch
var(MOCAWizardCrackerSounds) float MaxPopPitch;	// Moca: Maximum burst sound pitch

var bool bIsSwelling;
var bool bDirectHit;
var bool bCanHitHarry;
var vector LastSafeLocation;

var float WCSoundRadius;

function Burst();
function float DetermineDamage(float Distance);

event PostBeginPlay()
{
	Super.PostBeginPlay();
	
	if (WCSoundRadius == 9)
	{
		WCSoundRadius = BurstRadius * 0.5;
	}
}

event FellOutOfWorld()
{
    local vector HandPos;
    HandPos = PlayerHarry.BonePos('bip01 R Hand');
    SetLocation(HandPos);
}

function float GetRandomPitch(float fMin, float fMax)
{
	return RandRange(fMin,fMax);
}

function PrepareTimer()
{
    local float FinalWaitTime;
    if (bWaitForSwell)
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

        if (bExplodeOnTouch)
        {
            bObjectCanBePickedUp = False;
        }
    }

    event EndEvent()
    {
        bObjectCanBePickedUp = False;
    }

    event Touch (Actor Other)
    {
        if (bExplodeOnTouch && (Other.IsA('HChar') || Other.IsA('harry')))
        {
            Log(string(self) $ " hit HChar " $ string(Other));
            bDirectHit = Other.IsA('harry');
            GotoState('stateBurst');
        }
    }
}

state stateBeingThrown
{
    event BeginState()
    {
        PlayerHarry.ActorToCarry = None;
        bCanHitHarry = false;
        SetCollision(true,false,false);
    }

    event Touch (Actor Other)
    {
        if (Other.IsA('HChar') || (Other.IsA('harry') && bCanHitHarry))
        {
            Log(string(self) $ " hit HChar " $ string(Other));
            bDirectHit = Other.IsA('harry');
            GotoState('stateBurst');
        }
    }

    event Landed(vector HitNormal)
    {
		PlaySound(LandSound,SLOT_Interact,,,WCSoundRadius);
        GotoState('stateSwell');
    }

    begin:
        sleep(0.25);
        bCanHitHarry = true;
        
}

state stateSwell
{
    begin:
        SetCollision(true,false,false);
        bObjectCanBePickedUp = True;
        if (!bIsSwelling)
        {
            bIsSwelling = True;
            PrepareTimer();
			PlaySound(SwellSound,SLOT_Misc,,,WCSoundRadius);
            PlayAnim('swell',SwellRate);
            FinishAnim();
			PlaySound(PulseSound,SLOT_Misc,,,WCSoundRadius,,,true);
            LoopAnim('shake');
        }
}

state stateBurst
{
    event BeginState()
    {
        if (PlayerHarry.ActorToCarry == Self)
        {
            PlayerHarry.DropCarryingActor(True);
        }
        
        Burst();
    }

    function Burst()
    {
        local float DistanceFromHarry;

		StopSound(PulseSound);

        if (bActAsSpell)
        {
            PlayerHarry.AutoHitAreaEffect(BurstRadius);
        }

        DistanceFromHarry = VSize(Location - PlayerHarry.Location);

        if (DistanceFromHarry < BurstRadius)
        {
            local float DamageToDeal;
            local float ShakeAmount;
            DamageToDeal = DetermineDamage(DistanceFromHarry);
            PlayerHarry.TakeDamage(DamageToDeal,self,Location,Velocity,'MOCAWizardCracker');

            ShakeAmount = DamageToDeal / BurstDamage;
            ShakeAmount *= CameraShakeIntensity;
            PlayerHarry.ShakeView(0.2,ShakeAmount,ShakeAmount);
        }

		PlaySound(PopSound,SLOT_Interact,,,WCSoundRadius,GetRandomPitch(MinPopPitch,MaxPopPitch));

        Spawn(class'Firecracker_Burst',,,Location);

        GotoState('stateKill');
    }

    function float DetermineDamage(float Distance)
    {
        if (bDirectHit)
        {
            return bDirectHitDamage;
        }

        if (!bBurstFalloff)
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
    bDirectHitDamage=20.0
    CameraShakeIntensity=100.0
    CameraShakeDuration=0.75
    
    bBurstFalloff=True
    bWaitForSwell=True
	
	SwellSound=MultiSound'wizard_cracker_swell_multi'
	PopSound=Sound'wizard_cracker_pop'
	LandSound=MultiSound'wizard_cracker_land_multi'
	PulseSound=Sound'wizard_cracker_pulse'
	MinPopPitch=0.85
	MaxPopPitch=1.15
}