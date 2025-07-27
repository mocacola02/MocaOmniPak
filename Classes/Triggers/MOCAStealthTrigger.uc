//================================================================================
// MOCAStealthTrigger.
//================================================================================

class MOCAStealthTrigger extends Trigger;

var MOCAharry PlayerHarry;
var bool doOnce;
var bool attachedToKnight;


event PreBeginPlay()
{
	Super.PreBeginPlay();
	PlayerHarry = MOCAharry(Level.PlayerHarryActor);
}

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
    CollideType=CT_AlignedCylinder
    attachedToKnight=False
}    