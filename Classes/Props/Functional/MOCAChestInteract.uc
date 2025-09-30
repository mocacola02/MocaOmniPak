//================================================================================
// MOCAChestInteract.
//================================================================================

// TODO: Rewrite this. pretty old class

class MOCAChestInteract extends MOCAInteractProp;

const nMAX_EJECTED_OBJECTS= 8;
var() int iNumberOfBeans;
var() Class<Actor> NonRandomObjects[8];
var() Vector ObjectStartPoint[8];
var() Vector ObjectStartVelocity[8];
var() bool bRandomDrops;
var() bool bMakeSpawnPersistent;
var() Class<Actor> RandomObjects[8];
var() Sound openSound;
var() name openAnimation;
var() float openAnimationRate;
var bool bOpened;
var int iBean;

// Function to execute when hit by the line trace
function LineTraceHit() {
    if (!doOnceFulfilled) {
        Super.LineTraceHit();
        GotoState('turnover');
    }
}

function int GetMaxEjectedObjects()
{
  // return 8;
  return nMAX_EJECTED_OBJECTS;
}

function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
  {
    local Vector spawnLoc;
    local Actor newSpawn;
  
    GotoState('turnover');
    return True;
  }

function SetupRandomBeans()
{
  //local int iBean;
  local int iBeanObject;

  // iBean = 0;
  // if ( iBean < iNumberOfBeans )
  for(iBeanObject = 0; iBeanObject < iNumberOfBeans; iBeanObject++)
  {
    if ( Rand(100) < (30 - (PlayerHarry.GetHealth() * 30)) && iBeanObject == 0 )
    {
      NonRandomObjects[iBeanObject] = Class'ChocolateFrog';
    } else {
      switch (Rand(7))
      {
        case 0:
        NonRandomObjects[iBeanObject] = RandomObjects[0];
        break;
        case 1:
        NonRandomObjects[iBeanObject] = RandomObjects[1];
        break;
        case 2:
        NonRandomObjects[iBeanObject] = RandomObjects[2];
        break;
        case 3:
        NonRandomObjects[iBeanObject] = RandomObjects[3];
        break;
        case 4:
        NonRandomObjects[iBeanObject] = RandomObjects[4];
        break;
        case 5:
        NonRandomObjects[iBeanObject] = RandomObjects[5];
        break;
        case 6:
        NonRandomObjects[iBeanObject] = RandomObjects[6];
        break;
        case 7:
        NonRandomObjects[iBeanObject] = RandomObjects[7];
        break;
        default:
      }
    }
    // iBean++;
    // goto JL0007;
  }
}

state stillOpen
{
begin:
  LoopAnim('End');
}

auto state waitforspell
{
  event BeginState()
  {
    if ( bOpened )
    {
      GotoState('stillOpen');
    }
  }
  
 begin:
  if (  !bOpened )
  {
    LoopAnim('Start');
  }
}

state turnover
{
  event BeginState()
  {
    bOpened = True;
    eVulnerableToSpell = SPELL_None;
    Level.PlayerHarryActor.ClientMessage(" Chest " $ string(self) $ " is opening so bOpened = " $ string(bOpened));
  }
  
function generateobject()
{
    local Vector SpawnLocation;
    local Vector Vel;
    local Actor newSpawn;
    local Rotator SpawnDirection;
    local Rotator HarryDirection;
    local Rotator DifRotation;
    local bool bPlayBeanSound;
    local bool bPlayWCardSound;
    local Vector HitLocation;
    local Vector HitNormal;
    local int RandZVel;
    local int RandYVel;
    local int RandXVel;
    local int RandYLoc;
    local int RandXLoc;
    local Vector StartVector;

    Vel = ObjectStartVelocity[iBean];
    Vel.X += (-16 + Rand(96));
    if (Vel.X < 0)
    {
        Vel.X = 0.0;
    }
    SpawnDirection = Rotation;
    Vel = Vel >> SpawnDirection;
    SpawnLocation = ObjectStartPoint[iBean];
    SpawnLocation = SpawnLocation >> SpawnDirection;
    SpawnLocation = SpawnLocation + Location;

    // Spawn the actor and get the actual spawn location
    newSpawn = Spawn(Class'Spawn_flash_1',,, SpawnLocation, rot(0, 0, 0));
    SpawnLocation = newSpawn.Location;
    newSpawn = Spawn(Class'Spawn_flash_1',,, SpawnLocation, rot(0, 0, 0));

    // Optionally, you can check if newSpawn is valid here before proceeding
    if (newSpawn != None)
    {
        newSpawn = FancySpawn(NonRandomObjects[iBean % 8],,, SpawnLocation, Rotation);

        // Adjust the velocity after spawning if needed
        if (newSpawn.IsA('ChocolateFrog'))
        {
            newSpawn.Velocity = Vel * 2;
            bPlayBeanSound = True;
        }
        else if (newSpawn.IsA('WizardCardIcon'))
        {
            Vel = ObjectStartVelocity[iBean];
            Vel.X += 20;
            SpawnDirection = Rotation;
            Vel = Vel >> SpawnDirection;
            newSpawn.Velocity = Vel;
            HarryDirection = rotator(PlayerHarry.Location - SpawnLocation);
            DifRotation = HarryDirection - SpawnDirection;
            DifRotation.Yaw = DifRotation.Yaw & 65535;
            if ((Abs(DifRotation.Yaw) < 8192) && (VSize(PlayerHarry.Location - SpawnLocation) < 50))
            {
                if (DifRotation.Yaw > 0)
                {
                    newSpawn.Velocity = newSpawn.Velocity << rot(0, 14336, 0);
                }
                else
                {
                    newSpawn.Velocity = newSpawn.Velocity >> rot(0, 14336, 0);
                }
            }
            bPlayWCardSound = True;
        }
        else
        {
            RandXVel = Rand(17) + 48;
            RandYVel = Rand(97) - 48;
            RandZVel = Rand(81) + 120;
            RandXLoc = Rand(27) - 4;
            RandYLoc = Rand(79) - 42;
            StartVector.X = RandXVel;
            StartVector.Y = RandYVel;
            StartVector.Z = RandZVel;
            //Log("Velocity" $ StartVector);
            //ObjectStartVelocity = StartVelocity;
            ObjectStartVelocity[iBean] = StartVector;
            StartVector.X = RandXLoc;
            StartVector.Y = RandYLoc;
            StartVector.Z = 40;
            //Log("Location" $ StartVector);
            ObjectStartPoint[iBean]= StartVector;
            newSpawn.Velocity = Vel;
            bPlayBeanSound = True;
            newSpawn.SetPhysics(PHYS_Falling);
        }

        newSpawn.bPersistent = bMakeSpawnPersistent;

        if (bPlayWCardSound)
        {
            PlaySound(Sound'vendor_spawn_WC');
        }
        else if (bPlayBeanSound)
        {
            switch (Rand(3))
            {
                case 0:
                    PlaySound(Sound'spawn_bean01');
                    break;
                case 1:
                    PlaySound(Sound'spawn_bean02');
                    break;
                case 2:
                    PlaySound(Sound'spawn_bean03');
                    break;
            }
        }
    }
}




 begin:
  PlaySound(openSound);
  PlayAnim(openAnimation,openAnimationRate);
  FinishAnim();
  if ( bRandomDrops )
  {
// JL0039:
    SetupRandomBeans();
  }
  // iBean = 0;
  // if ( iBean < iNumberOfBeans )
  for(iBean = 0; iBean < iNumberOfBeans; iBean++)
  {
    generateobject();
    Sleep(RandRange(0.1,0.3));
    // iBean++;
    // goto JL0039;
  }

  for(iBean = 0; iBean < iNumberOfBeans; iBean++)
  {
    generateobject();
    Sleep(RandRange(0.1,0.3));
    // iBean++;
    // goto JL0039;
  }
  LoopAnim('End');
}

