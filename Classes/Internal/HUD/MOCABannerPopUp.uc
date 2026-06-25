//=============================================================================
// MOCABannerPopUp.
//=============================================================================
class MOCABannerPopUp extends MOCAPopUp;

const BANPCT_THRESHOLD = 0.75;

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

//= Misc Vars =//
var float Duration;
var float CurrentTime;


//=================
// Events
//=================

event Tick(float DeltaTime)
{
	CurrentTime += DeltaTime;

	CurFade = CalculateFade();
	CurBlinkFade = CalculateBlink(DeltaTime);
}

event Destroyed()
{
	OwningTrigger.PopUp = None;
	Super.Destroyed();
}


//=================
// Canvas Drawing
//=================

function Draw(Canvas C)
{
	local float BanX, BanY;
	local float BanW, BanH;
	local float LineW, LineH;
	local float ScaleX, ScaleY;

	local Vector2 Ratios;
	local Vector2 Margins;

	local array<string> Lines;
	local int i;

	local Texture Background;

	local float MaxLineW;
	local float MaxAllowedW;
	local float TextBlockH;
	local float MsgY;
	local float StartY;

	local float OldFS;
	local Font OldFont;

	Ratios = GetScreenRatio(C);
	Margins = GetScreenMargin(Ratios);

	ScaleX = Ratios.X;
	ScaleY = Ratios.Y;

	OldFS = C.FontScale;
	OldFont = C.Font;

	C.Font = TextFont;
	C.FontScale = FClamp(FontScale * ScaleX, 0.05, FontScale);

	WrapText(
		C,
		Text,
		BANPCT_THRESHOLD,
		BoxMargin,
		Lines
	);

	MaxLineW = 0;
	BanH = BoxMargin * 2.0;

	for (i = 0; i < Lines.Length; i++)
	{
		C.TextSize(Lines[i], LineW, LineH);

		if (LineW > MaxLineW)
			MaxLineW = LineW;

		BanH += LineH;
	}

	MaxAllowedW = C.SizeX * BANPCT_THRESHOLD;

	BanW = MaxLineW + (BoxMargin * 2.0);
	BanW = FMin(BanW, MaxAllowedW);

	GetBannerPosition(
		C,
		BanW,
		BanH,
		Margins,
		HAlignment,
		VAlignment,
		BanX,
		BanY
	);

	Background = BannerTexture;

	Background.Alpha = BannerOpacity * CurFade * CurBlinkFade;
	Background.bTransparent = (Background.Alpha < 1.0);

	C.SetPos(BanX, BanY);
	C.DrawTile(
		Background,
		BanW,
		BanH,
		0,
		0,
		Background.USize,
		Background.VSize
	);

	TextBlockH = BanH - (BoxMargin * 2.0);
	StartY = BanY + (BanH * 0.5) - (TextBlockH * 0.5);

	MsgY = StartY;

	for (i = 0; i < Lines.Length; i++)
	{
		C.TextSize(Lines[i], LineW, LineH);

		C.SetPos(
			BanX + (BanW * 0.5) - (LineW * 0.5),
			MsgY
		);

		C.DrawText(Lines[i]);

		MsgY += LineH;
	}

	C.Font = OldFont;
	C.FontScale = OldFS;
}

