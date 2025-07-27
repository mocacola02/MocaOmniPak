//================================================================================
// Portcullis.
//================================================================================

class Portcullis extends HP3Movers;

defaultproperties
{
     Mesh=SkeletalMesh'MocaModelPak.skPortcullis'
     DrawScale=2.2
     CollisionRadius=70
     CollisionWidth=4
     CollisionHeight=100
     CollideType=CT_Box
     bAlignBottomAlways=True
}
