class MOCAStatusGroupAir extends StatusGroup;

function GetGroupFinalXY_2 (bool bMenuMode, int nCanvasSizeX, int nCanvasSizeY, int nIconWidth, int nIconHeight, out int nOutX, out int nOutY)
{
	local float fScaleFactor;

	fScaleFactor 	= GetScaleFactor(nCanvasSizeX);
	nOutX 			= fScaleFactor * 68;
	nOutY 			= fScaleFactor * 320;
}

function GetGroupFlyOriginXY (bool bMenuMode, Canvas GroupCanvas, int nIconWidth, int nIconHeight, out int nX, out int nY)
{
	local int nFinalX;
	local int nFinalY;
	local float fScaleFactor;

	fScaleFactor 	= GetScaleFactor(GroupCanvas.SizeX);
	GetGroupFinalXY(bMenuMode, GroupCanvas, nIconWidth, nIconHeight, nFinalX, nFinalY);
	nX 				= nFinalX;
	nY 				=  -(fScaleFactor * nIconHeight);
}

defaultproperties
{
     AlignmentType=AT_Left
     fTotalEffectInTime=0.3
     fTotalHoldTime=3
     fTotalEffectOutTime=0.3
}
