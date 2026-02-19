//================================================================================
// MOCABabbler.
//================================================================================

class MOCABabbler extends MOCAChar;

var () float TimeBetweenBabble; 	// Moca: How many seconds in between the connected babble sounds. Def: 0.1
var () float DelayBeforeEnding; 	// Moca: How many seconds to hold on the subtitles after done talking. Def: 2.0
var () float BabbleVoiceVolume; 			// Moca: How loud should the voice be. Def: 1.4
var () float BabbleVoicePitch; 		// Moca: How high or deep should the voice. Def: 128
var () float BabbleVoiceRadius; 			// Moca: How far should the voice reach? Def: 100000.0
var () name BabbleAnim; 			// Moca: What animation to use for babbling. Def: Idle
var () string CustomMessage; 		// Moca: Type a message here to skip setting up a bumpline. Def: empty
var () bool bTurnToHarry; 			// Moca: Should actor turn towards Harry while talking. Def: false

var int CurrentLetter;
var array<Sound> LettersToBabble;


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( BabbleVoicePitch <= 0.0 )
	{
		BabbleVoicePitch = 1.0;
	}
	else if ( BabbleVoicePitch > 2.0 )
	{
		BabbleVoicePitch = 2.0;
	}
}


/////////////
// Bumpline
/////////////

function DoBumpLine (optional string AlternateBumpSet)
{
	local string ActiveBumpSet;
	local string SetID;
	local string SayTextID;
	local string SayText;
 
	local float SoundLen;

	local int NumberOfSpaces;

	if ( CustomMessage != "" )
	{
		SayText = CustomMessage;
	
		BabbleString(SayText);

		NumberOfSpaces = CountSpaces();
		Log("Number of Spaces: "$string(numSpaces));

		SoundLen = (Len(SayText) * TimeBetweenBabble) + (NumberOfSpaces * TimeBetweenBabble) + DelayBeforeEnding;

		SayText = HandleFacialExpression(SayText, SoundLen);
		
		if( !bJustTalk )
		{
			local TimedCue TCue;
			TCue = Spawn(class'TimedCue');
			TCue.CutNotifyActor = Self;
			TCue.SetupTimer(SoundLen + 0.5, "_BumpLineCue");
		}

		PlayerHarry.MyHud.SetSubtitleText(SayText, SoundLen);
		
		if( !bJustTalk )
		{
			Log("Time to babble!");
			GotoState('DoingBumpLine');
		}

		return;
	}

	if ( BumpSetFile == "" && AlternateBumpSet == "" )
	{
		Print("ERROR, I DO NOT HAVE ANY BUMPLINES!!!",true);
	}

	ActiveBumpSet = BumpSetFile;

	if ( AlternateBumpSet != "" )
	{
		ActiveBumpSet = AlternateBumpSet;
	}

	if ( BumpSetPrefix != "" )
	{
		SetID = BumpsetPrefix $ "_" $ ActiveBumpSet;
	}

	Print("LOOKING FOR BUMPSET: " $ string(sSetID));

	LastBumpline = CurrentBumpline;

	if ( bRandomBumpLine )
	{
		local int NumOfBS;
		local int i;

		NumOfBS = int(Localize(SetID, "Count", BumpSetFile));
		i = Rand(NumOfBS);

		if ( i == LastBumpline )
		{
			i = (i + 1) % NumOfBS;
		}

		CurrentBumpline = i;
	}
	else
	{
		CurrentBumpline++;
		
		if ( InStr(SayTextID, "<") > -1 )
		{
			CurrentBumpline = 0;
		}
	}

	SayTextID = Localize(SetID, "line" $ CurrentBumpline, ActiveBumpSet);

	if ( InStr(SayTextID, "<") > -1 )
	{
		Print("ERROR: COULDN'T FIND BUMPSET: " $ ActiveBumpSet);
		return;
	}

	Print("LOOKING FOR BUMPLINE ID: " $ SayTextID);

	SayText = Localize(BumpSetSection, SayTextID, BumpSetLocalizationFile);

	if ( InStr(SayText, "<?") > -1 )
	{
		Print("ERROR: COULDN'T FIND BUMPLINE ID: " $ SayTextID $ " FROM BUMPSET: " $ ActiveBumpSet);
		return;
	}

	PreBumpState = GetStateName();
	PreBumpRot = Rotation;

	if ( bBumpCapturesHarry && PlayerHarry.CutNotifyActor != None )
	{
		PlayerHarry.CutNotifyActor = Self;
		PlayerHarry.CutCommand("capture");
	}
	
	CutNotifyActor = Self;

	BabbleString(SayText);

	NumberOfSpaces = CountSpaces();

	SoundLen = (Len(SayText) * TimeBetweenBabble) + (NumberOfSpaces * TimeBetweenBabble) + DelayBeforeEnding;

	SayText = HandleFacialExpression(SayText, SoundLen);

	local TimedCue TCue;
	TCue = Spawn(class'TimedCue');
	TCue.CutNotifyActor = Self;
	TCue.SetupTimer(SoundLen + 0.5, "_BumpLineCue");

	PlayerHarry.myHUD.SetSubtitleText(SayText, SoundLen + BumpLineHoldTime);

	GotoState('DoingBumpLine');
}

