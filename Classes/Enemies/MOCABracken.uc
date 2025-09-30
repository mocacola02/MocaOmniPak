//=============================================================================
// MOCABracken
//=============================================================================

class MOCABracken extends MOCAStalker;

defaultproperties
{
    Mesh=SkeletalMesh'MocaModelPak.skBracken'
    hitsToKill=10
    DrawScale=1.2
    DebugErrMessage="Brackens require BrackenPathNodes to be placed in the level. While PathNodes will work, they do not have all the proper features for the Bracken. Please add BrackenPathNodes and rebuild your level, or if you require non-Bracken path nodes for it for whatever reason then set bBypassErrorMode = True";
    attackSound=Sound'MocaSoundPak.Creatures.br_Anger'
    killSound=Sound'MocaSoundPak.Creatures.br_Kill'
    retreatSound=Sound'MocaSoundPak.Creatures.br_Retreat'
    waitAnim=Sneak
    sneakAnim=Sneak
    retreatAnim=Backoff
    attackAnim=AttackWalk
    stareAnim=Idle
    killAnim=Kill
    dieAnim=Die
}