//================================================================================
// MOCABabbler.
//================================================================================

class MOCABabbler extends MOCAChar;

var () float timeBetweenBabble; 	// Moca: How many seconds in between the connected babble sounds. Def: 0.1
var () float delayBeforeEnding; 	// Moca: How many seconds to hold on the subtitles after done talking. Def: 2.0
var () float voiceVolume; 			// Moca: How loud should the voice be. Def: 1.4
var () float babbleVoicePitch; 		// Moca: How high or deep should the voice. Def: 128
var () float voiceRadius; 			// Moca: How far should the voice reach? Def: 100000.0
var () name babbleAnim; 			// Moca: What animation to use for babbling. Def: Idle
var () string customMessage; 		// Moca: Type a message here to skip setting up a bumpline. Def: empty
var () bool bTurnToHarry; 			// Moca: Should actor turn towards Harry while talking. Def: false

var int currentLetter;
var array<sound> lettersToBabble;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if (babbleVoicePitch <= 0.0)
	{
		babbleVoicePitch = 1.0;
	}
	else if (babbleVoicePitch > 2.0)
	{
		babbleVoicePitch = 2.0;
	}
}

// ripped from KW code, don't blame me
function DoBumpLine (optional bool bJustTalk, optional string AlternateBumpLineSet)
{
	local string sSetID;
	local string sSayTextID;
	local string sSayText;
	local float sndLen;
	local TimedCue tcue;
	local int ri;
	local int rm;
	local int numSpaces;

	Log("ATTEMPT BUMPLINE");

	if (customMessage != "")
	{
		sSayText = customMessage;
	
		BabbleString(sSayText);
		numSpaces = CountSpaces();
		Log("Number of Spaces: " $ string(numSpaces));
		sndLen = (Len(sSayText) * timeBetweenBabble) + (numSpaces * timeBetweenBabble) + delayBeforeEnding;

		// Metallicafan212:	This wasn't here for some reason
		sSayText = HandleFacialExpression( sSayText, sndLen );
		
		if( !bJustTalk )
		{
			//create a TimedCue to cue object after sndLen seconds.
			tcue=spawn(class 'TimedCue');
			tcue.CutNotifyActor=Self;		//Tell me when done. This is auto passed back to the CutNotifyActor if any.
											//Or it can be used by the talk to find out when the talk is finished.
			tcue.SetupTimer(sndLen+0.5,"_BumpLineCue"); //little extra time for slop
		}

		//show text
		level.playerHarryActor.MyHud.SetSubtitleText(sSayText, sndLen);
		
		if( !bJustTalk )
		{
			Log("Time to babble!");
			GotoState('DoingBumpLine');
			return;
		}
		else
		{
			Log("Got to the end and couldn't babble with custom message.");
			return;
		}
	}

	if (  !bUseBumpLine &&  !bJustTalk )
	{
		if (!bDoRandomBumpLine)
		{
			return;
		}
	}
	if ( (CutNotifyActor != None) &&  !bJustTalk )
	{
		return;
	}
	if ( (BumpLineSet == "") && (AlternateBumpLineSet == "") )
	{
		Level.PlayerHarryActor.ClientMessage("ERROR BUMPLINES:" $ string(self) $ " has no BumpLineSet");
		if (!bDoRandomBumpLine)
		{
			return;
		}
	}
	if ( AlternateBumpLineSet != "" )
	{
		sSetID = AlternateBumpLineSet;
		Level.PlayerHarryActor.ClientMessage("BUMPLINES:" $ string(self) $ " looking for BumpLineSet:" $ sSetID);
		// DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
		//sSayTextID = Localize(sSetID, "line" $(Rand(int(Localize(sSetID, "Count", "BumpSet")))), "BumpSet");
		sSayTextID = Localize(sSetID, "line" $(Rand(int(Localize(sSetID, "Count", BumpSetFile)))), BumpSetFile);
	} 
	else 
	{
		if ( BumpLineSetPrefix != "" )
		{
			sSetID = BumpLineSetPrefix $"_" $BumpLineSet;
		} 
		else 
		{
			sSetID = BumpLineSet;
		}
		//log(sSetID);
		Level.PlayerHarryActor.ClientMessage("BUMPLINES:" $ string(self) $ " looking for BumpLineSet:" $ BumpLineSet);
		if ( bDoRandomBumpLine )
		{
			// DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
			//rm = int(Localize(sSetID, "Count", "BumpSet"));
			rm = int(Localize(sSetID, "Count", BumpSetFile));
			ri = Rand(rm);
			if ( ri == lastRandomBumpLine )
			{
				ri = (ri + 1) % rm;
				lastRandomBumpLine = ri;
			}
			// DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
			//sSayTextID = Localize(sSetID, "line" $ri,"BumpSet");
			sSayTextID = Localize(sSetID, "line" $ri,BumpSetFile);
		} 
		else 
		{
			// DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
			//sSayTextID = Localize(sSetID, "line" $curBumpLine,"BumpSet");
			sSayTextID = Localize(sSetID, "line" $curBumpLine,BumpSetFile);
			curBumpLine++ ;
			if ( InStr(sSayTextID,"<") > -1 )
			{
				curBumpLine = 0;
				// DivingDeep39: Replaced "BumpSet" with the BumpSetFile var.
				//sSayTextID = Localize(sSetID,"line" $curBumpLine,"BumpSet");
				sSayTextID = Localize(sSetID,"line" $curBumpLine,BumpSetFile);
			}
		}
		if ( InStr(sSayTextID, "<") > -1 )
		{
			Level.PlayerHarryActor.ClientMessage("ERROR BUMPLINES:" $ string(self) $ " couldn't find BumpLineSet:" $ BumpLineSet);
			return;
		}
	}
	Level.PlayerHarryActor.ClientMessage("BUMPLINES:" $ string(self) $ " looking for BumpLine ID:" $ sSayTextID);
	// DivingDeep39: Replaced " "all" " and "BumpDialog" with the Section and LocalizationFile vars.
	//sSayText = Localize("all",sSayTextID,"BumpDialog");
	sSayText = Localize(Section,sSayTextID,LocalizationFile);
	if ( InStr(sSayText,"<?") > -1 )
	{
		Level.PlayerHarryActor.ClientMessage("ERROR BUMPLINES:" $ string(self) $ " couldn't find BumpLine ID:" $ sSayTextID $ " from BumpLineSet:" $ BumpLineSet);
		return;
	}
	SavedPreBumpState = GetStateName();
	SavedPreBumpRot = Rotation;
	if ( bBumpCaptureHarry && (Level.PlayerHarryActor.CutNotifyActor != None) )
	{
		Level.PlayerHarryActor.CutNotifyActor = self;
		Level.PlayerHarryActor.CutCommand("capture");
	}
	CutNotifyActor = self;

	BabbleString(sSayText);
    numSpaces = CountSpaces();
	Log("Number of Spaces: " $ string(numSpaces));
	sndLen = (Len(sSayText) * timeBetweenBabble) + (numSpaces * timeBetweenBabble) + delayBeforeEnding;

	// Metallicafan212:	This wasn't here for some reason
	sSayText = HandleFacialExpression( sSayText, sndLen );
	
	if( !bJustTalk )
	{
		//create a TimedCue to cue object after sndLen seconds.
		tcue=spawn(class 'TimedCue');
		tcue.CutNotifyActor=Self;		//Tell me when done. This is auto passed back to the CutNotifyActor if any.
										//Or it can be used by the talk to find out when the talk is finished.
		tcue.SetupTimer(sndLen+0.5,"_BumpLineCue"); //little extra time for slop
	}

	//show text
	level.playerHarryActor.MyHud.SetSubtitleText(sSayText, sndLen);
	
	if( !bJustTalk )
	{
		Log("Time to babble!");
		GotoState('DoingBumpLine');
	}
	else
	{
		Log("Got to the end and couldn't babble.");
	}
}

