class MOCAharryAnimChannel extends cHarryAnimChannel;

auto state stateIdle
{
  function BeginState()
  {
    harry(Owner).PlayIdle();
    //LoopAnim('CastAim',1.0,0.5);
  }
}

state stateCasting
{
begin:
    harry(Owner).HarryAnimType = AT_Combine;
    Log("Using custom stateCasting");
    if ( harry(Owner).bHarryUsingSword )
    {
        LoopAnim('swordaim',1.0,0.2);
    }
  
    else if ( harry(Owner).bInDuelingMode )
        {
        LoopAnim('duel_charge',1.0,0.2);
        }

    else {
        PlayAnim(harry(Owner).CurrIdleAnimName);
        PlayAnim('CastAim',,0.5);
        FinishAnim();
        LoopAnim('CastAim',1.0,0.5);
    }
}