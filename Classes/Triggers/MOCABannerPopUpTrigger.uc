//=============================================================================
// MOCAPopUpTrigger.
//=============================================================================
class MOCABannerPopUpTrigger extends MOCATrigger;

enum EHoriAlign
{
	HA_Left,
	HA_Center,
	HA_Right
};

enum EVertAlign
{
	VA_Top,
	VA_Center,
	VA_Bottom
};

//= Message Vars =//
var(MOCAPopUpGeneral) float PopUpDuration;							// Moca: How long will the warning pop up appear?
var(MOCAPopUpGeneral) float FadeInTime, FadeOutTime;
var(MOCAPopUpGeneral) string PopUpMessage;							// Moca: Message to display on the pop up
var(MOCAPopUpGeneral) Sound PopUpSound;								// Moca: Sound to play on pop up

//= Display Vars =//
var(MOCAPopUpDisplay) float PopUpOpacity;
var(MOCAPopUpDisplay) float BoxMarginPx;
var(MOCAPopUpDisplay) float ScreenMarginPx;
var(MOCAPopUpDisplay) float FontScaleMult;							// Moca: Size multiplier of pop up
var(MOCAPopUpDisplay) Texture BannerTexture;
var(MOCAPopUpDisplay) Font PopUpFont;								// Moca: Font to use for message text
var(MOCAPopUpDisplay) EHoriAlign HorizontalAlignment;		// Moca: How to align pop up on the screen horizontally
var(MOCAPopUpDisplay) EVertAlign VerticalAlignment;		// Moca: How to align pop up on the screen vertically

//= Blinking Vars =//
var(MOCAPopUpFlash) bool bBlinkBeforeClose;
var(MOCAPopUpFlash) float BlinkStartTime;		// How many seconds into PopUpDuration should we start blinking? Won't work if BlinkStartTime >= PopUpDuration
var(MOCAPopUpFlash) float BlinkFrequency;		// How much time in between blinks?
var(MOCAPopUpFlash) float BlinkFade;			// Fade value when blinking. 0.0 is invisible, 1.0 is visible

//= Actor Refs =//
var MOCABannerPopUp PopUp;


//===================
// Trigger Handling
//===================

function ProcessTrigger(Actor Other, Pawn Instigator)
{
	if ( PopUp == None )
	{
		baseHUD(PlayerHarry.myHUD).ShowPopup(Class'MOCABannerPopUp');
		PopUp = MOCABannerPopUp(baseHUD(PlayerHarry.myHUD).curPopup);

		if ( PopUp != None )
		{
			PopUp.OwningTrigger = self;
			PopUp.SetTimer(PopUpDuration, False);
			PopUp.SetTextProperties(PopUpMessage, PopUpFont, BannerTexture);
			PopUp.SetSizeProperties(FontScaleMult, BoxMarginPx, ScreenMarginPx);

			// Casting to an int here probably isn't ideal
			PopUp.SetAlignProperties(HorizontalAlignment, VerticalAlignment);
			PopUp.SetFadeProperties(PopUpOpacity, FadeInTime, FadeOutTime);

			if ( bBlinkBeforeClose )
			{
				PopUp.SetBlinkProperties(BlinkStartTime, BlinkFrequency, BlinkFade);
			}

			if ( PopUpSound != None )
			{
				PlaySound(PopUpSound, [Disable3D] True);
			}
		}
	}
	else
	{
		Log("We already have a pop up");
	}
}


//=====================
// Default Properties
//=====================

defaultproperties
{
	PopUpDuration=5.0
	FadeInTime=0.5
	FadeOutTime=0.5
	PopUpMessage="Edit the message from MOCAPopUpTrigger properties."
	
	PopUpOpacity=1.0
	BoxMarginPx=4.0
	ScreenMarginPx=64.0
	FontScaleMult=1.5
	BannerTexture=Texture'leftPanel'
	HorizontalAlignment=HA_Center
	VerticalAlignment=VA_Top

	BlinkStartTime=3.5
	BlinkFrequency=0.5
	BlinkFade=0.334

	TransientSoundVolume=1.0
}