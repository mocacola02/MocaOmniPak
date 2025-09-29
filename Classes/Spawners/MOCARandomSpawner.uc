//================================================================================
// MOCARandomSpawner.
//================================================================================

class MOCARandomSpawner extends Triggers;

var() array<Class<Actor>> CustomSpawnClasses; // Moca: Configurable array in the editor
var() float fVelocityModifier;
var() name SpawnTag;
var() bool bThrowItem;
var() bool bKeepingTryingSpawnZOnly;
var() float fAdditionalZVelocity;
var(SpawnThingyPatrol) name nameFirstPatrolPoint;
var(SpawnThingyPatrol) bool bLoopPatrolPath;
//var() bool preventRepeatedSpawns;
var() bool bUseCustomSpawnClasses; // Moca: Boolean to use custom array defined in-editor

// Preset array of actors defined in the code
var Class<Actor> PresetSpawnClasses[118]; 

event Trigger (Actor Other, Pawn Instigator)
{
    local Actor SpawnedObject;
    local Vector Vel;
    local Rotator SpawnDirection;
    local int RandomIndex;
    local Class<Actor> SelectedClass;
    local array<Class<Actor>> SpawnArray; // Dynamic array to hold the active set of classes
    local int i;

    // Determine which array to use: custom or preset
    if (bUseCustomSpawnClasses && CustomSpawnClasses.Length > 0)
    {
        SpawnArray = CustomSpawnClasses; // Use the array set in the editor
    }
    else
    {
        // Use preset array by manually copying elements
        SpawnArray.Length = 0; // Clear the dynamic array first
        for (i = 0; i < ArrayCount(PresetSpawnClasses); i++)
        {
            if (PresetSpawnClasses[i] != None) // Ensure valid elements
            {
                SpawnArray.AddItem(PresetSpawnClasses[i]);
            }
        }
    }

    // Ensure there's something to spawn
    if (SpawnArray.Length > 0)
    {
        // Randomly pick a class from the array
        RandomIndex = Rand(SpawnArray.Length);
        SelectedClass = SpawnArray[RandomIndex];

        // Spawn the selected actor
        if (SpawnTag != 'None')
        {
            SpawnedObject = FancySpawn(SelectedClass,,SpawnTag,Location,,bKeepingTryingSpawnZOnly);
        } 
        else 
        {
            SpawnedObject = FancySpawn(SelectedClass,,,Location,,bKeepingTryingSpawnZOnly);
        }

        // Apply patrol behavior if it's a pawn
        if ((nameFirstPatrolPoint != 'None') && SpawnedObject.IsA('HPawn'))
        {
            HPawn(SpawnedObject).firstPatrolPointObjectName = nameFirstPatrolPoint;
            HPawn(SpawnedObject).bLoopPath = bLoopPatrolPath;
        }

        // Apply velocity if needed
        if (bThrowItem || (SpawnedObject.IsA('Jellybean') && bDirectional))
        {
            Vel.X = 96.0 - 32 + Rand(64);
            Vel.Y = 0.0;
            Vel.Z = 40.0 + fAdditionalZVelocity;
            Vel = Vel >> Rotation;
            SpawnedObject.Velocity = Vel * fVelocityModifier;
            SpawnedObject.SetPhysics(PHYS_Falling);
        }
    }
}

