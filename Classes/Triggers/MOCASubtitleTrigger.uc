class MOCASubtitleTrigger extends MOCATrigger;

var() string MessageText;	// Moca: Text to display in the popup.
var() float MessageDuration;// Moca: Duration in seconds. Def: 5.0


function ProcessTrigger(Actor Other, Pawn EventInstigator)
{
	PlayerHarry.MyHud.SetSubtitleText(MessageText, MessageDuration);
}

defaultproperties
{
	MessageText="Change this text in the trigger properties."
	MessageDuration=5.0
}
