// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************


class MMovieManager extends MInfo
	Config(MPak);


var() array<string> MovieList;
var() vector vFallbackResolution;
var() name nEventToFireWhenFinished;
var() bool bStopMusicDuringMovies, bPickRandom, bKeepHUDHiddenAfterMovies;
var() float fMusicFadeTime;
var int iCurrentMovieIndex;
var string sOldMusic;
var bool bCanBeTriggered;


function Trigger(Actor Other, Pawn EventInstigator)
{
	if(!bCanBeTriggered)
	{
		return;
	}
	
	bCanBeTriggered = false;
	
	BeginNextMovie();
}

function BeginNextMovie()
{
	local vector vRes;
	local string sResVars;
	
	PC = U.GetPC();
	HUD = U.GetHUD();
	HUD.bHideHUD = true;
	
	if(bStopMusicDuringMovies && iCurrentMovieIndex == 0)
	{
		U.StopAMusic(fMusicFadeTime);
		
		sOldMusic = U.GetCurrentMusic();
	}
	
	if(bPickRandom)
	{
		iCurrentMovieIndex = Rand(MovieList.Length);
	}
	
	if(iCurrentMovieIndex > MovieList.Length)
	{
		StopPlayingMovies();
		
		return;
	}
	
	vRes = U.GetResolution();
	
	sResVars = "$" $ U.FloatToString(vRes.X) $ "x" $ U.FloatToString(vRes.Y);
	
	if(vFallbackResolution != default.vFallbackResolution)
	{
		if(!U.DoesFileExist("..\\Movies\\" $ MovieList[iCurrentMovieIndex] $ sResVars))
		{
			sResVars = "$" $ U.FloatToString(vFallbackResolution.X) $ "x" $ U.FloatToString(vFallbackResolution.Y);
		}
	}
	
	U.PlayMovie(MovieList[iCurrentMovieIndex] $ sResVars, true);
	
	GotoState('PlayMovie');
}

function StopPlayingMovies()
{
	HUD = U.GetHUD();
	HUD.bHideHUD = bKeepHUDHiddenAfterMovies;
	
	GotoState('');
	
	if(bStopMusicDuringMovies)
	{
		U.PlayAMusic(sOldMusic, fMusicFadeTime);
	}
	
	if(nEventToFireWhenFinished != 'None')
	{
		TriggerEvent(nEventToFireWhenFinished, none, none);
	}
	
	bCanBeTriggered = true;
}

state PlayMovie
{
	event Tick(float DeltaTime)
	{
		if(!U.IsMoviePlaying())
		{
			if(!bPickRandom)
			{
				iCurrentMovieIndex++;
				
				BeginNextMovie();
			}
			else
			{
				StopPlayingMovies();
				
				GotoState('');
			}
		}
	}
}


defaultproperties
{
	bCanBeTriggered=true
	fMusicFadeTime=1.0
}