//=============================================================================
// BrackenPathNode.
//=============================================================================
class BrackenPathNode extends PathNode;

var() float dotMin;
var() float requiredDistance;
var harry PlayerHarry;

event PostBeginPlay()
{
    PlayerHarry = harry(Level.PlayerHarryActor);
    SetTimer(1.0, true);  // Set timer to 1 second for performance optimization
}

function Timer()
{
    local float distToPlayer;
    distToPlayer = Abs(VSize(Location - PlayerHarry.Location));

    if (distToPlayer < requiredDistance)
    {
        if (IsOtherLookingAt(PlayerHarry, dotMin))
        {
            if (cost != 999999)  // Reduced from 99999999999 to a more manageable value
            {
                cost = 999999 - (distToPlayer * 5000);  // Adjusted for new cost scale
                Texture = Texture'MocaTexturePak.ICO_BrackenPath';
            }
        }
        else 
        {
            if (cost != -999999)
            {
                cost = -999999;
                Texture = Texture'MocaTexturePak.ICO_BrackenPathGreen';
            }
        }
    }
    else if (cost != -999999)
    {
        cost = -999999;
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
    requiredDistance=1000
}
