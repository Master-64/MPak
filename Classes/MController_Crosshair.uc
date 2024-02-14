// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************


class MController_Crosshair extends MController
	Config(User);


exec function SetCrosshairVisibility(bool B) // Sets the visibility of the crosshair. True is visible and false is invisible
{
	if(Cursor != none)
	{
		if(B)
		{
			Cursor.SetDrawType(DT_Sprite);
		}
		else
		{
			Cursor.SetDrawType(DT_None);
		}
	}
}

exec function SetCrosshairDistance(float F) // Sets the maximum distance of the crosshair. Default is 1500.0
{
	if(Cursor != none)
	{
		Cursor.SetLOSDistance(F);
	}
}


// Command Aliases

exec function SCV(bool B) // SetCrosshairVisibility
{
	SetCrosshairVisibility(B);
}

exec function SCD(float F) // SetCrosshairDistance
{
	SetCrosshairDistance(F);
}


defaultproperties
{
	DefaultSelectCursorType=class'MSelectCursor'
}