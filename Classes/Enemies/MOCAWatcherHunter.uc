//================================================================================
// MOCAWatcherHunter.
//================================================================================
class MOCAWatcherHunter extends MOCAHunter;

defaultproperties
{
    AwakenAnim=StepDown
    CaughtAnim=StandCaught
    CaughtSound=MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks'
    CaughtTransAnim=StandIdle2Caught
    CollisionHeight=58
    DrawScale=1.2
    eVulnerableToSpell=SPELL_None
    IdleAnim=StandIdle
    Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
    Skins(1)=Texture'MocaTexturePak.Misc.transparent'
    SleepAnim=Idle
    WalkAnim=StandWalk
}
