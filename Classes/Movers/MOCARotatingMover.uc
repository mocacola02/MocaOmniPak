class MOCARotatingMover extends RotatingMover;

// DELETEME : This is a rush job for the museum map.

function BeginPlay()
{
	Super.BeginPlay();
	
	Enable( 'Tick' );
}

function DoOpen()
{
    Super.DoOpen();
    Enable('Tick'); // force it back on
}

function DoClose()
{
    Super.DoClose();
    Enable('Tick'); // keep spinning even after close
}
