//================================================================================
// Essence_fx.
//================================================================================

class Essence_fx extends ParticleFX;

struct RandomColor
{
    var() config byte R, G, B, A;
};

var RandomColor MyRandomColor;

//texture package import -AdamJD
#exec OBJ LOAD FILE=..\Textures\HP_FX.utx 		Package=HPParticle.hp_fx

event PostBeginPlay()
{
    Super.PostBeginPlay();
    RandomizeColor();
}

function RandomizeColor()
{
    local byte R;
    local byte G;
    local byte B;

    // Loop until a suitable color is generated
    do
    {
        // Generate random color values for R, G, and B
        R = Rand(256);
        G = Rand(256);
        B = Rand(256);

        // Check if the color is too dark (you can adjust the threshold as needed)
        if ((R + G + B) / 3 < 200)
        {
            // If too dark, regenerate color values
            continue;
        }

        // If the color passes the darkness check, set the values in MyRandomColor
        MyRandomColor.R = R;
        MyRandomColor.G = G;
        MyRandomColor.B = B;
        MyRandomColor.A = 255; // Set alpha to maximum for full opacity
        // Log the generated color
        log("Generated color: R=" $ string(MyRandomColor.R) 
            $ ", G=" $ string(MyRandomColor.G) 
            $ ", B=" $ string(MyRandomColor.B) 
            $ ", A=" $ string(MyRandomColor.A)); // Add this line for debugging
        // Break out of the loop since a suitable color has been generated
        break;
    } until (true);
}

defaultproperties
{
    ParticlesPerSec=(Base=32.00,Rand=46.00)

    SourceWidth=(Base=2.00,Rand=0.00)

    SourceHeight=(Base=2.00,Rand=0.00)

    SourceDepth=(Base=20.00,Rand=0.00)

    AngularSpreadWidth=(Base=180.00,Rand=0.00)

    AngularSpreadHeight=(Base=180.00,Rand=0.00)

    bSteadyState=True

    Speed=(Base=2.00,Rand=16.00)

    Lifetime=(Base=0.50,Rand=1.00)

    ColorStart=(Base=(R=MyRandomColor.R,G=MyRandomColor.G,B=MyRandomColor.B,A=255),Rand=(R=0,G=0,B=0,A=0))

    ColorEnd=(Base=(R=MyRandomColor.R,G=MyRandomColor.G,B=MyRandomColor.B,A=255),Rand=(R=0,G=0,B=0,A=0))

    SizeWidth=(Base=16.00,Rand=24.00)

    SizeLength=(Base=16.00,Rand=24.00)

    SizeEndScale=(Base=0.00,Rand=0.00)

    SpinRate=(Base=-2.00,Rand=2.00)

    Chaos=5.00

    ChaosDelay=0.50

    Textures(0)=Texture'HPParticle.hp_fx.Particles.Sparkle_5'

    Rotation=(Pitch=-16352,Yaw=0,Roll=0)

    DesiredRotation=(Pitch=-16352,Yaw=0,Roll=0)
}