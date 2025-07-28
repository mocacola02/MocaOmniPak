class MOCAChar extends HChar;

var string DebugErrMessage;
var bool inErrorMode;
var name PreviousState;
var() bool bypassErrorMode;
var() int hitsToKill; //Moca: How many hits to kill it? 0 means invincible.
var int HitsLeft;
var() float maxTravelDistance;
var() bool affectAmbience; //Moca: Should this actor contribute to the frequency of ambience being played by MOCAAmbiencePlayer
var() float travelFromHome;
var Vector vHome;
var Vector vNewPos;
var NavigationPoint prevNavP;

var Vector lastHarryPos;
var Vector lastHarryDirection;

event PostBeginPlay()
{
    Super.PostBeginPlay();
    prevNavP = Level.NavigationPointList;
    vHome = Location;
}

function bool ActorExistenceCheck(Class<Actor> ActorToCheck)
{
    local Actor A;

    if (bypassErrorMode)
    {
        return true;
    }
    
    Log("OOOOOOOOOOOOOOOOOOOOOO Checking for actor " @ string(ActorToCheck));
    foreach AllActors(ActorToCheck, A)
    {
        Log("Actor is real!!!!!");
        return true;
    }
    Log("actor is not real");
    return false;
}

function EnterErrorMode()
{
    DrawType = DT_Sprite;
    DrawScale = 0.25;
    Texture = Texture'MocaTexturePak.ICO_ActorErrorBubble';
    Log("IIIIIIIIIIIIIIIIIIIII start printing error");
    inErrorMode = True;
}

function EnableTurnTo(actor TurnTarget)
{
    TurnTo_TargetActor = TurnTarget;
    MakeTurnToPermanentController();
}

function bool IsFacing(Actor Other, float MinDot)  //Courtesy of Omega
{
    local float Dot;
    Dot = Vector(Rotation) Dot Normal(Other.Location - Location);

    if (Dot > MinDot)
    {
        return true;
    }
    return false;
}

function bool IsOtherFacing(Actor Other, float MinDot)
{
    local float Dot;

    // Calculate the direction the 'Other' actor is facing
    Dot = Vector(Other.Rotation) Dot Normal(Location - Other.Location);

    // Check if the current actor is within 'Other's view range based on the MinDot threshold
    if (Dot > MinDot)
    {
        return true;
    }
    return false;
}

function vector GetPointBehindActor(float Distance)
{
    local vector ForwardVector;
    local vector BehindLocation;

    ForwardVector = Vector(Rotation);

    BehindLocation = Location - (ForwardVector * Distance);

    Spawn(Class'MocaTexturePak.MOCADebugSprite',,,BehindLocation);

    return BehindLocation;
}

function bool IsOtherLookingAt(Actor Other, float minDot)
{
    if (IsOtherFacing(Other, minDot) && PlayerCanSeeMe())
    {
        return true;
    }
    return false;
}

function StoreNavP(NavigationPoint inputNav)
{
    prevNavP = inputNav;
}

function bool CheckCost(NavigationPoint inNav)
{
    if (inNav.cost > 0)
    {
        return true;
    }
    return false;
}

function float GetDistanceFromHarry()
{
    return VSize(Location - PlayerHarry.Location);
}

function bool isValidNavP()
{
    if (navP == None || navP == prevNavP)
    {
        return false;
    }
    return true;
}

function NavigationPoint GetFurthestNavPoint(actor actorToCheck)
{
    local NavigationPoint Nav;
    local NavigationPoint FurthestNav;
    local float currentDistance;
    local float maxDistance;
    local vector actorLocation;

    actorLocation = actorToCheck.Location;

    maxDistance = 0;

    Nav = Level.NavigationPointList;

    while (Nav != None)
    {
        currentDistance = VSize(Nav.Location - actorLocation);

        if (currentDistance > maxDistance)
        {
            maxDistance = currentDistance;
            FurthestNav = Nav;
        }

        Nav = Nav.nextNavigationPoint;
    }
    Log("Furthest navP: " @ string(FurthestNav));

    return FurthestNav;
}

function bool ShouldStrafeTo (NavigationPoint WayPoint) //very loosely based on UT
{
    if (WayPoint != None)
    {
        Log("navP != None");
        if (WayPoint.Extracost > 200)
        {
            Log("cost too high");
            return false;
        }
        Log("ShouldStrafeTo");
        return true;
    }
    Log("navP = None");
    return false;
}

function bool CloseToHome()
{
  if ( VSize(Location - vHome) < travelFromHome )
  {
    return True;
  }
  return False;
}

function Vector RandomPosition (Vector NewPos, float fAccuracy)
{
  local Rotator R;
  local Vector D;
  local Vector V;
  local Vector rv;
  local float spread;

  spread = (1.0 - fAccuracy) * 8192;
  D.X = NewPos.X;
  D.Y = NewPos.Y;
  D.Z = 0.0;
  R = rotator(D);
  R.Yaw += RandRange(-spread,spread);
  V = vector(R);
  rv = V * VSize(D);
  rv.Z = NewPos.Z;
  
  return rv;
}

function bool isHarryNear()
{
    local float Size;
    Size = VSize(PlayerHarry.Location - Location);
    PlayerHarry.ClientMessage("Distance" @ string(Size));
    if (VSize(PlayerHarry.Location - Location) < SightRadius)
    {
        Log("is close");
        lastHarryPos = PlayerHarry.Location;
        return True;
    }
    Log("not close");
    return False;
}

state stateError
{
    begin:
        EnterErrorMode();
        Goto 'loop';
    
    loop:
        PlayerHarry.ClientMessage(string(self) @ " : " @ DebugErrMessage);
        sleep (15.0);
        goto 'loop';
}

defaultproperties
{
     maxTravelDistance=2000
     travelFromHome=150
}
