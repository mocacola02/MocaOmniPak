//================================================================================
// MOCAsnail.
//================================================================================

class MOCAsnail extends orangesnail;

var() class<SnailTrail> TrailToSpawn; // Moca: What SnailTrail class to spawn


// Ripped from KW, not messing with this further
function DoTrailUpdates (float DeltaTime)
{
	local int nTrailRadius;
	local Rotator rTrailRotation;
	local Vector vTrailLocation;

	nTrailRadius = trailToSpawn.Default.CollisionRadius;

	if ( (bLeaveTrail == True && Physics != PHYS_Falling) && (VSize(Location - vLastTrailSpawnLoc) > (nTrailRadius * 0.8)) )
	{
		rTrailRotation = trailToSpawn.Default.Rotation;
		vTrailLocation = Location;
		vTrailLocation.Z -= CollisionHeight;

		if ( arrayTrail[nCurrTrailSlot] == None )
		{
			arrayTrail[nCurrTrailSlot] = Spawn(trailToSpawn,,,vTrailLocation,rTrailRotation);
			arrayTrail[nCurrTrailSlot].SetSpawnProps(Self,fTrailDuration,fTrailShrinkAfter);
		}

		arrayTrail[nCurrTrailSlot].StartUsing(vTrailLocation);
		vLastTrailSpawnLoc = Location;
		nCurrTrailSlot++;

		if ( nCurrTrailSlot >= nMaxTrailSegments )
		{
			nCurrTrailSlot = 0;
		}
	}
	if ( bAllowSnailDamage == False )
	{
		fTimeSinceSnailDamage += DeltaTime;

		if ( fTimeSinceSnailDamage >= fTrailDamageWait )
		{
			bAllowSnailDamage = True;
			fTimeSinceSnailDamage = 0.0;
		}
	}
}

defaultproperties
{
	TrailToSpawn=class'MOCASnailTrail'
}