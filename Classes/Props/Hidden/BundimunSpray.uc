//================================================================================
// BundimunSpray.
//================================================================================

class BundimunSpray extends HiddenHPawn;

var bool bTouch;
var float fLifetime;
var Vector CurrentDir;

function PostBeginPlay()
{
	SetTimer(fLifetime,False);
}

function Timer()
{
	Destroy();
}

function Touch (Actor Other)
{
	if ( Pawn(Other) == Instigator )
	{
		return;
	}
	if ( (Other == PlayerHarry) && (bTouch) )
	{
		Other.TakeDamage(5,None,vect(0.00,0.00,0.00),vect(0.00,0.00,0.00),'None');
		bTouch = False;
	}
	PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
}

function Bump (Actor Other)
{
	Touch(Other);
}

defaultproperties
{
    bTouch=True

    fLifetime=3.00

    attachedParticleClass(0)=Class'MocaOmniPak.BundimunMist'

    attachedParticleOffset(0)=(X=0.00,Y=0.00,Z=-16.00)

    DrawType=DT_None

    CollisionRadius=10.00

    CollisionHeight=22.00

    bCollideActors=True

    bCollideWorld=True

}