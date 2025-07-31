//=============================================================================
// MOCAStalkerNode.
//=============================================================================
class MOCAStalkerNode extends PathNode;

var() float dotMin;
var() float requiredDistance;
var harry PlayerHarry;

event PostBeginPlay()
{
    PlayerHarry = harry(Level.PlayerHarryActor);
    local float timerRate;
    timerRate = RandRange(0.1, 0.3);
    SetTimer(timerRate, true);
}

function setViewDistance(float newDistance)
{
    if (newDistance == 0)
    {
        newDistance = Default.requiredDistance;
    }
    requiredDistance = newDistance;
}

function Timer()
{
    local float distToPlayer;
    distToPlayer = Abs(VSize(Location - PlayerHarry.Location));

    if (distToPlayer < requiredDistance)
    {
        if (IsOtherLookingAt(PlayerHarry, dotMin))
        {
            if (!bBlocked)
            {
                bBlocked = true;
                Texture = Texture'MocaTexturePak.ICO_BrackenPath';
            }
        }
        else 
        {
            if (bBlocked)
            {
                bBlocked = false;
                Texture = Texture'MocaTexturePak.ICO_BrackenPathGreen';
            }
        }
    }
    else if (bBlocked)
    {
        bBlocked = false;
        Texture = Texture'MocaTexturePak.ICO_BrackenPathGreen';
    }
}

function bool IsOtherFacing(Actor Other, float MinDot)
{
    local float Dot;
    Dot = Vector(Other.Rotation) Dot Normal(Location - Other.Location);

    if (Dot > MinDot)
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

defaultproperties
{
    bSpecialCost=true
    Texture=Texture'MocaTexturePak.ICO_BrackenPathGreen'
    bStatic=False
    dotMin=0.25
    requiredDistance=2000
}
