class MOCASpongifyPad extends SpongifyPad;

var() bool bDeactivateOnJump;	// Moca: Should pad deactivate on jump? Def: False
var() Sound JumpSFX;			// Moca: What sound to play for jump. Def: JumpSFX=Sound'SPN_bounce_on'


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
		if ( fxSheet.DrawScale > DrawScale )
		{
			fxSheet.DrawScale -= 4 * fTimeDelta;
		}
		else
		{
			fxSheet.DrawScale = DrawScale;
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
		fxSheet = Spawn(Class'SpongifySheet',Self,,Location);
		fxSheet.DrawScale = DrawScale;
		fxSheet.SetCollisionSize(CollisionRadius,CollisionHeight,CollisionWidth);
		fxSheet.DesiredRotation = rot(0,0,0);
		fxSheet.DesiredRotation.Yaw += 16383;
		fxSheet.SetRotation(fxSheet.DesiredRotation);
	}

	if ( fxSparkles == None )
	{
		if( CollideType == CT_AlignedCylinder || CollideType == CT_OrientedCylinder || CollisionWidth == 0 )
		{
			hwd = Vec(CollisionRadius,CollisionRadius,CollisionHeight);
		}
		else
		{
			hwd = Vec(CollisionRadius,CollisionWidth,CollisionHeight);
		}

		hwdRotated = hwd >> Rotation;
		fxSparkles = Spawn(fxSparklesClass,Self,,Location);
		fxSparkles.SourceDepth.Base = hwdRotated.X * 2.0;
		fxSparkles.SourceWidth.Base = hwdRotated.Y * 2.0;
		fxSparkles.SourceHeight.Base = hwdRotated.Z * 1.0;
	}
}

function OnBounce (Actor Other)
{
	PlayerHarry.ClientMessage(" ONBounce called "$string(Other));
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

		fxSheet.DrawScale = DrawScale * 2;
		bBouncing = True;
		PlaySound(JumpSFX,SLOT_None,,True);

		TriggerEvent(Event,Self,Self);

		if ( bDeactivateOnJump )
		{
			GotoState('stateGoingToDisabled');
		}
	}
}


defaultproperties
{
	JumpSFX=Sound'SPN_bounce_on'
}