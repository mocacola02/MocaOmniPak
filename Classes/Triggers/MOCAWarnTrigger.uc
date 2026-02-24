//=============================================================================
// MOCAWarnTrigger.
//=============================================================================
class MOCAWarnTrigger extends MOCATrigger;

var() float Duration;				// Moca: How long will the warning pop up appear?
var() float WarningSoundVolume;		// Moca: Volume of the sound to play when pop up is made
var() float SizeMultiplier;			// Moca: Size multiplier of pop up
var() float XPosition;				// Moca: Optional X (left & right) position of pop up. If 0.0, it centers to the screen.
var() float YPosition;				// Moca: Optional Y (up & down) position of pop up. If 0.0, it appears at the top of the screen.

var() string WarningMessage;		// Moca: Message to display on the pop up
var() Font WarningFont;				// Moca: Font to use for message text
var() Sound WarningSound;			// Moca: Sound to play on pop up

function ProcessTrigger(Actor Other, Pawn Instigator)
{
	local MOCAWarning PopUp;
	
	// Get ref to pop up
	baseHUD(PlayerHarry.myHUD).ShowPopup(Class'MOCAWarning');
	PopUp = MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup);

	// Set font
	PopUp.LabelFont = WarningFont;

	// Set position
	PopUp.XPos = XPosition;
	PopUp.YPos = YPosition;

	// Set scale, text, & duration
	PopUp.SizeScale = SizeMultiplier;
	PopUp.DisplayText = WarningMessage;
	PopUp.LifeSpan = Duration;

	// Play pop up sound
	PlaySound(WarningSound,SLOT_None,WarningSoundVolume,,,,True);

	// If bTriggerOnceOnly, don't allow this event to trigger again
	if ( bTriggerOnceOnly )
	{
		Disable('Activate');
	}
}


defaultproperties
{
	Duration=5.0
	WarningSoundVolume=1.0
	SizeMultiplier=2.0
	WarningMessage="Edit message in the properties."
}