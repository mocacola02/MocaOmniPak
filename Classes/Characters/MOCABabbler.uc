//================================================================================
// MOCABabbler.
//================================================================================
class MOCABabbler extends MOCAChar;

var() bool bRandomBumpLine;		// Moca: Use random bumpline instead of cycling through them? Def: True
var() bool bTurnToHarry; 		// Moca: Should actor turn towards Harry while talking. Def: False
var() float TimeBetweenBabble; 	// Moca: How many seconds in between the connected babble sounds. Def: 0.1
var() float DelayBeforeEnding; 	// Moca: How many seconds to hold on the subtitles after done talking. Def: 2.0
var() name BabbleAnim; 			// Moca: What animation to use for babbling. Def: Idle
var() string CustomMessage; 	// Moca: Type a message here to skip setting up a bumpline. Def: empty


var int CurrentBumpline;			// Current bumpline we're on
var int CurrentLetter;				// Current letter we're on
var array<Sound> LettersToBabble;	// Array of letters to speak


///////////
// Events
///////////

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Fix invalid pitch values
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

	// If we have a specified custom message
	if ( CustomMessage != "" )
	{
		// Custom message will be the SayText
		SayText = CustomMessage;
	
		// Get our babble array
		BabbleString(SayText);

		// Get number of spaces
		NumberOfSpaces = CountSpaces();

		// Determine length of message
		SoundLen = (Len(SayText) * TimeBetweenBabble) + (NumberOfSpaces * TimeBetweenBabble) + DelayBeforeEnding;

		// Do facial expression if applicable
		SayText = HandleFacialExpression(SayText, SoundLen);

		// Create subtitle box with text
		PlayerHarry.MyHud.SetSubtitleText(SayText, SoundLen);
		
		// If we can talk
		if( !bJustTalk )
		{
			// Setup cue
			local TimedCue TCue;
			TCue = Spawn(class'TimedCue');
			TCue.CutNotifyActor = Self;
			TCue.SetupTimer(SoundLen + 0.5, "_BumpLineCue");
			// Start talking
			GotoState('DoingBumpLine');
		}

		// Otherwise, cancel
		return;
	}

	// If we don't have valid bump params, cancel
	if ( BumpSetFile == "" && AlternateBumpSet == "" )
	{
		Print("ERROR, I DO NOT HAVE ANY BUMPLINES!!!",True);
		return;
	}

	// Set our target bumpset
	ActiveBumpSet = BumpSetFile;

	// If we have an alternative, use that
	if ( AlternateBumpSet != "" )
	{
		ActiveBumpSet = AlternateBumpSet;
	}

	// Add prefix to get our ID
	if ( BumpSetPrefix != "" )
	{
		SetID = BumpsetPrefix$"_"$ActiveBumpSet;
	}

	Print("LOOKING FOR BUMPSET: "$string(SetID));

	// Get bumpline index
	if ( bRandomBumpLine )
	{
		local int NumOfBS;
		local int i;

		// Get random index
		NumOfBS = int(Localize(SetID, "Count", BumpSetFile));
		i = Rand(NumOfBS);


		CurrentBumpline = i;
	}
	else
	{
		// Increment index
		CurrentBumpline++;
		
		// If we're too high, go back to 0
		if ( InStr(SayTextID, "<") > -1 )
		{
			CurrentBumpline = 0;
		}
	}

	// Localize SayTextID
	SayTextID = Localize(SetID, "line"$CurrentBumpline, ActiveBumpSet);

	// If we still have invalid index, cancel
	if ( InStr(SayTextID, "<") > -1 )
	{
		Print("ERROR: COULDN'T FIND BUMPSET: "$ActiveBumpSet);
		return;
	}

	// Get SayText from localization file
	SayText = Localize(Section, SayTextID, LocalizationFile);

	// If we have a bad ID, cancel
	if ( InStr(SayText, "<?") > -1 )
	{
		Print("ERROR: COULDN'T FIND BUMPLINE ID: "$SayTextID$" FROM BUMPSET: "$ActiveBumpSet);
		return;
	}

	// If bBumpCaptureHarry, capture Harry
	if ( bBumpCaptureHarry && PlayerHarry.CutNotifyActor != None )
	{
		PlayerHarry.CutNotifyActor = Self;
		PlayerHarry.CutCommand("capture");
	}
	
	// We are the CutNotifyActor
	CutNotifyActor = Self;

	// Get babble array
	BabbleString(SayText);

	// Get number of spaces
	NumberOfSpaces = CountSpaces();

	// Determine length of message
	SoundLen = (Len(SayText) * TimeBetweenBabble) + (NumberOfSpaces * TimeBetweenBabble) + DelayBeforeEnding;

	// Handle face expression if needed
	SayText = HandleFacialExpression(SayText, SoundLen);
	
	// Store our rotation
	SavedPreBumpRot = Rotation;

	// Setup the cue
	local TimedCue TCue;
	TCue = Spawn(class'TimedCue');
	TCue.CutNotifyActor = Self;
	TCue.SetupTimer(SoundLen + 0.5, "_BumpLineCue");

	// Create subtitle box with message
	PlayerHarry.myHUD.SetSubtitleText(SayText, SoundLen);

	GotoState('DoingBumpLine');
}

