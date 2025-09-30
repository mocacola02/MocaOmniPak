//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends MOCATrigger;

var bool bDoOnce;
var bool bAttachedToKnight;

function Activate ( actor Other, pawn Instigator ) {
    if (bDoOnce && !PlayerHarry.IsInState('caught')) {
        GotoState('ProcessTrigger');
    }
}

state ProcessTrigger
{
    begin:
        bDoOnce = False;
        if (bAttachedToKnight)
        {
            Owner.GotoState('catch');
        }
        PlayerHarry.GotoState('caught');
        sleep(4.0);
        bDoOnce = True;
}

defaultproperties
{
    bDoOnce=True
    CollisionHeight=35
    CollisionRadius=42
    CollisionWidth=0
    CollideType=CT_Box
    bAttachedToKnight=False
    LightBrightness=128
    LightHue=128
    LightSaturation=128
    bDynamicLight=true
    LightRadius=8
    LightType=LT_Steady
}    