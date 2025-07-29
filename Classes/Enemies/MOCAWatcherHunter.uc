//================================================================================
// MOCAWatcherHunter.
//================================================================================

class MOCAWatcherHunter extends MOCAHunter;

defaultproperties
{
    awakenAnim=StepDown
    caughtAnim=StandCaught
    caughtSound=MultiSound'MocaSoundPak.Creatures.Multi_Armour_Clinks'
    caughtTransAnim=StandIdle2Caught
    CollisionHeight=58
    DrawScale=1.2
    eVulnerableToSpell=SPELL_Flipendo
    idleAnim=StandIdle
    Mesh=SkeletalMesh'MocaModelPak.skKnightWatcher'
    MultiSkins(1)=Texture'MocaTexturePak.Misc.transparent'
    sleepAnim=Idle
    walkAnim=StandWalk
}
