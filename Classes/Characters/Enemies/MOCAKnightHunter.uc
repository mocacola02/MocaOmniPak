//================================================================================
// MOCAKnightHunter.
//================================================================================
class MOCAKnightHunter extends MOCAHunter;

defaultproperties
{
    AwakenAnim=StepDown
    CaughtAnim=StandCaught
    CaughtSound=MultiSound'MocaOmniResources.Creatures.armor_clink_multi'
    CaughtTransAnim=StandIdle2Caught
    CollisionHeight=58
    DrawScale=1.2
    eVulnerableToSpell=SPELL_None
    IdleAnim=StandIdle
    Mesh=SkeletalMesh'MocaOmniResources.skKnight'
    SleepAnim=Idle
    WalkAnim=StandWalk
}
