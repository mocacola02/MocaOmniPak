//================================================================================
// MOCAInteractProp.
//================================================================================

class MOCAInteractProp extends HProp;

var() bool bDoOnce;
var bool bDoOnceFulfilled;
var() bool bActAsTrigger;
var() bool bDestroyOnTrigger;
var() float CooldownLength;
var bool bCoolingDown;
var float TimeLeft;

function bool CheckCooldown();

function LineTraceHit() {
    Log("Hit! bDoOnceFulfilled = " $bDoOnceFulfilled);
    if (bDoOnce && !bDoOnceFulfilled) {
        bDoOnceFulfilled = True;
        Log("Attempting to trigger (bDoOnce)");
        TriggerEvent( Event, Self, None );
    }
    else if (bDoOnce && bDoOnceFulfilled)
    {
        Log("already done");
    }
    else
    {
        Log("Attempting to trigger");
        TriggerEvent( Event, Self, None );
    }
}

/* 
Trigger an event, courtesy of Omega
*/
function TriggerEvent( Name EventName, Actor Other, Pawn EventInstigator )
{
    Log("Trigger started for event:" $ EventName);
    local Actor A;
    if (bActAsTrigger && !IsInState('cooldown'))
    {
        if ( (EventName == '') || (EventName == 'None') ){
            Log("no event");
            return;
        } 

        ForEach AllActors( class 'Actor', A, EventName ) {
            Log("starting event");
            A.Trigger(Other, EventInstigator);
            bCoolingDown = True;
            if (bDestroyOnTrigger) {
                Log('Destroying Trigger');
                Destroy();
            }
            else {
                Log('Initiate cooldown');
                Gotostate('cooldown');
            }
        }
            
    }
}

auto state idle
{
    begin:
        Log('DONE cooldown');
} 

state cooldown
{
    function bool CheckCooldown()
    {
        if (TimeLeft > 0)
        {
            return false;
        }
        else
        {
            return true;
        }
    }

    begin:
        TimeLeft = CooldownLength;
    loop:
        if (CheckCooldown())
        {
            Gotostate('idle');
        }
        else {
            TimeLeft = TimeLeft - 1;
        }
        sleep(1.0);
        Goto('loop');
}

defaultproperties {
    bDoOnce=True
    bCollideWorld=false
    CooldownLength=3
    bActAsTrigger=True
    bDoOnce=True
    bDestroyOnTrigger=True
    bCoolingDown=False
}