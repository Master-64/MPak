// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************


class MShrekMouse extends MShrekCreature
	Config(MPak);


defaultproperties
{
	BlendOutLandingFrame=20.0
	SHHeroName=Mouse
	CameraSetStandard=(vLookAtOffset=(X=-30.0,Y=0.0,Z=45.0),fLookAtDistance=100.0,fLookAtHeight=30.0,fRotTightness=8.0,fRotSpeed=8.0,fMoveTightness=(X=25.0,Y=40.0,Z=40.0),fMoveSpeed=0.0,fMaxMouseDeltaX=190.0,fMaxMouseDeltaY=65.0,fMinPitch=-10000.0,fMaxPitch=10000.0)
	CameraSnapRotationPitch=-2500.0
	GroundRunSpeed=300.0
	GroundWalkSpeed=300.0
	BaseMovementRate=300.0
	_BaseMovementRate=300.0
	Mesh=SkeletalMesh'ShrekCharacters.Mouse'
	CollisionRadius=15.0
	CollisionHeight=13.0
	Label="Mouse"
}