state DoingBumpLine
{
	function CutCue(string cue)
	{
		// If we captured Harry, release him
		if ( bBumpCaptureHarry )
		{
			PlayerHarry.CutCommand("release");
			PlayerHarry.CutNotifyActor = None;
		}

		// Prepare to end bumpline state
		CutNotifyActor = None;
		DesiredRotation = SavedPreBumpRot;
		LastBumpTime = Level.TimeSeconds;
		GotoState(LastValidState);
	}

	begin:
		// Loop talk animation
		LoopAnim(BabbleAnim,,0.5);
	
	babble:
		// If bTurnToHarry, turn to him
		if ( bTurnToHarry )
		{
			TurnTo(LocationSameZ(PlayerHarry.Location));
		}

		// If we still have more to say
		if ( CurrentLetter < LettersToBabble.Length )
		{
			// If the current letter is a space
			if ( LettersToBabble[CurrentLetter] == None )
			{
				// Wait for TimeBetweenBabble amount of seconds
				Sleep(TimeBetweenBabble);
			}
			// Otherwise
			else
			{
				// Say the letter
				PlaySound(LettersToBabble[CurrentLetter], SLOT_Talk);
			}
		}
		else
		{
			// Go to 'end' label if no more letters
			goto('end');
		}

		// Increment our current letter
		CurrentLetter++;
		// Wait for TimeBetweenBabble amount of seconds
		Sleep(TimeBetweenBabble);
		// Restart our babble loop
		goto('babble');
	
	end:
		//Reset array and current letter
		LettersToBabble.empty();
		CurrentLetter = 0;
}


////////////////////
// Helper Functions
////////////////////

function BabbleString(string InputText)
{
	local int i;
	local string Letter;
	local string SoundName;
	local sound SoundRef;

	local array<Sound> LetterArray;

	// Set text to all caps
	InputText = Caps(InputText);

	// For the length of the text
	for ( i = 0; i < Len(InputText); i++ )
	{
		// Get letter
		Letter = Mid(InputText, i, 1);

		// If our letter isn't actually a letter
		if ( (Asc(Letter) < 65 || Asc(Letter) > 90) && (Asc(Letter) < 97 || Asc(Letter) > 122) )
		{
			// Make it None (aka a space)
			LetterArray[LetterArray.Length] = None;
		}
		// Otherwise
		else
		{
			// Get sound name from letter
			SoundName = "MocaSoundPak.babble_"$Letter;
			SoundRef = Sound(DynamicLoadObject(SoundName, class'Sound'));

			// If valid, set the sound
			if ( SoundRef != None )
			{
				LetterArray[LetterArray.Length] = SoundRef;
			}
		}
	}

	// Store our final array of letters
	LettersToBabble = LetterArray;
}

function int CountSpaces()
{
	local int NumSpaces;
	local int i;

	// For each entry in LettersToBabble
	for ( i = 0; i < LettersToBabble.Length; i++ )
	{
		// If the entry is None (aka a space)
		if ( LettersToBabble[i] == None )
		{
			// Increase our space count
			NumSpaces++;
		}
	}

	// Return final count
	return NumSpaces;
}


defaultproperties
{
	bRandomBumpLine=True
	bTurnToHarry=True
	TimeBetweenBabble=0.1
	DelayBeforeEnding=1.0
	BabbleAnim=Idle
	
	TransientSoundVolume=1.4
	TransientSoundPitch=128
	TransientSoundRadius=10000.0
}