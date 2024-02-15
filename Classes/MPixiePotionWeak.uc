// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************


class MPixiePotionWeak extends MSpecialStockPotions
	Config(MPak);


function PostPickupLogic(Actor Other)
{
	PC = U.GetPC();
	
	if(PC.IsA('ShrekController') && U.GetHP() == Other)
	{
		ShrekController(PC).PickUpOwnedInventoryItem(class'PixiePotionWeak');
	}
}


defaultproperties
{
	InventoryTypes(0)=class'MicePotionWeakCollection'
	Event=PixiePotionWeakPickup
	StaticMesh=StaticMesh'Shrek2_Univ_SM.pixie_potion'
	DrawScale=0.66
	CollisionRadius=10.0
	CollisionHeight=14.0
}