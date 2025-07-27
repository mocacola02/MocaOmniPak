//================================================================================
// MOCAInteractProp.
//================================================================================

class MOCAInteractProp extends HProp;

var() bool doOnce;
var bool doOnceFulfilled;
var() bool actAsTrigger;
var() bool destroyOnTrigger;
var() float CooldownLength;
var bool CoolingDown;
var float TimeLeft;

function LineTraceHit() {
    Log("Hit! doOnceFulfilled = " $doOnceFulfilled);
    if (doOnce && !doOnceFulfilled) {
        doOnceFulfilled = True;
        Log("Attempting to trigger (doonce)");
        TriggerEvent( Event, Self, None );
    }
    else if (doOnce && doOnceFulfilled)
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
    if (actAsTrigger && !IsInState('cooldown'))
    {
        if ( (EventName == '') || (EventName == 'None') ){
            Log("no event");
            return;
        } 

        ForEach AllActors( class 'Actor', A, EventName ) {
            Log("starting event");
            A.Trigger(Other, EventInstigator);
            CoolingDown = True;
            if (destroyOnTrigger) {
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
    doOnce=True
    bCollideWorld=false
    CooldownLength=3
    actAsTrigger=True
    doOnce=True
    destroyOnTrigger=True
    CoolingDown=False
}