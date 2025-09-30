class MOCAPatrolPoint extends PatrolPoint;

// Tbh I forget what all this does and i'm too lazy to read it rn. i think it just adds extra anim options or something

var() Array<name> PatrolAnimList; 	// Moca: List of patrol anims
var() Array<name> PauseAnimList; 	// Moca: List of pause anims
var() bool bLogEachChange; 			// Moca: Whether or not to log each animation change. Only needed for debugging.

var int patrolAnimCount;
var int pauseAnimCount;
var int currPatrol;
var int currPause;

var bool bTouchCooldown;

event PostBeginPlay()
{
    patrolAnimCount = PatrolAnimList.Length;
    pauseAnimCount = PauseAnimList.Length;
    Log("PatrolCount: " @ string(patrolAnimCount));
    Log("PauseCount: " @ string(pauseAnimCount));

    if (patrolAnimCount > 0)
    {
        PatrolAnim = PatrolAnimList[0];
        currPatrol = 0;
        Log("first patrol anim set");
    }
    if (pauseAnimCount > 0)
    {
        PauseAnim = PauseAnimList[0];
        currPause = 0;
        Log("first pause anim set");
    }
}

event Touch (Actor Other)
{
    if (bTouchCooldown)
    {
        return;
    }

    if (Other.IsA('harry'))
    {
        return;
    }

    bTouchCooldown = true;

    SetTimer(1.0,false);

    if (patrolAnimCount > 1)
    {
        currPatrol++;
        if (currPatrol >= patrolAnimCount)
        {
            Log('resetting patrol count');
            currPatrol = 0;
        }
        PatrolAnim = PatrolAnimList[currPatrol];
    }

    if (pauseAnimCount > 1)
    {
        currPause++;
        if (currPause >= pauseAnimCount)
        {
            Log('resetting pause count');
            currPause = 0;
        }
        PauseAnim = PauseAnimList[currPause];
    }
    if (bLogEachChange)
    {
        Log("PatrolAnim: " @ string(PatrolAnim));
        Log("PauseAnim: " @ string(PauseAnim));
        Log("currPatrol: " @ string(currPatrol));
        Log("currPause: " @ string(currPause));
    }
}

event Timer()
{
    bTouchCooldown = false;
}

defaultproperties
{
     upstreamPaths(0)=-1
     upstreamPaths(1)=-1
     upstreamPaths(2)=-1
     upstreamPaths(3)=-1
     upstreamPaths(4)=-1
     upstreamPaths(5)=-1
     upstreamPaths(6)=-1
     upstreamPaths(7)=-1
     upstreamPaths(8)=-1
     upstreamPaths(9)=-1
     upstreamPaths(10)=-1
     upstreamPaths(11)=-1
     upstreamPaths(12)=-1
     upstreamPaths(13)=-1
     upstreamPaths(14)=-1
     upstreamPaths(15)=-1
     Paths(0)=-1
     Paths(1)=-1
     Paths(2)=-1
     Paths(3)=-1
     Paths(4)=-1
     Paths(5)=-1
     Paths(6)=-1
     Paths(7)=-1
     Paths(8)=-1
     Paths(9)=-1
     Paths(10)=-1
     Paths(11)=-1
     Paths(12)=-1
     Paths(13)=-1
     Paths(14)=-1
     Paths(15)=-1
     PrunedPaths(0)=-1
     PrunedPaths(1)=-1
     PrunedPaths(2)=-1
     PrunedPaths(3)=-1
     PrunedPaths(4)=-1
     PrunedPaths(5)=-1
     PrunedPaths(6)=-1
     PrunedPaths(7)=-1
     PrunedPaths(8)=-1
     PrunedPaths(9)=-1
     PrunedPaths(10)=-1
     PrunedPaths(11)=-1
     PrunedPaths(12)=-1
     PrunedPaths(13)=-1
     PrunedPaths(14)=-1
     PrunedPaths(15)=-1
     bCollideActors=True
}
