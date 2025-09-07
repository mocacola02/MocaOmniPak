class MOCAMusicComposerTrigger extends MOCATrigger;

enum ComposerCommand
{
    CC_Start,
    CC_RequestProgress,
    CC_Progress,
    CC_Stop
};

var() ComposerCommand CommandToSend;    //Moca: What command to send? Start will reset and start the composer, Request Progress will try to sync progression based on CheckRate, Progress will force-progress songs, Stop will stop the composer. Def: CC_Start
var() int SongOverride;                 //Moca: Override what song to start at. -1 or lower means disabled. Def: -1
var() float StopFadeTime;               //Moca: How long to fade out for when CC_Stop is sent. Def: 1.0
var MOCAMusicComposer Composer;

event Activate(actor Other, pawn Instigator)
{
    ProcessTrigger();
}

function ProcessTrigger()
{
    local MOCAMusicComposer A;
    
    foreach AllActors(class'MOCAMusicComposer', A, Event)
    {
        switch (CommandToSend)
        {
            case CC_Start: A.BeginComposing(SongOverride);  break;
            case CC_RequestProgress: A.ReadyUp(SongOverride);   break;
            case CC_Progress: A.ProgressSongs(SongOverride);    break;
            case CC_Stop: A.StopComposing(StopFadeTime);    break;
            default: A.StopComposing(StopFadeTime);     break;
        }
    }
}

defaultproperties
{
    SongOverride=-1
    StopFadeTime=1.0
    bTriggerOnceOnly=True
}