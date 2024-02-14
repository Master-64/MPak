// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************
// 
// A custom crosshair that can be easily configured through the
// use of the console commands provided in MController (Crosshair)


class MSelectCursor extends SelectCursor
	Config(MPak);


defaultproperties
{
	Texture=Texture'Shrek2_EFX.Gen_Particle.crosshair_tx'	// While not by default assigned anywhere, this is the crosshair that would've been used
	CollisionRadius=5.0										// The default in-game value is 5.0
	CollisionHeight=5.0										// The default in-game value is 5.0
	fLOS_Distance=1500.0									// The maximum distance the crosshair will go. The default in-game value is 1500.0
	Style=STY_Additive										// The game does not assign this by default, but makes the crosshair properly display
}