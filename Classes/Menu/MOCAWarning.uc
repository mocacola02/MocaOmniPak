class MOCAWarning extends baseWarning;

var float SizeScale;

var float XPos;    // Tile origin X (if non-zero)
var float YPos;    // Tile origin Y (if non-zero)
var float TileW;   // Optional custom width (0 = auto)
var float TileH;   // Optional custom height (0 = auto)

var Font LabelFont;

function Draw(Canvas C)
{
    local Font OldFont;
    local float TextW, TextH;
    local float BoxW, BoxH;
    local float BoxX, BoxY;
    local float TextX, TextY;
    local Texture Background;

    OldFont = C.Font;

    if (!bShow)
    {
        if (fFlashTime > 0.5)
        {
            bShow = true;
            fFlashTime = 0.0;
        }
        C.Font = OldFont;
        C.Reset();
        return;
    }

    if (fFlashTime > 1)
    {
        bShow = true;
        fFlashTime = 0.0;
    }

    Background = Texture'leftPanel';
    Background.Alpha = 0.5;
    Background.bTransparent = true;

    if (LabelFont == None)
    {
        C.FontScale = SizeScale;
        C.Font = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
        C.TextSize(DisplayText, TextW, TextH);

        if (TextW > C.SizeX - 32)
        {
            C.Font = baseConsole(PlayerHarry.Player.Console).LocalMedFont;
            C.TextSize(DisplayText, TextW, TextH);

            if (TextW > C.SizeX - 32)
            {
                C.Font = baseConsole(PlayerHarry.Player.Console).LocalSmallFont;
                C.TextSize(DisplayText, TextW, TextH);
            }
        }
    }
    else
    {
        C.FontScale = SizeScale;
        C.Font = LabelFont;
        C.TextSize(DisplayText, TextW, TextH);
    }

    BoxW = TextW + 16;
    BoxH = TextH + 16;

    BoxX = (C.SizeX - BoxW) * 0.5 + XPos;
    BoxY = 8 + YPos;

    if (BoxX < 0) BoxX = 0;
    if (BoxY < 0) BoxY = 0;
    if (BoxX + BoxW > C.SizeX) BoxX = C.SizeX - BoxW;
    if (BoxY + BoxH > C.SizeY) BoxY = C.SizeY - BoxH;

    C.SetPos(BoxX, BoxY);
    C.DrawTile(Background, BoxW, BoxH, 0, 0, 1, 1);

    TextX = BoxX + (BoxW - TextW) * 0.5;
    TextY = BoxY + 8;

    if (TextX < 0) TextX = 0;
    if (TextY < 0) TextY = 0;
    if (TextX + TextW > C.SizeX) TextX = C.SizeX - TextW;
    if (TextY + TextH > C.SizeY) TextY = C.SizeY - TextH;

    C.SetPos(TextX, TextY);
    C.DrawText(DisplayText, false);

    C.Font = OldFont;
    C.Reset();
}
