//=============================================================================
// MOCABracken
//=============================================================================

class MOCABracken extends MOCAStalker;

defaultproperties
{
    Mesh=SkeletalMesh'MocaModelPak.skBracken'
    HitsToKill=10
    DrawScale=1.2
    AttackSound=Sound'MocaSoundPak.Creatures.br_Anger'
    KillSound=Sound'MocaSoundPak.Creatures.br_Kill'
    RetreatSound=Sound'MocaSoundPak.Creatures.br_Retreat'
    WaitAnim=Sneak
    SneakAnim=Sneak
    retreatAnim=Backoff
    AttackAnim=AttackWalk
    StareAnim=Idle
    KillAnim=Kill
    DieAnim=Die
}