state DoingBumpLine
{
	function CutCue(string cue)
	{
		if ( bBumpCaptureHarry )
		{
			PlayerHarry.CutCommand("release");
			PlayerHarry.CutNotifyActor = None;
		}

		CutNotifyActor = None;
		GotoState(SavedPreBumpState);
		DesiredRotation = SavedPreBumpRot;
		LastBumpTime = Level.TimeSeconds;
	}

	begin:
		LoopAnim(BabbleAnim,,0.5);
	
	babble:
		if ( bTurnToHarry )
		{
			TurnTo(LocationSameZ(PlayerHarry.Location));
		}

		if ( CurrentLetter < LettersToBabble.Length )
		{
			if ( LettersToBabble[CurrentLetter] == None )
			{
				Sleep(TimeBetweenBabble);
			}
			else
			{
				PlaySound(LettersToBabble[CurrentLetter], SLOT_Talk, BabbleVoiceVolume,, BabbleVoiceRadius, BabbleVoicePitch, True);
			}
		}
		else
		{
			goto('end');
		}

		CurrentLetter++;
		Sleep(TimeBetweenBabble);
		goto('babble');
	
	end:
		LettersToBabble.empty();
		CurrentLetter = 0;
}

function BabbleString(string InputText)
{
	local int i;
	local string Letter;
	local string SoundName;
	local sound SoundRef;

	local array<Sound> LetterArray;

	InputText = Caps(InputText);

	for ( i = 0; i < Len(InputText); i++ )
	{
		Letter = Mid(InputText, i, 1);

		if ( (Asc(Letter) < 65 || Asc(Letter) > 90) && (Asc(Letter) < 97 || Asc(Letter) > 122) )
		{
			LetterArray[LetterArray.Length] = None;
		}
		else
		{
			SoundName = "MocaSoundPak.babble_"$Letter;
			SoundRef = Sound(DynamicLoadObject(SoundName, class'Sound'));

			if ( SoundRef != None )
			{
				LetterArray[LetterArray.Length] = SoundRef;
			}
		}
	}

	LettersToBabble = LetterArray;
}


////////////////////
// Misc. Functions
////////////////////

function int CountSpaces()
{
	local int NumSpaces;
	local int i;

	for ( i = 0; i < lettersToBabble.Length; i++ )
	{
		if ( LettersToBabble[i] == None )
		{
			NumSpaces++;
		}
	}

	return NumSpaces;
}


defaultproperties
{
	TimeBetweenBabble=0.05
	BabbleAnim=Idle
	DelayBeforeEnding=2.0
	bUseBumpLine=True
	BabbleVoicePitch=1.5
	BabbleVoiceRadius=100000.0
	BabbleVoiceVolume=1.4
}