state DoingBumpLine
{
	function BeginState()
	{
		Log("ENTERING DoingBumpline");
		Acceleration = vect(0.00,0.00,0.00);
		Velocity = vect(0.00,0.00,0.00);
		PlayAnim(babbleAnim,1.0,0.5);
	}
  
	event Bump (Actor Other)
	{
		Super.Bump(Other);
	}
  
	function CutCue (string cue)
	{
		if ( bBumpCaptureHarry )
		{
			Level.PlayerHarryActor.CutCommand("release");
			Level.PlayerHarryActor.CutNotifyActor = None;
		}
		CutNotifyActor = None;
		GotoState(SavedPreBumpState);
		DesiredRotation = SavedPreBumpRot;
		LastBumpTime = Level.TimeSeconds;
	}

	begin:
		LoopAnim(GetBabbleAnim());
		goto ('babble');
	
	babble:
		if (bTurnToHarry)
		{
			TurnTo(LocationSameZ(PlayerHarry.Location));
		}
		if (currentLetter < lettersToBabble.Length)
        {
			if (lettersToBabble[currentLetter] == None)
			{
				sleep(timeBetweenBabble);
			}
			else
			{
				Log("Saying Letter: " $ string(lettersToBabble[currentLetter]));
				PlaySound(lettersToBabble[currentLetter],SLOT_Talk,voiceVolume,,voiceRadius,babbleVoicePitch,True);
			}
        }
        else
        {
            goto ('end');
        }
        currentLetter++;
		sleep(timeBetweenBabble);
		goto ('babble');

    end:
		lettersToBabble.empty();
        currentLetter = 0;
}

function name GetBabbleAnim()
{
	return babbleAnim;
}

function BabbleString(string inputText)
{
	local int i;
	local string letter;
	local string soundName;
	local sound soundRef;

	local array<sound> letterArray;

	// Convert to uppercase
	inputText = Caps(inputText);

	for (i = 0; i < Len(inputText); i++)
	{
		letter = Mid(inputText, i, 1);

		if ((Asc(letter) < 65 || Asc(letter) > 90) && (Asc(letter) < 97 || Asc(letter) > 122))
		{
			letterArray[letterArray.Length] = None;
		}
		else
		{
			soundName = "MocaSoundPak.babble_" $ letter;
			soundRef = Sound(DynamicLoadObject(soundName, class'Sound'));

			if (soundRef != None)
			{
				letterArray[letterArray.Length] = soundRef;
			}
		}
	}

	lettersToBabble = letterArray;
}

function int CountSpaces()
{
	local int numSpaces;
	local int i;
	numSpaces = 0;

	for (i = 0; i < lettersToBabble.Length; i++)
	{
		if (lettersToBabble[i] == None)
		{
			numSpaces++;
		}
	}

	return numSpaces;
}

defaultproperties
{
	timeBetweenBabble=0.05
    babbleAnim=Idle
	delayBeforeEnding=2.0
	bUseBumpLine=true
	babbleVoicePitch=1.5
	voiceRadius=100000.0
	voiceVolume=1.4
}