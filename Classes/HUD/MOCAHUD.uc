class MOCAHUD extends HPHud;

var MOCAharry HarryMoca;

var bool isLoading;

var Texture LoadingImg;

event PostBeginPlay()
{
    super.PostBeginPlay();
    HarryMoca = MOCAharry(Level.PlayerHarryActor);
}

function SetLoading(Texture LoadingImage, string MapName, optional float LoadDelay)
{
	local MOCAPauseTimer PauseTicker;
    
	PauseTicker = Spawn(class'MOCAPauseTimer');
	PauseTicker.ActionToDo = PauseTicker.ActionMode.AM_LoadLevel;
	PauseTicker.NewMap = MapName;
	PauseTicker.LoadingScreenImage = LoadingImage;
	PauseTicker.TimerLength = LoadDelay;
	PauseTicker.PauseMessage = "";

	LoadingImg = LoadingImage;
	isLoading = true;

	PauseTicker.Activate(self,HarryMoca);
}

function ShowDelayedScreen(Canvas C) 
{
    local float HScale;
    local float fScaleFactor;
    local float Offset;
    local int xOffset;

    C.SetPos(0, 0);

	C.SetPos(0,0);
	C.DrawTileClipped(Texture'HGame.FEBook.FEMapBack', C.SizeX, C.SizeY, 0.0, 0.0, C.SizeX * 2.5, C.SizeY * 2.5);

    HScale = HPConsole(HarryMoca.Player.Console).GetHScale(C);
    fScaleFactor = (C.SizeX / 640.0) * HScale;

    C.Style = 1;

    Offset = (128.0 / HScale) - (128.0 * HScale);

    HPConsole(HarryMoca.Player.Console).AlignXToCenter(C, xOffset);
    C.SetPos(xOffset, 0);

    C.DrawIcon(LoadingImg, fScaleFactor);

    Offset *= HPConsole(HarryMoca.Player.Console).Root.GUIScale * 0.7;
}

function PostRender(Canvas C)
{
    super.PostRender(C);

    if (isLoading)
    {
        ShowDelayedScreen(C);
    }
}