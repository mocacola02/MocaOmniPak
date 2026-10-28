class MOCABaseCam extends BaseCam;

var Texture CrosshairTexture;

event RenderOverlays(Canvas C)
{
    Super.RenderOverlays(C);

    if ( CrosshairTexture != None )
    {
        local float HScale, TexScale;
        HScale = Class'M212HScale'.Static.CanvasGetHeightScale(C);
        TexScale = CrosshairTexture.USize * HScale * 0.25;

        local float CenterX, CenterY;
        CenterX = C.SizeX * 0.5;
        CenterY = C.SizeY * 0.5;
        
        C.SetPos(CenterX, CenterY);
        C.DrawIcon(CrosshairTexture, TexScale);
    }
}

defaultproperties
{
}
