class MOCAStatusGroupShield extends StatusGroup;

function GetGroupFinalXY_2 (bool bMenuMode, int nCanvasSizeX, int nCanvasSizeY, int nIconWidth, int nIconHeight, out int nOutX, out int nOutY)
{
  local float fScaleFactor;

  fScaleFactor 	= GetScaleFactor(nCanvasSizeX);
  nOutX 		= 554 * fScaleFactor;
  nOutY 		= fScaleFactor * 4;
}

function GetGroupFlyOriginXY (bool bMenuMode, Canvas C, int nIconWidth, int nIconHeight, out int nOutX, out int nOutY)
{
	local int nFinalX;
	local int nFinalY;
	local float fScaleFactor;

	fScaleFactor 	= GetScaleFactor(C.SizeX);
	GetGroupFinalXY(bMenuMode, C, nIconWidth, nIconHeight, nFinalX, nFinalY);
	nOutX 			= nFinalX;
	nOutY 			= -(fScaleFactor * nIconHeight);
}

defaultproperties
{
    fTotalEffectInTime=0.50

    fTotalHoldTime=3.00

    fTotalEffectOutTime=0.20

    MenuProps=Menu_IfCurrentlyHaveAny
	
	AlignmentType=AT_Right
}