//================================================================================
// MOCAPadlock.
//================================================================================
class MOCAPadlock extends MOCAPawn;

var() bool bFastOpen;
var() Sound UnlockSFX;
var() class<ParticleFX> DespawnFX;


event Destroyed()
{
	if ( DespawnFX != None )
	{
		DespawnFX.Shutdown();
	}

	Super.Destroyed();
}

auto state stateIdle
{
	function ProcessSpell()
	{
		GotoState('stateUnlock');
	}
}

state stateUnlock
{
	begin:
		PlaySound(UnlockSFX);
		
		if ( bFastOpen )
		{
			PlayAnim('open2');
		}
		else
		{
			PlayAnim('Open');
		}

		FinishAnim();
		TriggerEvent(Event,Self,Self);
		Destroy();
}

defaultproperties
{
	UnlockSFX=Sound'MocaSoundPak.padlock_multi'
	DespawnFX=class'HPParticle.Aloh_hit'

	DrawScale=2.5
	CollisionRadius=8.0
	CollisionHeight=8.0
	CollisionWidth=16.0
	CollideType=CT_OrientedCylinder
	bBlockActors=True
	bBlockPlayers=True

	Mesh=SkeletalMesh'MocaModelPak.skPadlock'
	eVulnerableToSpell=SPELL_Alohomora
}