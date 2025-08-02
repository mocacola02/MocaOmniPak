class MOCAWarnTrigger extends WarnTrigger;

function Touch (Actor Other)
{
  local Actor A;
  local harry H;

  baseHUD(PlayerHarry.myHUD).ShowPopup(Class'baseWarning');
  baseWarning(baseHUD(PlayerHarry.myHUD).curPopup).DisplayText = WarningMessage;
  baseWarning(baseHUD(PlayerHarry.myHUD).curPopup).LifeSpan = durration;
  if ( bTriggerOnceOnly )
  {
    Disable('Touch');
  }
}