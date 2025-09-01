//================================================================================
// BundimunSpray.
//================================================================================

class BundimunSpray extends HiddenHPawn;

var bool bTouch;
var float fLifetime;
var float DamageToDeal;
var Vector CurrentDir;

function PostBeginPlay()
{
	local vector EmitLocation;

	SetTimer(fLifetime,False);

	EmitLocation = Location;
	EmitLocation.Z -= 16;
	Spawn(Class'MocaOmniPak.BundimunMist',self,,EmitLocation,,true);
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
		Other.TakeDamage(DamageToDeal,None,vect(0.00,0.00,0.00),vect(0.00,0.00,0.00),'None');
		PlaySound(Sound'spell_hit',SLOT_Interact,1.0,False,2000.0,1.0);
		bTouch = False;
	}
}

function Bump (Actor Other)
{
	Touch(Other);
}

defaultproperties
{
    bTouch=True

    fLifetime=3.00

    DrawType=DT_None

    CollisionRadius=10.00

    CollisionHeight=22.00

    bCollideActors=True

    bCollideWorld=True

}