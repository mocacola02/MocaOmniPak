//=============================================================================
// MOCAWarning.
//=============================================================================
class MOCAWarning extends baseWarning;

var float SizeScale;	// Text size scale (which in turn increases overall scale)

var float XPos;    		// Tile origin X (if non-zero)
var float YPos;   		// Tile origin Y (if non-zero)
var float TileW;   		// Optional custom width (0 = auto)
var float TileH;   		// Optional custom height (0 = auto)

var float TextPadding;	// How many pixels to extend the box beyond the space the text requires

var float LabelOpacity;	// Opacity of label.	TODO: Add a fade in/out and maybe a smooth flicker in and out option

var Texture LabelTexture;	// Texture to use for background
var Font LabelFont;			// Font to use

function Draw(Canvas C)
{
	local float TextW,TextH;
	local float BoxW,BoxH;
	local float BoxX,BoxY;
	local float TextX,TextY;
	local Texture Background;

	// Prep the background texture & opacity
	Background = LabelTexture;
	Background.Alpha = LabelOpacity;
	Background.bTransparent = True;

	// If we don't have a font, use the console big font. I don't think we need to bother with the smaller font options but we'll see
	if ( LabelFont == None )
	{
		C.Font = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
	}

	// Set font & font scale
	C.FontScale = SizeScale;
	C.Font = LabelFont;
	C.TextSize(DisplayText,TextW,TextH);

	// Set box width/height to our text width/height + padding
	BoxW = TextW + TextPadding;
	BoxH = TextH + TextPadding;

	// Set box position based on Width/Height & Canvas size
	BoxX = (C.SizeX - BoxW) * 0.5 + XPos;
	BoxY = (TextPadding * 0.5) + YPos;

	// Make sure box position isn't negative
	BoxX = FClamp(BoxX,0.0,99999.0);
	BoxY = FClamp(BoxY,0.0,99999.0);

	// If box X position is off screen, push it back in
	if ( (BoxX + BoxW) > C.SizeX )
	{
		BoxX = C.SizeX - BoxW;
	}

	// If box X position is off screen, push it back in
	if ( (BoxY + BoxH) > C.SizeY )
	{
		BoxY = C.SizeY - BoxH;
	}

	// Set box position
	C.SetPos(BoxX,BoxY);
	// Draw our background
	C.DrawTile(Background,BoxW,BoxH,0,0,1,1);

	// Get text position based on text & box size
	TextX = BoxX + (BoxW - TextW) * 0.5;
	TextY = BoxY + (TextPadding * 0.5);

	// Make sure text position isn't negative
	TextX = FClamp(TextX,0.0,99999.0);
	TextY = FClamp(TextY,0.0,99999.0);

	// If text X position is off screen, push it back in (maybe I should change this to use box size and not canvas?)
	if ( (TextX + TextW ) > C.SizeX )
	{
		TextX = C.SizeX - TextW;
	}

	// If text Y position is off screen, push it back in
	if ( ( TextY + TextH ) > C.SizeY )
	{
		TextY = C.SizeY - TextH;
	}

	// Set text position
	C.SetPos(TextX,TextY);
	// Draw text
	C.DrawText(DisplayText);
}

defaultproperties
{
	SizeScale=2.0
	TextPadding=16.0
	LabelOpacity=0.5
	LabelTexture=Texture'leftPanel'
}