defaultproperties
{
     fVelocityModifier=1
     PresetSpawnClasses(0)=Class'HGame.Bowtruckle'
     PresetSpawnClasses(1)=Class'HGame.CornishPixie'
     PresetSpawnClasses(2)=Class'HGame.firecrab'
     PresetSpawnClasses(3)=Class'HGame.firecrabLarge'
     PresetSpawnClasses(4)=Class'HGame.gargoyle'
     PresetSpawnClasses(5)=Class'HGame.GNOME'
     PresetSpawnClasses(6)=Class'HGame.Horklumps'
     PresetSpawnClasses(7)=Class'HGame.Imp'
     PresetSpawnClasses(8)=Class'HGame.Pig'
     PresetSpawnClasses(9)=Class'HGame.Spider'
     PresetSpawnClasses(10)=Class'HGame.SpiderLarge'
     PresetSpawnClasses(11)=Class'HGame.SpiderSmall'
     PresetSpawnClasses(12)=Class'HGame.SpikyPlant'
     PresetSpawnClasses(13)=Class'HGame.Tentacula'
     PresetSpawnClasses(14)=Class'HGame.WillowRoot'
     PresetSpawnClasses(15)=Class'HGame.Boeing747'
     PresetSpawnClasses(16)=Class'HGame.Peeves'
     PresetSpawnClasses(17)=Class'HGame.Aragog'
     PresetSpawnClasses(18)=Class'HGame.Basilisk'
     PresetSpawnClasses(19)=Class'HGame.BloodyBaron'
     PresetSpawnClasses(20)=Class'HGame.Crabbe'
     PresetSpawnClasses(21)=Class'HGame.Dobby'
     PresetSpawnClasses(22)=Class'HGame.Draco'
     PresetSpawnClasses(23)=Class'HGame.DuelVendor'
     PresetSpawnClasses(24)=Class'HGame.Ectoplasma'
     PresetSpawnClasses(25)=Class'HGame.fatfriar'
     PresetSpawnClasses(26)=Class'HGame.Fawkes'
     PresetSpawnClasses(27)=Class'HGame.Filch'
     PresetSpawnClasses(28)=Class'HGame.FordFlying'
     PresetSpawnClasses(29)=Class'HGame.FredWeasley'
     PresetSpawnClasses(30)=Class'HGame.GeorgeWeasley'
     PresetSpawnClasses(31)=Class'HGame.Ginny'
     PresetSpawnClasses(32)=Class'HGame.GFemGry1'
     PresetSpawnClasses(33)=Class'HGame.GOldMaleGry1'
     PresetSpawnClasses(34)=Class'HGame.Goyle'
     PresetSpawnClasses(35)=Class'HGame.Hagrid'
     PresetSpawnClasses(36)=Class'HGame.HagridYoung'
     PresetSpawnClasses(37)=Class'HGame.Hermione'
     PresetSpawnClasses(38)=Class'HGame.Hedwig'
     PresetSpawnClasses(39)=Class'HGame.MoaningMyrtle'
     PresetSpawnClasses(40)=Class'HGame.LuciousMalfoy'
     PresetSpawnClasses(41)=Class'HGame.MrsNorris'
     PresetSpawnClasses(42)=Class'HGame.NHNick'
     PresetSpawnClasses(43)=Class'HGame.NHNickPetrified'
     PresetSpawnClasses(44)=Class'HGame.OliverWood'
     PresetSpawnClasses(45)=Class'HGame.orangesnail'
     PresetSpawnClasses(46)=Class'HGame.Percy'
     PresetSpawnClasses(47)=Class'HGame.PinkLady'
     PresetSpawnClasses(48)=Class'HGame.ProfDumbleDore'
     PresetSpawnClasses(49)=Class'HGame.ProfFlitwick'
     PresetSpawnClasses(50)=Class'HGame.ProfLockhart'
     PresetSpawnClasses(51)=Class'HGame.ProfMcGonagall'
     PresetSpawnClasses(52)=Class'HGame.ProfSnape'
     PresetSpawnClasses(53)=Class'HGame.ProfSprout'
     PresetSpawnClasses(54)=Class'HGame.Ron'
     PresetSpawnClasses(55)=Class'HGame.Snape'
     PresetSpawnClasses(56)=Class'HGame.TomRiddle'
     PresetSpawnClasses(57)=Class'HGame.BEATER'
     PresetSpawnClasses(58)=Class'HGame.Chaser'
     PresetSpawnClasses(59)=Class'HGame.Seeker'
     PresetSpawnClasses(60)=Class'HGame.Boulder'
     PresetSpawnClasses(61)=Class'HGame.ChallengeStar'
     PresetSpawnClasses(62)=Class'HGame.chestbronze'
     PresetSpawnClasses(63)=Class'HGame.ChestGold'
     PresetSpawnClasses(64)=Class'HGame.ChestIron'
     PresetSpawnClasses(65)=Class'HGame.ChestWood'
     PresetSpawnClasses(66)=Class'HGame.ChickenLeg'
     PresetSpawnClasses(67)=Class'HGame.ChocolateFrog'
     PresetSpawnClasses(68)=Class'HGame.FordAnglia'
     PresetSpawnClasses(69)=Class'HGame.GnomeHome'
     PresetSpawnClasses(70)=Class'HGame.Padlock'
     PresetSpawnClasses(71)=Class'HGame.CauldronMixing'
     PresetSpawnClasses(72)=Class'HGame.Salazar'
     PresetSpawnClasses(73)=Class'HGame.DiffindoRoots'
     PresetSpawnClasses(74)=Class'HGame.DiffindoRope'
     PresetSpawnClasses(75)=Class'HGame.DiffindoVines'
     PresetSpawnClasses(76)=Class'HGame.DiffindoWeb1'
     PresetSpawnClasses(77)=Class'HGame.FlipendoVaseBronze'
     PresetSpawnClasses(78)=Class'HGame.FlipendoVaseGreen'
     PresetSpawnClasses(79)=Class'HGame.FlipendoVaseMing'
     PresetSpawnClasses(80)=Class'HGame.Jellybean'
     PresetSpawnClasses(81)=Class'HPParticle.Bicorn'
     PresetSpawnClasses(82)=Class'HGame.boomslang'
     PresetSpawnClasses(83)=Class'HGame.FlobberwormMucus'
     PresetSpawnClasses(84)=Class'HGame.JarFlobberwormMucus'
     PresetSpawnClasses(85)=Class'HGame.JarWiggentreeBark'
     PresetSpawnClasses(86)=Class'HGame.WiggentreeBark'
     PresetSpawnClasses(87)=Class'HGame.WWellBlueBottle'
     PresetSpawnClasses(88)=Class'HGame.WWellCauldronBottle'
     PresetSpawnClasses(89)=Class'HGame.WWellGreenBottle'
     PresetSpawnClasses(90)=Class'HGame.WWellOrangeBottle'
     PresetSpawnClasses(91)=Class'MocaOmniPak.MOCASavePoint'
     PresetSpawnClasses(92)=Class'HGame.AragogSpellAttack'
     PresetSpawnClasses(93)=Class'HGame.AragogSpellWeb'
     PresetSpawnClasses(94)=Class'HGame.spellAcidSpit'
     PresetSpawnClasses(95)=Class'HGame.spellAlohomora'
     PresetSpawnClasses(96)=Class'HGame.spellDiffindo'
     PresetSpawnClasses(97)=Class'HGame.spellDuelExpelliarmus'
     PresetSpawnClasses(98)=Class'HGame.spellDuelMimblewimble'
     PresetSpawnClasses(99)=Class'HGame.spellEcto'
     PresetSpawnClasses(100)=Class'HGame.spellFire'
     PresetSpawnClasses(101)=Class'HGame.spellFireLarge'
     PresetSpawnClasses(102)=Class'HGame.spellFireSmall'
     PresetSpawnClasses(103)=Class'HGame.spellFlipendo'
     PresetSpawnClasses(104)=Class'HGame.spellLumos'
     PresetSpawnClasses(105)=Class'HGame.spellRictusempra'
     PresetSpawnClasses(106)=Class'HGame.spellSkurge'
     PresetSpawnClasses(107)=Class'HGame.spellSnakeHeadFire'
     PresetSpawnClasses(108)=Class'HGame.spellSpongify'
     PresetSpawnClasses(109)=Class'HGame.spellSwordFire'
     PresetSpawnClasses(110)=Class'HGame.spellWeb'
     PresetSpawnClasses(111)=Class'HGame.ChristmasTree'
     PresetSpawnClasses(112)=Class'HGame.Sundial'
     PresetSpawnClasses(113)=Class'HGame.FinalStar'
     PresetSpawnClasses(114)=Class'HGame.Fireball'
     PresetSpawnClasses(115)=Class'HGame.FireballLarge'
     PresetSpawnClasses(116)=Class'HGame.PoisonCloud'
     PresetSpawnClasses(117)=Class'HGame.WhompingWillow'
     Style=STY_Masked
     Texture=Texture'MocaTexturePak.EditorIco.ICO_RandomSpawner'
}
