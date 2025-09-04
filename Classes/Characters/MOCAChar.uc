class MOCAChar extends HChar;

var() bool affectAmbience;
var() bool bypassErrorMode;
var(MOCACharHealth) int hitsToKill;             //How many hits does it take to die? If 0, cannot die. Def: 0
var(MOCACharMovement) float maxTravelDistance;  //How far can the actor travel from its initial location? Def: 150
var(MOCACharMovement) bool tiltOnMovement;      //Should this actor lean into its movement direction (like Harry)? Def: true

var bool inErrorMode;
var int hitsTaken;
var name PreviousState;
var NavigationPoint prevNavP;
var string DebugErrMessage;

var Vector lastHarryDirection;
var Vector lastHarryPos;
var Vector vHome;
var Vector vNewPos;


event PostBeginPlay()
{
    Super.PostBeginPlay();
    prevNavP = Level.NavigationPointList;
    vHome = Location;
}

event AlterDestination()
{
    Super.AlterDestination();
    //Spawn(Class'DebugSprite');
    if (!tiltOnMovement)
    {
        DesiredRotation.Pitch = 0.0;
    }
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
    Log("actor is not real :(");
    return false;
}

function bool CloseToHome(float distanceAllowance)
{
  if ( VSize(Location - vHome) < distanceAllowance )
  {
    return True;
  }
  return False;
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
    bTurnTo_FollowActor = true;
    TurnTo_TargetActor = TurnTarget;
    MakeTurnToPermanentController();
}

function float GetDistanceFromHarry()
{
    return VSize(Location - PlayerHarry.Location);
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

function vector GetNearbyNavPointInView()
{
    local NavigationPoint Nav;
    local vector DirToNav, Forward;
    local float Distance, DotProduct, ClosestDist;
    local vector BestLocation;

    ClosestDist = 1000.0; // max distance
    BestLocation = Location; // fallback if none found

    Forward = vector(Rotation); // actor's forward direction

    foreach AllActors(class'NavigationPoint', Nav)
    {
        DirToNav = Normal(Nav.Location - Location);
        Distance = VSize(Nav.Location - Location);
        DotProduct = DirToNav Dot Forward;

        // Check distance and that it's in front (~90 degrees FOV)
        if (Distance <= 1000 && DotProduct > 0.0)
        {
            if (Distance < ClosestDist)
            {
                ClosestDist = Distance;
                BestLocation = Nav.Location;
            }
        }
    }

    return BestLocation;
}

function bool isHarryNear(optional float requiredDistance)
{
    local float Size;
    local float distToCheck;
    distToCheck = SightRadius;
    Size = VSize(PlayerHarry.Location - Location);
    PlayerHarry.ClientMessage("Distance" @ string(Size));

    if (requiredDistance != 0)
    {
        distToCheck = requiredDistance;
    }

    if (VSize(PlayerHarry.Location - Location) < distToCheck)
    {
        //Log("is close: " $ string(VSize(PlayerHarry.Location - Location) < distToCheck));
        lastHarryPos = PlayerHarry.Location;
        return True;
    }
    //Log("not close");
    return False;
}

function bool IsFacing(Actor Other, float MinDot)  //Courtesy of Omega
{
    local float DotProduct;
    DotProduct = Vector(Rotation) Dot Normal(Other.Location - Location);

    if (DotProduct > MinDot)
    {
        return true;
    }
    return false;
}

function bool IsOtherFacing(Actor Other, float MinDot)
{
    local float DotProduct;

    // Calculate the direction the 'Other' actor is facing
    DotProduct = Vector(Other.Rotation) Dot Normal(Location - Other.Location);

    // Check if the current actor is within 'Other's view range based on the MinDot threshold
    if (DotProduct > MinDot)
    {
        return true;
    }
    return false;
}

function bool IsOtherLookingAt(Actor Other, float minDot)
{
    if (IsOtherFacing(Other, minDot) && PlayerCanSeeMe())
    {
        return true;
    }
    return false;
}

function bool SeesHarry()
{
    if (PlayerCanSeeMe())
        {
            if (IsFacing(PlayerHarry, 0.25))
            {
                if (Abs(PlayerHarry.Location.Z - Location.Z) <= 50)
                {
                    lastHarryPos = PlayerHarry.Location;
                    return true;
                }
            }
        }
    return false;
}

function screenFade (float fadeOpacity, float fadeOutTime)
{
  local FadeViewController mcCamFade;
  mcCamFade = Spawn(Class'FadeViewController');
  mcCamFade.Init (fadeOpacity, 0, 0, 0, fadeOutTime);
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

function FaceActor(Actor Target)
{
	if (Target == None)
		return;

	local vector Dir;
	Dir = Target.Location - Location;

	local rotator NewRotation;
	NewRotation = Rotator(Dir);

	NewRotation.Pitch = Rotation.Pitch;
	NewRotation.Roll = Rotation.Roll;

	// Apply the new rotation
	SetRotation(NewRotation);
}

function bool HandleSpellAlohomora (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDiffindo (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellEcto (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellFlipendo (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellLumos (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellSkurge (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellSpongify (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDuelRictusempra (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDuelMimblewimble (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpellDuelExpelliarmus (optional baseSpell spell, optional Vector vHitLocation)
{
  return HandleSpell(spell,vHitLocation);
}

function bool HandleSpell (optional baseSpell spell, optional Vector vHitLocation)
{
    if (PlayerHarry.IsA('MOCAharry'))
    {
        if (eVulnerableToSpell == DetermineSpellType(spell.Class))
        {
            Log("Spell hit and match on " $ string(self));
            ProcessSpell();
            return true;
        }
        else
        {
            return False;
        }
    }
    else
    {
        return false;
    }
}

function ProcessSpell()
{
    //Define in child classes.
}

function ESpellType DetermineSpellType (class<baseSpell> TestSpell)
{
    local int i;
    local MOCAharry MocaPlayerHarry;

    MocaPlayerHarry = MOCAharry(PlayerHarry);

    for (i = 0; i < ArrayCount(MocaPlayerHarry.SpellMapping); i++)
    {
        if (MocaPlayerHarry.SpellMapping[i].SpellToAssign == TestSpell)
        {
            Log("Found mapping at index " $ i $ " with slot " $ MocaPlayerHarry.SpellMapping[i].SpellSlot);
            return MocaPlayerHarry.SpellMapping[i].SpellSlot;
        }
    }

    Log("No mapping found for " $ string(TestSpell));
    return SPELL_None;
}

defaultproperties
{
     maxTravelDistance=150
     tiltOnMovement=True
}
