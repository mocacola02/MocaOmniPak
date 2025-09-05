class MOCAWarning extends baseWarning;

var float SizeScale;

function Draw (Canvas cCanvas)
{
  local Font saveFont;
  local float fTextHeight;
  local float fTextWidth;
  local int t;
  local Texture Background;

  saveFont = cCanvas.Font;
  if ( bShow )
  {
    if ( fFlashTime > 1 )
    {
      bShow = True;
      fFlashTime = 0.0;
    }
    Background = Texture'leftPanel';
    Background.Alpha = 0.5;
    Background.bTransparent = True;
    cCanvas.FontScale = SizeScale;
    cCanvas.Font = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
    cCanvas.TextSize(DisplayText,fTextWidth,fTextHeight);
    if ( fTextWidth > cCanvas.SizeX - 32 )
    {
        cCanvas.Font = baseConsole(PlayerHarry.Player.Console).LocalMedFont;
        cCanvas.TextSize(DisplayText,fTextWidth,fTextHeight);
      if ( fTextWidth > cCanvas.SizeX - 32 )
      {
        cCanvas.Font = baseConsole(PlayerHarry.Player.Console).LocalSmallFont;
        cCanvas.TextSize(DisplayText,fTextWidth,fTextHeight);
      }
    }
    cCanvas.SetPos(cCanvas.SizeX / 2 - (fTextWidth / 2) - 8,8.0);
    cCanvas.DrawTile(Background,(fTextWidth + 16),(fTextHeight + 16),0.0,0.0,1.0,1.0);
    cCanvas.SetPos(cCanvas.SizeX / 2 - (fTextWidth / 2),16.0);
    cCanvas.DrawText(DisplayText,False);
    cCanvas.Reset();
  } else {
    if ( fFlashTime > 0.5 )
    {
      bShow = True;
      fFlashTime = 0.0;
    }
  }
  cCanvas.Font = saveFont;
  cCanvas.Reset();
}