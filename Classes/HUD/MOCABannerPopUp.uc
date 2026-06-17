//=============================================================================
// MOCABannerPopUp.
//=============================================================================
class MOCABannerPopUp extends MOCAPopUp;

const BASE_X = 1024.0;
const BASE_Y = 768.0;

struct Vector2
{
	var float X;
	var float Y;
};

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
var float Duration;
var float CurrentTime;


//=========
// Events
//=========

event Tick(float DeltaTime)
{
	CurrentTime += DeltaTime;

	CurFade = CalculateFade(DeltaTime);
	CurBlinkFade = CalculateBlink(DeltaTime);
}

event Destroyed()
{
	OwningTrigger.PopUp = None;
	super.Destroyed();
}


//===================
// Canvas Rendering
//===================

function Draw(Canvas C)
{
	local float BanX, BanY, BanW, BanH;
	local float MsgX, MsgY, MsgW, MsgH;
	local Vector2 Ratios;
	local Vector2 Margins;
	local Texture Background;

	Background = BannerTexture;
	Background.Alpha = BannerOpacity * CurFade * CurBlinkFade;
	Background.bTransparent = Background.Alpha < 1.0;

	Ratios = GetScreenRatio(C);

	C.Font = TextFont;
	C.FontScale = FClamp(FontScale * Ratios.X, 0.05, FontScale);
	C.TextSize(Text, MsgW, MsgH);

	BanW = MsgW + (BoxMargin * 2.0);
	BanW *= Ratios.X;
	BanH = MsgH + (BoxMargin * 2.0);
	BanH *= Ratios.Y;

	Margins = GetScreenMargin(Ratios);

	switch(HAlignment)
	{
		case HA_Left:
			BanX = Margins.X;
		case HA_Right:
			BanX = C.SizeX - BanW - Margins.X;
		default:
			BanX = (C.SizeX - BanW) * 0.5;
	}

	switch(VAlignment)
	{
		case VA_Center:
			BanY = (C.SizeY - BanH) * 0.5;
			break;

		case VA_Bottom:
			BanY = C.SizeY - BanH - Margins.Y;
			break;

		default: // VA_Top or fallback
			BanY = Margins.Y;
			break;
	}

	C.SetPos(BanX, BanY);
	C.DrawTile(Background, BanW, BanH, 0.0, 0.0, Background.USize, Background.VSize);

	MsgX = BanX + (BanW * 0.5) - (MsgW * 0.5);
	MsgY = BanY + (BanH * 0.5) - (MsgH * 0.5);
	C.SetPos(MsgX, MsgY);
	C.DrawText(Text);
}


//================
// Fade Handling
//================

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

function SetTextProperties(string Message, Font MessageFont, Texture BannerTex)
{
	Text = Message;
	TextFont = MessageFont;
	BannerTexture = BannerTex;

	if ( TextFont == None )
	{
		TextFont = baseConsole(PlayerHarry.Player.Console).LocalBigFont;
	}

	if ( BannerTexture == None )
	{
		BannerTexture = Texture'leftPanel';
	}
}

function SetSizeProperties(float FontScaleMult, float BoxMarginPx, float ScreenMarginPx)
{
	FontScale =  FontScaleMult;
	BoxMargin = BoxMarginPx;
	ScreenMargin = ScreenMarginPx;
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

function Vector2 GetScreenRatio(Canvas C)
{
	local Vector2 Ratios;
	Ratios.X = C.SizeX / BASE_X;
	Ratios.Y = C.SizeY / BASE_Y;
	return Ratios;
}

function Vector2 GetScreenMargin(Vector2 Ratios)
{
	local Vector2 Margins;
	Margins.X = ScreenMargin * Ratios.X;
	Margins.Y = ScreenMargin * Ratios.Y;
	return Margins;
}