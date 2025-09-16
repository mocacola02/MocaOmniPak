class MOCATriggerChangeLevel extends MOCATrigger;

var() Texture LoadingScreenImage;
var() float LoadDelay;
var() string NewMapName;

var HPConsole ConsoleRef;

function Activate ( actor Other, pawn Instigator )
{
    ProcessTrigger();
}

function ProcessTrigger()
{
	if (NewMapName != "")
	{
		if (PlayerHarry.IsA('MOCAharry') && LoadingScreenImage != Texture'HGame.LoadingScreen.FELoadingScreen')
		{
			ConsoleRef = HPConsole(PlayerHarry.Player.Console);

			if (ConsoleRef == None)
			{
				return;
			}

			local MOCAharry PlayerMoca;
			local MOCAHUD MocaHudRef;

			PlayerMoca = MOCAharry(PlayerHarry);
			MocaHudRef = PlayerMoca.GetMocaHud();

			ConsoleRef.LoadingBackground = LoadingScreenImage;
			MocaHudRef.SetLoading(LoadingScreenImage, NewMapName, LoadDelay);
		}
		else
		{
			ConsoleRef.LoadingBackground = LoadingScreenImage;
			PlayerHarry.LoadLevel(NewMapName);
		}
	}
	else
	{
		Log("No map name is set! Trigger can't change level, please fix this in your map!");
	}
}

defaultproperties
{
     LoadingScreenImage=Texture'HGame.LoadingScreen.FELoadingScreen'
     LoadDelay=0.0
	 NewMapName="Entryhall_hub"
}
