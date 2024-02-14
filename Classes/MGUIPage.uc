// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************
// 
// A general fork of a GUI page


class MGUIPage extends SHGUIPage
	Config(MPak);


var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var array<KWHudItem> HudItems;
var BaseCam Cam;
var MUtils U;


function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	U = GetUtils(MyController);
	
	super.InitComponent(MyController, MyOwner);
}

function MUtils GetUtils(GUIController C)
{
	local MUtils Ut;
	
	foreach C.ViewportOwner.Actor.DynamicActors(class'MUtils', Ut)
	{
		return Ut;
	}
	
	return C.ViewportOwner.Actor.Spawn(class'MUtils');
}

function bool InternalOnClick(GUIComponent Sender)
{
	super.InternalOnClick(Sender);
	
	return true;
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
	if(Key == 27 && State == 1)
	{
		ClosePage();
	}
	
	return false;
}

function GUIComponent CenterComponent(GUIComponent GUIC)
{
	GUIC.WinTop -= GUIC.WinHeight / 2.0;
	GUIC.WinLeft -= GUIC.WinWidth / 2.0;
	
	return GUIC;
}

function ClosePage()
{
	UnPause();
	Controller.CloseAll(false);
}


defaultproperties
{
	WinHeight=1.0
}