// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************


class MController_PlayerCanAirJump extends MController
	Config(User);


event PlayerTick(float DeltaTime)
{
	if(IsInState('PlayerWalking'))
	{
		GotoState('PlayerCanAirJump');
	}
	
	super.PlayerTick(DeltaTime);
}