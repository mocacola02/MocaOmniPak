class MOCAWarnTrigger extends MOCATrigger;

var() string WarningMessage;
var() float Duration;
var() float SizeMultiplier;
var() Font WarningFont;
var() Sound WarningSound;
var() float WarningSoundVolume;
var() float fXPos;	// Moca: Sets the position of the pop up. If 0, uses the default top centered position.
var() float fYPos;	// Moca: Sets the position of the pop up. If 0, uses the default top centered position.
var() float fWarnWidth;
var() float fWarnHeight;
/* var() Color BackdropColor;
var() Color FontColor; */

event Activate (Actor Other,Pawn Instigator)
{
	PlaySound(WarningSound,SLOT_None,WarningSoundVolume);
	baseHUD(PlayerHarry.myHUD).ShowPopup(Class'MOCAWarning');
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).LabelFont = WarningFont;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).XPos = fXPos;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).YPos = fYPos;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).TileW = fWarnWidth;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).TileH = fWarnHeight;
/* 	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).BackdropColor = BackdropColor;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).FontColor = FontColor; */
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).SizeScale = SizeMultiplier;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).DisplayText = WarningMessage;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).LifeSpan = Duration;

	if ( bTriggerOnceOnly )
	{
		Disable('Activate');
	}
}

defaultproperties
{
  WarningMessage="Edit message in the properties."
  Duration=5.0
  SizeMultiplier=2.0
  WarningSoundVolume=1.0
}