class MOCAWarnTrigger extends MOCATrigger;

var() string WarningMessage;
var() float Duration;
var() float SizeMultiplier;
var() Font WarningFont;
var() Sound WarningSound;
var() float WarningSoundVolume;
var() float XPos;	// Moca: Sets the position of the pop up. If 0, uses the default top centered position.
var() float YPos;	// Moca: Sets the position of the pop up. If 0, uses the default top centered position.
var() float fWarnWidth;
var() float fWarnHeight;

event Activate (Actor Other,Pawn Instigator)
{
	PlaySound(WarningSound,SLOT_None,WarningSoundVolume);
	baseHUD(PlayerHarry.myHUD).ShowPopup(Class'MOCAWarning');
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).LabelFont = WarningFont;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).XPos = XPos;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).YPos = YPos;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).TileW = fWarnWidth;
	MOCAWarning(baseHUD(PlayerHarry.myHUD).curPopup).TileH = fWarnHeight;
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