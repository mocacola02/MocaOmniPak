class MOCAFilch extends MOCAChar;

var() int suspicionThreshold; //Moca: How high can his suspicion level get before he becomes more paranoid (def: 16)
var int suspicion;

auto state stateIdle
{
    function BeginState()
    {
        Log("starting idle");
        if (!ActorExistenceCheck(class'PatrolPoint'))
        {
            GotoState('stateError');
        }
    }
}

state patrol
{
    event BeginState()
    {
        Super.BeginState();
    }
}



defaultproperties
{
    Mesh=SkeletalMesh'MocaModelPak.skfilchlanternMesh'
    DebugErrMessage="WARNING: Filch requires PatrolPoints to be placed and configured in the level. Check stock HP2 maps for PatrolPoint examples.";
    IdleAnimName=Breathe
    WalkAnimName=Walk
    RunAnimName=run
    TalkAnimName=Talk



    suspicionThreshold=16
}