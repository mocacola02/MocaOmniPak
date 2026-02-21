class MOCASubtitleTrigger extends MOCATrigger;

var() string MessageText;                // Moca: Text to display in the popup
var() string WebMessageLink;             // Link to web text resource to display. This currently crashes (idk why) so don't use it yet
var() float TimeOut;                     // Moca: Duration in seconds.


function ProcessTrigger()
{
	if ( WebMessageLink != "" )
	{
		//MessageText = LoadURL(WebMessageLink);
		MessageText = "Web text is not supported yet due to an engine crash.";
		if ( MessageText == "" )
		{
			MessageText = "Unable to fetch web content.";
		}
	}

	PlayerHarry.MyHud.SetSubtitleText(MessageText, TimeOut);
}

defaultproperties
{
	MessageText="Change this text in the trigger properties."
	TimeOut=5
}
