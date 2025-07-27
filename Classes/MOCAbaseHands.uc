//================================================================================
// MOCAbaseHands.
//================================================================================

class MOCAbaseHands extends HWeapon;

function actor TraceForInteracts (vector TraceEnd, vector TraceStart, optional vector Extent) //Courtesy of Omega because ue1 didn't like my solution
{
	local actor aHitActor;
	local vector HitLoc;
	local vector HitNorm;
	local harry PlayerHarry;
    local MOCAInteractProp MocaProp;

	PlayerHarry = Harry(Level.PlayerHarryActor);


    //SpawnSprite(TraceStart);
    //SpawnSprite(TraceEnd);

    //TraceActors(class<actor> BaseClass, out actor Actor, out vector HitLoc, out vector HitNorm, vector End, optional vector Start, optional vector Extent);
	foreach TraceActors(Class'Actor', aHitActor, HitLoc, HitNorm, TraceEnd, TraceStart, Extent)
	{
        if(aHitActor.IsA('MOCAharry'))
        {
            continue;
        }

        // Omega: Check the level if it was hit first, and if so exit
        if(aHitActor == Level)
        {
            break;
        }

        // Omega: Then we check if the hit actor was set to block players or not, and if not continue
        if(!aHitActor.bBlockPlayers)
        {
            Continue;
        }
        /* 
        if(!aHitActor.bCollideActors)
        {
            Continue;
        }*/

        break;
    }

    Log(aHitActor);

    if (aHitActor != None && ( aHitActor.IsA('MOCAInteractProp')))
    {
        MocaProp = MOCAInteractProp(aHitActor);
        if (!MocaProp.doOnceFulfilled){
            Log("Successfully hit interactable!");
            MOCAInteractProp(aHitActor).LineTraceHit();
            PlayerHarry.GotoState('stateInteract');   
        }
        else {
            Log("Already been activated");
        }
    }
    /*else if (aHitActor != None && ( aHitActor.IsA('MOCAInteractTrigger')) )
    {
        Log("Successfully hit interactable!");
        MOCAInteractTrigger(aHitActor).LineTraceHit();
        PlayerHarry.GotoState('stateInteract');
    }*/
}

function SpawnSprite(Vector Location)
{
    // Spawn a sprite at the given location
    local Actor NewSprite;
    NewSprite = Spawn(class'DebugSprite', , , Location);
}

defaultproperties
{
    Mesh=SkeletalMesh'MocaModelPak.MOCAHarry'
}