function WrapText(
	Canvas C,
	string InText,
	float MaxPct,
	float BoxMarginPx,
	out array<string> Lines
)
{
	local float LineW, LineH;
	local float MaxWidth;

	local string Remaining;
	local string Word;
	local string TestLine;
	local string CurrentLine;
	local string CharChunk;

	local int SpacePos;
	local int i;

	Lines.Length = 0;

	MaxWidth = (C.SizeX * MaxPct) - (BoxMarginPx * 2.0);
	Remaining = InText;

	while (Remaining != "")
	{
		SpacePos = InStr(Remaining, " ");

		if (SpacePos == -1)
		{
			Word = Remaining;
			Remaining = "";
		}
		else
		{
			Word = Left(Remaining, SpacePos);
			Remaining = Mid(Remaining, SpacePos + 1);
		}

		C.TextSize(Word, LineW, LineH);

		if (LineW > MaxWidth)
		{
			for (i = 0; i < Len(Word); i++)
			{
				CharChunk = Mid(Word, i, 1);

				if (CurrentLine == "")
					TestLine = CharChunk;
				else
					TestLine = CurrentLine $ CharChunk;

				C.TextSize(TestLine, LineW, LineH);

				if (LineW > MaxWidth && CurrentLine != "")
				{
					Lines[Lines.Length] = CurrentLine;
					CurrentLine = CharChunk;
				}
				else
				{
					CurrentLine = TestLine;
				}
			}

			continue;
		}

		if (CurrentLine == "")
			TestLine = Word;
		else
			TestLine = CurrentLine $ " " $ Word;

		C.TextSize(TestLine, LineW, LineH);

		if (LineW > MaxWidth && CurrentLine != "")
		{
			Lines[Lines.Length] = CurrentLine;
			CurrentLine = Word;
		}
		else
		{
			CurrentLine = TestLine;
		}
	}

	if (CurrentLine != "")
		Lines[Lines.Length] = CurrentLine;
}

function GetBannerPosition(
	Canvas C,
	float BanW,
	float BanH,
	Vector2 Margins,
	MOCABannerPopUpTrigger.EHoriAlign HAlign,
	MOCABannerPopUpTrigger.EVertAlign VAlign,
	out float BanX,
	out float BanY
)
{
	switch (HAlign)
	{
		case HA_Left:
			BanX = Margins.X;
			break;

		case HA_Right:
			BanX = C.SizeX - BanW - Margins.X;
			break;

		default:
			BanX = (C.SizeX - BanW) * 0.5;
			break;
	}

	switch (VAlign)
	{
		case VA_Center:
			BanY = (C.SizeY - BanH) * 0.5;
			break;

		case VA_Bottom:
			BanY = C.SizeY - BanH - Margins.Y;
			break;

		default:
			BanY = Margins.Y;
			break;
	}
}


//======================
// Fade/Blink Handling
//======================

function float CalculateFade()
{
	local float InW, OutW;

	InW = CurrentTime / FadeIn;
	OutW = (LifeSpan - CurrentTime) / FadeOut;

	return FClamp(Min(InW, OutW), 0.0, 1.0);
}

function float CalculateBlink(float DeltaTime)
{
	local float Alpha;

	if (BlinkStart >= 0 && CurrentTime >= BlinkStart)
	{
		CurBlinkTime += DeltaTime;

		Alpha = (Sin(CurBlinkTime * BlinkFreq * (2 * Pi)) + 1.0) * 0.5;

		return BlinkMinFade + Alpha * (1.0 - BlinkMinFade);
	}

	return 1.0;
}


//======================
// Setters
//======================

function SetTextProperties(string Message, Font MessageFont, Texture BannerTex)
{
	Text = Message;
	TextFont = MessageFont;
	BannerTexture = BannerTex;

	if (TextFont == None)
		TextFont = baseConsole(PlayerHarry.Player.Console).LocalBigFont;

	if (BannerTexture == None)
		BannerTexture = Texture'leftPanel';
}

function SetSizeProperties(float FontScaleMult, float BoxMarginPx, float ScreenMarginPx)
{
	FontScale = FontScaleMult;
	BoxMargin = BoxMarginPx;
	ScreenMargin = ScreenMarginPx;
}

function SetAlignProperties(
	MOCABannerPopUpTrigger.EHoriAlign HorizontalAlignment,
	MOCABannerPopUpTrigger.EVertAlign VerticalAlignment
)
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


//======================
// Screen Helpers
//======================

function Vector2 GetScreenRatio(Canvas C)
{
	local Vector2 R;

	R.X = C.SizeX / BASE_X;
	R.Y = C.SizeY / BASE_Y;

	return R;
}

function Vector2 GetScreenMargin(Vector2 Ratios)
{
	local Vector2 M;

	M.X = ScreenMargin * Ratios.X;
	M.Y = ScreenMargin * Ratios.Y;

	return M;
}