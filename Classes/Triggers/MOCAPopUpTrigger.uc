class MOCAPopUpTrigger extends Trigger;

var harry PlayerHarry;
var() string MessageText;                // Moca: Text to display in the popup
var() string WebMessageLink;             // Link to web text resource to display. This currently crashes (idk why) so don't use it yet
var() float TimeOut;                     // Moca: Duration in seconds.

event PreBeginPlay()
{
    Super.PreBeginPlay();
    PlayerHarry = harry(Level.PlayerHarryActor); // Cache the PlayerHarry instance
}

function Activate(actor Other, pawn Instigator)
{
    ProcessTrigger();
}

function ProcessTrigger()
{
    if (WebMessageLink != "")
    {
        MessageText = LoadURL(WebMessageLink);
        if (MessageText == "")
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
