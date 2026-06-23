//================================================================================
// MOCAPortcullis.
//================================================================================

class MOCAPortcullis extends MOCAHP3Movers;

defaultproperties
{
     Mesh=SkeletalMesh'MocaOmniResources.skPortcullis'
     DrawScale=2.2
     CollisionRadius=70
     CollisionWidth=4
     CollisionHeight=100
     CollideType=CT_Box
     bAlignBottomAlways=True
}
