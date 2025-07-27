//================================================================================
// MOCAsnail.
//================================================================================

class MOCAsnail extends orangesnail;

function DoTrailUpdates (float fDeltaTime)
{
  local int nTrailRadius;
  local int nTrailHeight;
  local Rotator rTrailRotation;
  local Vector vTrailLocation;

  nTrailRadius = class'MOCASnailTrail'.Default.CollisionRadius;
  // if ( (bLeaveTrail == True) && (bool(Physics) != bool(2)) && (VSize(Location - vLastTrailSpawnLoc) > byte(nTrailRadius) * 0.81) );
  if ( (bLeaveTrail == True && Physics != PHYS_Falling) && (VSize(Location - vLastTrailSpawnLoc) > (nTrailRadius * 0.8)) )
  {
    rTrailRotation = class'MOCASnailTrail'.Default.Rotation;
    vTrailLocation = Location;
    vTrailLocation.Z -= CollisionHeight;
    if ( arrayTrail[nCurrTrailSlot] == None )
    {
      arrayTrail[nCurrTrailSlot] = Spawn(class'MOCASnailTrail',,,vTrailLocation,rTrailRotation);
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