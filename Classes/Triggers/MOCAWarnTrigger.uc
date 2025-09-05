class MOCAWarnTrigger extends MOCATrigger;

var() string WarningMessage;
var() float Duration;
var() float SizeMultiplier;

event Activate (Actor Other,Pawn Instigator)
{
  baseHUD(PlayerHarry.myHUD).ShowPopup(Class'MOCAWarning');
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
}