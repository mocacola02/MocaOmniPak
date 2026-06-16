//=============================================================================
// MOCABannerPopUp.
//=============================================================================
class MOCABannerPopUp extends MOCAPopUp;

//= Text Vars =//
var string Text;
var Font TextFont;

//= Banner Visual Vars =//
var float BannerOpacity;
var Texture BannerTexture;

//= Size & Align Vars =//
var float FontScale, BoxMargin, ScreenMargin;
var MOCABannerPopUpTrigger.EHoriAlign HAlignment;
var MOCABannerPopUpTrigger.EVertAlign VAlignment;

//= Blink Vars =//
var float BlinkStart, BlinkFreq, BlinkMinFade;
var float CurBlinkTime, CurBlinkFade;

//= Fade Vars =//
var float FadeIn, FadeOut;
var float CurFade;

//= Actor Ref Vars =//
var MOCABannerPopUpTrigger OwningTrigger;

//= Misc. Vars =//
var float CurrentTime;


//===================
// Canvas Rendering
//===================

function Draw(Canvas C)
{
	local float BanX, BanY, BanW, BanH;
	local float MsgX, MsgY, MsgW, MsgH;
	local Vector TempPos;
	local Texture Background;

	Background = BannerTexture;
	Background.Alpha = BannerOpacity * CurFade * CurBlinkFade;
	Background.bTransparent = Background.Alpha < 1.0;

	C.Font = TextFont;
	C.FontScale = FontScale;
	C.TextSize(Text, MsgW, MsgH);

	BanW = MsgW + BoxMargin;
	BanH = MsgH + BoxMargin;

	GetBannerPosition(C.SizeX, C.SizeY, BanW, BanH, BanX, BanY);
	C.SetPos(BanX, BanW);
	C.DrawTile(Background, BanW, BanH, 0.0, 0.0, Background.USize, Background.VSize);

	GetTextPosition(BanW, BanH, MsgW, MsgH, MsgX, MsgY);
	C.SetPos(MsgX, MsgY);
	C.DrawText(Text);
}


//================
// Fade Handling
//================

event Tick(float DeltaTime)
{
	CurrentTime += DeltaTime;

	CurFade = CalculateFade(DeltaTime);
	CurBlinkFade = CalculateBlink(DeltaTime);
}

function float CalculateFade(float DeltaTime)
{
	local float FadeWeight, InWeight, OutWeight;

	InWeight = CurrentTime / FadeIn;
	OutWeight = (LifeSpan - CurrentTime) / FadeOut;
	FadeWeight = Min(InWeight, OutWeight);
	return FClamp(FadeWeight, 0.0, 1.0);
}

function float CalculateBlink(float DeltaTime)
{
	local float Alpha;

	if ( BlinkStart >= 0.0 && CurrentTime >= BlinkStart )
	{
		CurBlinkTime += DeltaTime;
		Alpha = (Sin(CurBlinkTime * BlinkFreq * (2 * Pi)) + 1.0) * 0.5;
		return BlinkMinFade + Alpha * (1.0 - BlinkMinFade);
	}

	return 1.0;
}


//=================
// Setter Helpers
//=================

function SetTextProperties(string Message, Font MessageFont)
{
	Text = Message;
	TextFont = MessageFont;

	if ( TextFont == None )
	{
		TextFont = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
	}
}

function SetSizeProperties(float FontScaleMult, float BoxMarginPct, float ScreenMarginPct)
{
	FontScale =  FontScaleMult;
	BoxMargin = BoxMarginPct;
	ScreenMargin = ScreenMarginPct;
}

function SetAlignProperties(MOCABannerPopUpTrigger.EHoriAlign HorizontalAlignment, MOCABannerPopUpTrigger.EVertAlign VerticalAlignment)
{
	HAlignment = HorizontalAlignment;
	VAlignment = VerticalAlignment;
}

function SetFadeProperties(float PopUpOpacity, float FadeInTime, float FadeOutTime)
{
	BannerOpacity = PopUpOpacity;
	FadeIn = FadeInTime;
	FadeOut = FadeOutTime;
}

function SetBlinkProperties(float BlinkStartTime, float BlinkFrequency, float BlinkFade)
{
	BlinkStart = LifeSpan - BlinkStartTime;
	BlinkFreq = BlinkFrequency;
	BlinkMinFade = BlinkFade;
}


//=================
// Getter Helpers
//=================

function float GetScreenMargin(float CanvasSize)
{
	return CanvasSize * ScreenMargin;
}

function GetBannerPosition(float CanvW, float CanvH, float BanW, float BanH, out float X, out float Y)
{
	GetElementPosition(CanvW, CanvH, BanW, BanH, CanvW * ScreenMargin, CanvH * ScreenMargin, X, Y);
}

function GetTextPosition(float CanvW, float CanvH, float TextW, float TextH, out float X, out float Y)
{
	GetElementPosition(CanvW, CanvH, TextW, TextH, CanvW * BoxMargin, CanvH * BoxMargin, X, Y);
}

function GetElementPosition(float CanvW, float CanvH, float BanW, float BanH, float XMargin, float YMargin, out float X, out float Y)
{
	switch(HAlignment)
	{
		case HA_Left:
			X = XMargin;
		case HA_Right:
			X = CanvW - BanW - XMargin;
		default:
			X = (CanvW - BanW) * 0.5 + XMargin;
	}

	switch(VAlignment)
	{
		case VA_Center:
			Y = (CanvH - BanH) * 0.5;
		case VA_Bottom:
			Y = CanvH - (BanH + YMargin);
		default:
			Y = BanH + YMargin;
	}
}