class MOCAChangeAnimSetTrigger extends Trigger;

enum enumHarryAnimSet {
  HARRY_ANIM_SET_MAIN,
  HARRY_ANIM_SET_ECTO,
  HARRY_ANIM_SET_SLEEPY,
  HARRY_ANIM_SET_SWORD,
  HARRY_ANIM_SET_WEB,
  HARRY_ANIM_SET_DUEL
};

var() enumHarryAnimSet newAnimSet; //Moca: What set to change to?

event Touch( Actor Other )
{
    TriggerEvent('',Other,None);
}

function TriggerEvent (name EventName, Actor Other, Pawn EventInstigator)
{
    local int setID;

    if (Other.IsA('MOCAharry'))
    {
        setID = int(newAnimSet);
        Log("Trigger anim set change with ID " $ string(setID));
        MOCAharry(Other).SetAnimSet(setID);
    }
    else
    {
        Log("ChangeAnimSetTrigger got hit by " $ string(Other) $ ", but we require MOCAharry!");
    }
}

defaultproperties
{
    newAnimSet=HARRY_ANIM_SET_MAIN
}