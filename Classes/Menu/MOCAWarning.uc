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

	// Reset flash timer
	if (fFlashTime > 1)
	{
		bShow = true;
		fFlashTime = 0.0;
	}

	// Background
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

	if (XPos != 0 && YPos != 0)
	{
		local float AutoPadding;

		AutoPadding = 8; // padding used when no explicit size set

		// Determine box size
		BoxW = (TileW > 0) ? TileW : (TextW + AutoPadding * 2);
		BoxH = (TileH > 0) ? TileH : (TextH + AutoPadding * 2);

		// Top-left origin comes from XPos/YPos
		BoxX = XPos;
		BoxY = YPos;

		// Draw tile
		C.SetPos(BoxX, BoxY);
		C.DrawTile(Background, BoxW, BoxH, 0, 0, 1, 1);

		// Center text inside box
		TextX = BoxX + (BoxW * 0.5) - (TextW * 0.5);
		TextY = BoxY + (BoxH * 0.5) - (TextH * 0.5);

		C.SetPos(TextX, TextY);
		C.DrawText(DisplayText, false);

		C.Font = OldFont;
		C.Reset();
		return;
	}

	BoxW = TextW + 16;
	BoxH = TextH + 16;

	// Center top of screen
	BoxX = (C.SizeX - BoxW) * 0.5;
	BoxY = 8;

	C.SetPos(BoxX, BoxY);
	C.DrawTile(Background, BoxW, BoxH, 0, 0, 1, 1);

	// Text center inside tile
	TextX = (C.SizeX - TextW) * 0.5;
	TextY = BoxY + 8;

	C.SetPos(TextX, TextY);
	C.DrawText(DisplayText, false);

	C.Font = OldFont;
	C.Reset();
}