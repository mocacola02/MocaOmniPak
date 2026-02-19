class MOCAChangeAnimSetTrigger extends MOCATrigger;

enum enumHarryAnimSet {
	HARRY_ANIM_SET_MAIN,
	HARRY_ANIM_SET_ECTO,
	HARRY_ANIM_SET_SLEEPY,
	HARRY_ANIM_SET_SWORD,
	HARRY_ANIM_SET_WEB,
	HARRY_ANIM_SET_DUEL
};

var() enumHarryAnimSet NewAnimSet; // Moca: What set to change to?

event Activate(Actor Other, pawn Instigator)
{
	ProcessTrigger(Other);
}

function ProcessTrigger(Actor Other)
{
	local int SetID;
	local harry.enumHarryAnimSet TargetSet;

	if ( Other.IsA('MOCAharry') )
	{
		SetID = int(NewAnimSet);
		TargetSet = harry.enumHarryAnimSet(SetID);
		MOCAharry(Other).SetAnimSet(TargetSet);
	}
	else
	{
		Log("ChangeAnimSetTrigger got hit by "$string(Other)$", but we require MOCAharry!");
	}
}

defaultproperties
{
	newAnimSet=HARRY_ANIM_SET_MAIN
}