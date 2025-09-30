//================================================================================
// MOCAsnail.
//================================================================================

class MOCAsnail extends orangesnail;

var() class<SnailTrail> trailToSpawn; // Moca: What SnailTrail class to spawn

function DoTrailUpdates (float fDeltaTime)
{
	local int nTrailRadius;
	local int nTrailHeight;
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
		arrayTrail[nCurrTrailSlot].SetSpawnProps(self,fTrailDuration,fTrailShrinkAfter);
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
		fTimeSinceSnailDamage += fDeltaTime;
		if ( fTimeSinceSnailDamage >= fTrailDamageWait )
		{
		bAllowSnailDamage = True;
		fTimeSinceSnailDamage = 0.0;
		}
	}
}

defaultproperties
{
  trailToSpawn=class'MOCASnailTrail'
}