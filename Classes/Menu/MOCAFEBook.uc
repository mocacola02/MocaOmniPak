//================================================================================
// MOCAFEBook.
//================================================================================

class MOCAFEBook extends FEBook;

var baseFEPage MCLoadingPage;

function Created()
{
	Super.Created();

	MCLoadingPage = FEInGamePage(CreateWindow(Class'FEInGamePage', 0.0, 0.0, WinWidth, WinHeight));
	MCLoadingPage.book = self;
	MCLoadingPage.HideWindow();
	
	MCLoadingPage.ResolutionChanged(Root.RealWidth, Root.RealHeight);
	
	MCLoadingPage.RepositionChildControls();
}

function ChangePageNamed (string Name)
{
	switch (Caps(Name))
	{
		case "MAIN":
			ChangePage(MainPage);
			break;
		case "INPUT":
			Log("changepagenamed input");
			ChangePage(InputPage);
			break;
		case "SOUNDVIDEO":
			Log("changepagenamed soundvideo");
			ChangePage(SoundVideoPage);
			break;
		case "LANG":
		case "LANGUAGE":
			ChangePage(LangPage);
			break;
		case "INGAME":
			ChangePage(InGamePage);
			break;
		case "FOLIO":
			Log("changepagenamed folio");
			ChangePage(FolioPage);
			break;
		case "MAP":
			ChangePage(MapPage);
			break;
		case "QUID":
		case "QUIDDITCH":
			ChangePage(QuidPage);
			break;
		case "DUEL":
			ChangePage(DuelPage);
			break;
		case "HPOINTS":
			ChangePage(HousepointsPage);
			break;
		case "CHALLENGES":
			ChangePage(ChallengesPage);
			break;
		case "CREDITSPAGE":
			ChangePage(CreditsPage);
			break;
        case "LOADING":
            ChangePage(MCLoadingPage);
            break;
		default:
			Log("UnknownPage in FEBook: " $ Name);
			break;
	}
}