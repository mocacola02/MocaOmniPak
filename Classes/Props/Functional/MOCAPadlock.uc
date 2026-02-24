//================================================================================
// MOCAPadlock.
//================================================================================
class MOCAPadlock extends MOCAPawn;

var() bool bFastOpen;				// Moca: Play faster unlock animation? Def: False
var() Sound UnlockSFX;				// Moca: Sound to play on unlock. Def: Sound'MocaSoundPak.padlock_multi'
var() class<ParticleFX> DespawnFX;	// Moca: Despawn particle class to spawn when padlock despawns. Def: class'HPParticle.Aloh_hit'

auto state stateIdle
{
	function ProcessSpell()
	{
		// If hit by spell, unlock
		GotoState('stateUnlock');
	}
}

state stateUnlock
{
	begin:
		// Play unlock sound
		PlaySound(UnlockSFX);
		// Spawn despawn FX
		Spawn(DespawnFX,,,Location,,True);
		
		// If fast open, play faster anim
		if ( bFastOpen )
		{
			PlayAnim('open2');
		}
		// Otherwise play default anim
		else
		{
			PlayAnim('Open');
		}

		// Finish anim
		FinishAnim();
		// Emit event
		TriggerEvent(Event,Self,Self);
		// Destroy self
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