//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var bool doOnce;
var bool attachedToKnight;

function Activate ( actor Other, pawn Instigator ) {
    if (doOnce && !PlayerHarry.IsInState('caught')) {
        GotoState('ProcessTrigger');
    }
}

state ProcessTrigger
{
    begin:
        doOnce = False;
        if (attachedToKnight)
        {
            Owner.GotoState('catch');
        }
        PlayerHarry.GotoState('caught');
        sleep(4.0);
        doOnce = True;
}

defaultproperties
{
    doOnce=True
    CollisionHeight=35
    CollisionRadius=42
    CollisionWidth=0
    CollideType=CT_Box
    attachedToKnight=False
    LightBrightness=128
    LightHue=128
    LightSaturation=128
    bDynamicLight=true
    LightRadius=8
    LightType=LT_Steady
}    