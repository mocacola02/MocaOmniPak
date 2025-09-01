class MOCASpongifyPad extends SpongifyPad;

var() float PadSize;     // Custom size for the pad, only works if UseDrawScale is false. Def: 1.0
var() bool UseCollisionRadius; // Use this SpongifyPad's collision radius as the PadSize? Def: True

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (UseCollisionRadius)
	{
		PadSize = (CollisionRadius / 48);
	}
}

function UpdateSpecialFX (float fTimeDelta)
{
	fxSparkles.SetRotation(Rotation);
	fxSparkles.SetLocation(Location);
	fxSheet.DesiredRotation = Rotation;
	fxSheet.DesiredRotation.Yaw += 16383;
	fxSheet.SetRotation(fxSheet.DesiredRotation);
	fxSheet.SetLocation(Location);
	if ( bBouncing )
	{
		if ( fxSheet.DrawScale > PadSize )
		{
		fxSheet.DrawScale -= 4 * fTimeDelta;
		} else {
		fxSheet.DrawScale = PadSize;
		bBouncing = False;
		}
	}
}

function TurnOnSpecialFX()
{
  local Vector hwd;
  local Vector hwdRotated;

  if ( fxSheet == None )
  {
    fxSheet = Spawn(Class'SpongifySheet',self,,Location);
    fxSheet.DrawScale = PadSize;
    fxSheet.DesiredRotation = rot(0,0,0);
    fxSheet.DesiredRotation.Yaw += 16383;
    fxSheet.SetRotation(fxSheet.DesiredRotation);
  }
  if ( fxSparkles == None )
  {
    // if ( (bool(CollideType) == bool(0)) || (bool(CollideType) == bool(1)) || (CollisionWidth == byte(0)) )
    if( CollideType == CT_AlignedCylinder || CollideType == CT_OrientedCylinder || CollisionWidth == 0 )
	{
      hwd = Vec(CollisionRadius,CollisionRadius,CollisionHeight);
    } else {
      hwd = Vec(CollisionRadius,CollisionWidth,CollisionHeight);
    }
    hwdRotated = hwd >> Rotation;
    fxSparkles = Spawn(fxSparklesClass,self,,Location);
    fxSparkles.SourceDepth.Base = hwdRotated.X * 2.0;
    fxSparkles.SourceWidth.Base = hwdRotated.Y * 2.0;
    fxSparkles.SourceHeight.Base = hwdRotated.Z * 1.0;
  }
}

function OnBounce (Actor Other)
{
	PlayerHarry.ClientMessage(" ONBounce called " $ string(Other));
	if ( Other.IsA('harry') )
	{
		if ( Target != None )
		{
			Other.Velocity = ComputeTrajectoryByTime(Location,Target.Location,fTimeToHitTarget);
		} 
		else 
		{
			Other.Velocity = PadDir * PadSpeed;
		}
		fxSheet.DrawScale = PadSize * 2;
		bBouncing = True;
		PlaySound(Sound'SPN_bounce_on',SLOT_None,,True);
	}
}

defaultproperties
{
     PadSize=1
	 UseCollisionRadius=True
}