defaultproperties
{
    iNumberOfBeans=4

    RandomObjects(0)=Class'Jellybean'

    RandomObjects(1)=Class'MOCAEssence'

    RandomObjects(2)=Class'Jellybean'

    RandomObjects(3)=Class'MOCAEssence'

    RandomObjects(4)=Class'Jellybean'

    RandomObjects(5)=Class'MOCAEssence'

    RandomObjects(6)=Class'Jellybean'

    RandomObjects(7)=Class'MOCAEssence'

    NonRandomObjects(0)=Class'Jellybean'

    NonRandomObjects(1)=Class'Jellybean'

    NonRandomObjects(2)=Class'Jellybean'

    NonRandomObjects(3)=Class'Jellybean'

    NonRandomObjects(4)=Class'Jellybean'

    NonRandomObjects(5)=Class'Jellybean'

    NonRandomObjects(6)=Class'Jellybean'

    NonRandomObjects(7)=Class'Jellybean'

/** 

    ObjectStartPoint(0)=(X=0.00,Y=0.00,Z=40.00)

    ObjectStartPoint(1)=(X=17.00,Y=-3.00,Z=40.00)

    ObjectStartPoint(2)=(X=2.00,Y=22.00,Z=40.00)

    ObjectStartPoint(3)=(X=-4.00,Y=-18.00,Z=40.00)

    ObjectStartPoint(4)=(X=22.00,Y=19.00,Z=40.00)

    ObjectStartPoint(5)=(X=16.00,Y=-23.00,Z=40.00)

    ObjectStartPoint(6)=(X=8.00,Y=36.00,Z=40.00)

    ObjectStartPoint(7)=(X=12.00,Y=-42.00,Z=40.00)

    ObjectStartVelocity(0)=(X=48.00,Y=0.00,Z=120.00)

    ObjectStartVelocity(1)=(X=64.00,Y=0.00,Z=200.00)

    ObjectStartVelocity(2)=(X=48.00,Y=24.00,Z=120.00)

    ObjectStartVelocity(3)=(X=48.00,Y=-24.00,Z=120.00)

    ObjectStartVelocity(4)=(X=64.00,Y=24.00,Z=200.00)

    ObjectStartVelocity(5)=(X=64.00,Y=-24.00,Z=200.00)

    ObjectStartVelocity(6)=(X=48.00,Y=48.00,Z=150.00)

    ObjectStartVelocity(7)=(X=48.00,Y=-48.00,Z=150.00)

*/
    bRandomDrops=True

    bMakeSpawnPersistent=True

    // Physics=2
	Physics=PHYS_Falling

    // eVulnerableToSpell=1
	eVulnerableToSpell=SPELL_Alohomora

    CentreOffset=(X=0.00,Y=0.00,Z=20.00)

    Mesh=SkeletalMesh'HPModels.skwoodchestMesh'

    DrawScale=2.00

    CollisionRadius=24.00

    CollisionWidth=32.00

    CollisionHeight=24.00

    // CollideType=2
	CollideType=CT_Box

    bProjTarget=False;

    bCollideWorld=True

    openSound=Sound'wood_chest_open'

    openAnimationRate=1.0

    openAnimation=Open
}
