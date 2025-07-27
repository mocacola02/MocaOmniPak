class MOCATriggerChangeLevel extends TriggerChangeLevel;

var() Texture LoadingScreenImage;
var() string LoadingText;

function ProcessTrigger()
{
  local harry PlayerHarry;
  local Canvas C;

  PlayerHarry = harry(Level.PlayerHarryActor);
  HPConsole(PlayerHarry.Player.Console).LoadingBackground = LoadingScreenImage;
  if ( PlayerHarry == None )
  {
    Log("TriggerChangeLevel: Couldn't find Harry, and that ain't right!");
    return;
  }
  PlayerHarry.LoadLevel(NewMapName);
  if ( InStr(Caps(NewMapName),"STARTUP") > -1 )
  {
    HPConsole(PlayerHarry.Player.Console).menuBook.bGamePlaying = False;
    HPConsole(PlayerHarry.Player.Console).DrawLevelAction(C);
    HPConsole(PlayerHarry.Player.Console).menuBook.OpenBook("Main");
    HPConsole(PlayerHarry.Player.Console).LaunchUWindow();
  }
}

defaultproperties
{
     LoadingScreenImage=Texture'HGame.LoadingScreen.FELoadingScreen'
     LoadingText="Loading Game"
}
