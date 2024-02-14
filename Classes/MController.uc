// *****************************************************
// *		  Master Pack (MPak) by Master_64		   *
// *		  Copyrighted (c) Master_64, 2022		   *
// *   May be modified but not without proper credit!  *
// *	 https://master-64.itch.io/shrek-2-pc-mpak	   *
// *****************************************************


class MController extends ShrekController
	Config(User);


var float fAnnTime, fTimeAfterLoading, fPlayASoundVolume, fTeleportDist;
var byte AnnColorR, AnnColorG, AnnColorB;
var name NewState;
var bool bCanTPBack, bModifyHealthSFX, bModifyHealthKnockback, bTPBackOncePerTP;
var vector OldTPLoc;
var int iAirJumpCounter, iAirJumpMax, iTPRetryAttempts, iSummonRetryAttempts;
var KWHeroController PC;
var Pawn HP, ICP;
var KWHud HUD;
var array<KWHudItem> HudItems;
var BaseCam Cam;
var MUtils U;


event PostBeginPlay()
{
	super.PostBeginPlay();
	
	U = GetUtils();
	
	Log(class'MVersion'.default.ModName @ class'MVersion'.default.Version @ "-- A pawn is using Master's Controller, made by Master_64");
}

function MUtils GetUtils()
{
	local MUtils Ut;
	
	foreach DynamicActors(class'MUtils', Ut)
	{
		return Ut;
	}
	
	return Spawn(class'MUtils');
}

event OnEnginePreFirstTick(bool bLoadFromSaveGame) // Gets the time after loading, which allows for calculating a loadless time
{
	super.OnEnginePreFirstTick(bLoadFromSaveGame);
	
	fTimeAfterLoading = Level.TimeSeconds;
}

event PlayerTick(float DeltaTime) // A manual port of the PlayerTick() function that bridges the gap between controllers so that this function acts as intended
{
	local KWGame.EMaterialType MaterialType;
	
	if(Pawn == none)
	{
		return;
	}
	
	SHHeroPawn(Pawn).UseSHJumpMagnet();
	MaterialType = SHHeroPawn(Pawn).TraceMaterial(Pawn.Location, 1.5 * Pawn.CollisionHeight);
	
	if((MaterialType != MTYPE_Wet) && SHHeroPawn(Pawn).bInWater == true)
	{
		SHHeroPawn(Pawn).HeroOutOfWater();
	}
	
	if((MaterialType != MTYPE_QuickSand) && SHHeroPawn(Pawn).bInQuicksand == true)
	{
		SHHeroPawn(Pawn).HeroOutOfQuicksand();
	}
	
	if(MaterialType == MTYPE_QuickSand)
	{
		if(SHHeroPawn(Pawn).bInQuicksand != true)
		{
			SHHeroPawn(Pawn).HeroInQuicksand();
		}		
	}
	else if(MaterialType == MTYPE_Wet)
	{
		if(SHHeroPawn(Pawn).bInWater == false)
		{
			SHHeroPawn(Pawn).HeroInWater();
		}
	}
	
	CheckForCameraBlocking(DeltaTime);
	
	if(Pawn.CanDoubleJump() && bPressedJump)
	{
		Pawn.DoDoubleJump(false);
	}
	
	if((bFire == 1) && !bLastPressedFire)
	{
		KWPawn(Pawn).PressedFire();
	}
	
	if((bFire == 0) && bLastPressedFire)
	{
		if((Cursor != none) && Pawn != none)
		{
			Cursor.ReleasedFire();
			KWPawn(Pawn).ReleasedFire();
		}
	}
	
	if((bAltFire == 0) && bLastPressedAltFire)
	{
		if((Cursor != none) && Pawn != none)
		{
			Cursor.ReleasedAltFire();
			KWPawn(Pawn).ReleasedFire();
		}
	}
	
	bLastPressedFire = bFire != 0;
	bLastPressedAltFire = bAltFire != 0;
	
	super.PlayerTick(DeltaTime);
}

exec function MPakVersion()
{
	local float fSavedAnnTime;
	local byte SavedAnnColorR, SavedAnnColorG, SavedAnnColorB;
	
	fSavedAnnTime = fAnnTime;
	SavedAnnColorR = AnnColorR;
	SavedAnnColorG = AnnColorG;
	SavedAnnColorB = AnnColorB;
	
	fAnnTime = 6.4;
	AnnColorR = 0;
	AnnColorG = 255;
	AnnColorB = 0;
	
	Announce("The current MPak version is:" @ class'MVersion'.default.Version);
	U.CMAndLog("The current MPak version is:" @ class'MVersion'.default.Version);
	
	fAnnTime = fSavedAnnTime;
	AnnColorR = SavedAnnColorR;
	AnnColorG = SavedAnnColorG;
	AnnColorB = SavedAnnColorB;
}

exec function ReviewJumpSpots(name TestLabel) // It's unknown what this console command does
{
	switch(TestLabel)
	{
		case 'Transloc':
			TestLabel = 'Begin';
			
			break;
		case 'Jump':
			TestLabel = 'Finished';
			
			break;
		case 'Combo':
			TestLabel = 'FinishedJumping';
			
			break;
		case 'LowGrav':
			TestLabel = 'FinishedComboJumping';
			
			break;
		default:
			break;
	}
	
	U.CMAndLog("TestLabel is " $ string(TestLabel));
	Level.Game.ReviewJumpSpots(TestLabel);
}

exec function ListStaticActors()
{
	local Actor A;
	local int i;
	
	foreach AllActors(class'Actor', A)
	{
		if(A.bStatic == true)
		{
			i++;
			
			Log(string(i) @ string(A));
		}
	}
	
	U.CMAndLog("Num static actors:" @ string(i));
}

exec function ListDynamicActors()
{
	local Actor A;
	local int i;
	
	foreach DynamicActors(class'Actor', A)
	{
		i++;
		
		Log(string(i) @ string(A));
	}
	
	U.CMAndLog("Num dynamic actors:" @ string(i));
}

exec function FreezeFrame(float Delay)
{
	Level.Game.SetPause(true, self);
	Level.PauseDelay = Level.TimeSeconds + Delay;
}

exec function WriteToLog()
{
	U.CMAndLog("NOW!");
}

exec function SetFlash(float F)
{
	FlashScale.X = F;
}

exec function KillViewedActor()
{
	if(ViewTarget != none)
	{
		if((Pawn(ViewTarget) != none) && (Pawn(ViewTarget).Controller != none))
		{
			U.FancyDestroy(Pawn(ViewTarget).Controller);
		}
		
		U.FancyDestroy(ViewTarget);
		SetViewTarget(none);
	}
}

exec function LogScriptedSequences()
{
	local AIScript S;
	
	foreach AllActors(class'AIScript', S)
	{
		S.bLoggingEnabled =	!S.bLoggingEnabled;
	}
}

exec function Teleport()
{
	local Actor HitActor;
	local vector HitNormal, HitLocation;
	
	HitActor = Trace(HitLocation, HitNormal, ViewTarget.Location + fTeleportDist * vector(Rotation), ViewTarget.Location, true);
	
	if(HitActor == None)
	{
		HitLocation = ViewTarget.Location + fTeleportDist * vector(Rotation);
	}
	else
	{
		HitLocation = HitLocation + ViewTarget.CollisionRadius * HitNormal;
	}
	
	U.MFancySetLocation(ViewTarget, HitLocation);
}

exec function ChangeSize(float F)
{
	if(Pawn.SetCollisionSize(Pawn.default.CollisionRadius * F, Pawn.default.CollisionHeight * F))
	{
		Pawn.SetDrawScale(F);
		U.MFancySetLocation(Pawn, Pawn.Location);
	}
}

exec function LockCamera()
{
	if(bUseBaseCam && Camera != none)
	{
		if(Camera.GetStateName() != 'StateMenuCam')
		{
			LastState = GetStateName();
			GotoState('StateNoPawnMove');
			Camera.SetCameraMode(Camera.GetModeFromString("MenuCam"));
		}
		else
		{
			GotoState(LastState);
			Camera.InitTarget(Pawn, 0.0, true);
		}
	}
}

exec function SetCameraDist(string S)
{
	local array<string> TokenArray;
	local BaseCam BC;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 1)
	{
		Warn("Master Controller (SetCameraDist) -- Missing arguments; aborting process");
		
		return;
	}
	
	foreach DynamicActors(class'BaseCam', BC)
	{
		BC.fDesiredLookAtDistance = float(TokenArray[0]);
		
		if(TokenArray.Length < 2)
		{
			return;
		}
		else if(bool(TokenArray[1]))
		{
			BC.fCurrLookAtDistance = float(TokenArray[0]);
		}
	}
}

exec function CauseEvent(name EventName)
{
	TriggerEvent(EventName, Pawn, Pawn);
}

exec function UnCauseEvent(name EventName)
{
	UnTriggerEvent(EventName, Pawn, Pawn);
}

exec function Amphibious()
{
	Pawn.UnderWaterTime = U.GetMaxFloat();
}

exec function Fly()
{
	Pawn.UnderWaterTime = Pawn.default.UnderWaterTime;
	U.CM("You feel much lighter");
	Pawn.SetCollision(true, true, true);
	Pawn.bCollideWorld = true;
	bCheatFlying = true;
	Pawn.bCanDoubleJump = false;
	GotoState('PlayerFlying');
}

exec function Ghost()
{
	if(!Pawn.IsA('Vehicle'))
	{
		Pawn.UnderWaterTime = -1.0;
		U.CM("You feel ethereal");
		Pawn.SetCollision(false, false, false);
		Pawn.bCollideWorld = false;
		bCheatFlying = true;
		Pawn.bCanDoubleJump = false;
		GotoState('PlayerFlying');
	}
	else
	{
		U.CMAndLog("Can't ghost in vehicles");
	}
}

exec function Walk()
{
	bCheatFlying = false;
	Pawn.UnderWaterTime = Pawn.default.UnderWaterTime;
	Pawn.SetCollision(true, true, true);
	Pawn.SetPhysics(PHYS_Walking);
	Pawn.bCollideWorld = true;
	Pawn.bCanDoubleJump = Pawn.default.bCanDoubleJump;
	ClientReStart();
}

exec function God(bool bGod)
{
	if(bGod)
	{
		bGodMode = true;
		SHHeroPawn(Pawn).AmInvunerable = true;
		U.CM("God mode on");
	}
	else
	{
		bGodMode = false;
		SHHeroPawn(Pawn).AmInvunerable = false;
		U.CM("God mode off");
	}
}

exec function SloMo(float F)
{
	Level.Game.SetGameSpeed(F);
}

exec function SloMoSave(float F)
{
	Level.Game.SetGameSpeed(F);
	Level.Game.SaveConfig();
	Level.Game.GameReplicationInfo.SaveConfig();
}

exec function SetPotions(int I)
{
	ICP = U.GetICP();
	
	KWPawn(ICP).AddToInventoryCollection(class'Potion1Collection', -KWPawn(ICP).GetInventoryCount('Potion1sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion1Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion2Collection', -KWPawn(ICP).GetInventoryCount('Potion2sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion2Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion3Collection', -KWPawn(ICP).GetInventoryCount('Potion3sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion3Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion4Collection', -KWPawn(ICP).GetInventoryCount('Potion4sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion4Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion5Collection', -KWPawn(ICP).GetInventoryCount('Potion5sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion5Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion6Collection', -KWPawn(ICP).GetInventoryCount('Potion6sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion6Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion7Collection', -KWPawn(ICP).GetInventoryCount('Potion7sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion7Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion8Collection', -KWPawn(ICP).GetInventoryCount('Potion8sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion8Collection', I);
	KWPawn(ICP).AddToInventoryCollection(class'Potion9Collection', -KWPawn(ICP).GetInventoryCount('Potion9sh'));
	KWPawn(ICP).AddToInventoryCollection(class'Potion9Collection', I);
}

exec function SetCoins(int I)
{
	ICP = U.GetICP();
	
	KWPawn(ICP).AddToInventoryCollection(class'CoinCollection', -KWPawn(ICP).GetInventoryCount('Coin'));
	KWPawn(ICP).AddToInventoryCollection(class'CoinCollection', I);
}

exec function SetHealth(float H)
{
	U.SetHealth(Pawn, H, bModifyHealthKnockback,, bModifyHealthSFX);
}

exec function AddHealth(float H)
{
	U.AddHealth(Pawn, H, bModifyHealthKnockback,, bModifyHealthSFX);
}

exec function SetShamrocks(int I)
{
	U.SetShamrocks(I,, true);
}

exec function AddShamrocks(int I)
{
	U.AddShamrocks(I,, true);
}

exec function SetJumpZ(string S)
{
	local array<string> TokenArray;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 1)
	{
		Warn("Master Controller (SetJumpZ) -- Missing arguments; aborting process");
		
		return;
	}
	
	if(TokenArray.Length > 1)
	{
		if(bool(TokenArray[1]))
		{
			if(Pawn.IsA('KWPawn'))
			{
				KWPawn(Pawn).DoubleJumpZ = float(TokenArray[0]);
			}
		}
		else
		{
			Pawn.JumpZ = float(TokenArray[0]);
		}
	}
	else
	{
		Pawn.JumpZ = float(TokenArray[0]);
	}
}

exec function SetGravity(float F)
{
	PhysicsVolume.Gravity.Z = F;
}

exec function SetSpeed(float F)
{
	if(Pawn.IsA('KWPawn'))
	{
		KWPawn(Pawn).GroundRunSpeed = F;
	}
}

exec function KillAll(class<Actor> aClass)
{
	local Actor A;
	
	if(ClassIsChildOf(aClass, class'AIController'))
	{
		Level.Game.KillBots(Level.Game.NumBots);
		
		return;
	}
	
	if(ClassIsChildOf(aClass, class'Pawn'))
	{
		KillAllPawns(class<Pawn>(aClass));
		
		return;
	}
	
	foreach AllActors(class'Actor', A)
	{
		if(ClassIsChildOf(A.Class, aClass))
		{
			U.FancyDestroy(A);
		}
	}
}

function KillAllPawns(class<Pawn> aClass)
{
	local Pawn P;
	
	Level.Game.KillBots(Level.Game.NumBots);
	
	foreach AllActors(class'Pawn', P)
	{
		if(ClassIsChildOf(P.Class, aClass) && !P.IsPlayerPawn())
		{
			U.FancyDestroy(P);
		}
	}
}

exec function KillPawns()
{
	KillAllPawns(class'Pawn');
}

exec function Avatar(string ClassName)
{
	local class<Actor> NewClass;
	local Pawn P;
	
	NewClass = class<Actor>(DynamicLoadObject(ClassName, class'Class'));
	
	foreach AllActors(class'Pawn', P)
	{
		if(P.Class == NewClass && P != Pawn)
		{
			if(Pawn.Controller != none)
			{
				Pawn.Controller.PawnDied(Pawn);
			}
			
			Possess(P);
		}
	}
}

exec function Summon(string S)
{
	local class<Actor> NewClass;
	local vector SpawnLoc;
	local Actor A;
	
	NewClass = U.GetClassByString(S);
	
	if(Pawn != none)
	{
		SpawnLoc = Pawn.Location;
	}
	else
	{
		SpawnLoc = Location;
	}
	
	if(!U.MFancySpawn(NewClass, SpawnLoc + 72.0 * vector(Rotation) + Vect(0.0, 0.0, 1.0) * 15.0, Rotation, A, iSummonRetryAttempts))
	{
		U.CM("Failed to spawn actor");
		
		return;
	}
	
	U.GivePawnController(KWPawn(A));
}

exec function PlayersOnly()
{
	Level.bPlayersOnly = !Level.bPlayersOnly;
}

exec function CheatView(class<Actor> aClass, optional bool bQuiet)
{
	ViewClass(aClass, bQuiet, true);
}

exec function FocusOn(optional class<Actor> aClass, optional bool bQuiet)
{
	local HUD H;
	
	foreach AllActors(class'HUD', H)
	{
		H.bShowDebugInfo = true;
		HUD.SetPropertyText("bPortalDebugView", "True");
	}
	
	if(aClass != none)
	{
		ViewClass(aClass, bQuiet);
	}
}

exec function FocusOff()
{
	local HUD H;
	
	foreach AllActors(class'HUD', H)
	{
		HUD.SetPropertyText("bPortalDebugView", "False");
	}
}

exec function RememberSpot()
{
	if(Pawn != none)
	{
		Destination = Pawn.Location;
	}
	else
	{
		Destination = Location;
	}
}

exec function ViewSelf(optional bool bQuiet)
{
	bBehindView = false;
	bViewBot = false;
	
	SetViewTarget(Pawn);
	
	if(!bQuiet)
	{
		U.CM(OwnCamera);
	}
	
	FixFOV();
}

exec function ViewActor(name ActorName)
{
	local Actor A;
	
	foreach AllActors(class'Actor', A)
	{
		if(A.Name == ActorName)
		{
			SetViewTarget(A);
			bBehindView = true;
			HandleViewTargetCam(ViewTarget);
			
			break;
		}
	}
}

exec function ViewTag(name TagName)
{
	local Actor A;
	
	foreach AllActors(class'Actor', A, TagName)
	{
		SetViewTarget(A);
		bBehindView = true;
		HandleViewTargetCam(ViewTarget);
		
		break;
	}
}

exec function ViewBot()
{
	local Actor first;
	local bool bFound;
	local Controller C;
	
	bViewBot = true;
	myHUD.bShowDebugInfo = true;
	myHUD.SetPropertyText("bDrawLines", "True");
	C = Level.ControllerList;
	
	if(C != none)
	{
		if(C.IsA('AIController') && (C.Pawn != none))
		{
			SetDebug(false);
			
			if(bFound || (first == none))
			{
				SetDebug(true);
				
				first = C.Pawn;
			}
			else
			{
				if((C.Pawn == ViewTarget) || (ViewTarget == none))
				{
					bFound = true;
				}
			}
		}
		
		C = C.nextController;
	}
	
	if(first != none)
	{
		SetViewTarget(first);
		bBehindView = true;
		CM("ALLRIGHT!!!");
		ViewTarget.BecomeViewTarget();
		FixFOV();
	}
	else
	{
		CM("DAMMIT!!!"); // Kids game by the way
		ViewSelf(true);
	}
}

function SetDebug(bool B) // Used in ViewBot to toggle debug mode
{
	local KWAIController KWAI;
	
	foreach DynamicActors(class'KWAIController', KWAI)
	{
		KWAI.bDebug = B;
	}
}

exec function ViewClass(class<Actor> aClass, optional bool bQuiet, optional bool bCheat)
{
	local Actor Other, first;
	local bool bFound;
	
	if((Level.Game != none) && !Level.Game.bCanViewOthers)
	{
		return;
	}
	
	first = none;
	
	foreach AllActors(aClass, Other)
	{
		if(bFound || (first == none))
		{
			first = Other;
			
			if(bFound)
			{
				break;
			}
		}
		
		if(Other == ViewTarget)
		{
			bFound = true;
		}
	}
	
	if(first != none)
	{
		if(!bQuiet)
		{
			if(Pawn(first) != none)
			{
				U.CM(ViewingFrom @ first.GetHumanReadableName());
			}
			else
			{
				U.CM(ViewingFrom @ string(first));
			}
		}
		
		SetViewTarget(first);
		bBehindView = ViewTarget != Pawn;
		
		if(bBehindView)
		{
			ViewTarget.BecomeViewTarget();
		}
		
		FixFOV();
		HandleViewTargetCam(ViewTarget);
	}
	else
	{
		ViewSelf(bQuiet);
	}
}

function HandleViewTargetCam(Actor ViewTarget); // Does nothing, but as it's in the game by default, it's kept in here

exec function SetMinPibBossHealth()
{
	local BossPIB Boss;
	
	foreach DynamicActors(class'BossPIB', Boss)
	{
		U.SetHealth(Boss, 1.0);
	}
}

exec function SetMinFGMBossHealth()
{
	local BossFGM Boss;
	
	foreach DynamicActors(class'BossFGM', Boss)
	{
		U.SetHealth(Boss, 1.0);
	}
}

exec function SetMinFatKnightHealth()
{
	local FatKnight Boss;
	
	foreach DynamicActors(class'FatKnight', Boss)
	{
		U.SetHealth(Boss, 1.0);
	}
}

exec function ShowAINodes(bool bAINodesEnabled)
{
	if(bAINodesEnabled)
	{
		myHUD.bShowDebugInfo = true;
		myHUD.SetPropertyText("bDrawLines", "True");
		
		U.CM("AI nodes turned on");
	}
	else
	{
		myHUD.bShowDebugInfo = false;
		myHUD.SetPropertyText("bDrawLines", "False");
		
		U.CM("AI nodes turned off");
	}
}

exec function Invisible(bool bInvisibilityEnabled)
{
	local bool B;
	
	B = bool(GetProp("CurrentPlayer bInvisible", true));
	
	if(!B && bInvisibilityEnabled)
	{
		U.CC("ToggleVisibility");
		
		U.CM("Invisibility turned on");
	}
	else if(B && !bInvisibilityEnabled)
	{
		U.CC("ToggleVisibility");
		
		U.CM("Invisibility turned off");
	}
}

exec function NoTarget(bool bNoTargetEnabled)
{
	if(Pawn.IsA('SHHeroPawn') && bNoTargetEnabled)
	{
		SHHeroPawn(Pawn).bInvisible = true;
		
		U.CM("NoTarget turned on");
	} 
	else
	{
		SHHeroPawn(Pawn).bInvisible = false;
		
		U.CM("NoTarget turned off");
	}
}

exec function FullDebug(bool bFullDebug)
{
	if(bFullDebug)
	{
		U.SetDebugMode(true);
		
		U.CM("Both debug modes turned on");
	}
	else
	{
		U.SetDebugMode(false);
		
		U.CM("Both debug modes turned off");
	}
}

exec function SummonNoRot(string S)
{
	local class<Actor> NewClass;
	local vector SpawnLoc;
	local rotator TempRot;
	local Actor A;
	
	NewClass = U.GetClassByString(S);
	
	if(Pawn != none)
	{
		SpawnLoc = Pawn.Location;
	}
	else
	{
		SpawnLoc = Location;
	}
	
	TempRot = Rotation;
	TempRot.Pitch = 0;
	
	if(!U.MFancySpawn(NewClass, SpawnLoc + 72 * vector(Rotation) + Vect(0.0, 0.0, 1.0) * 15, TempRot, A, iSummonRetryAttempts))
	{
		U.CM("Failed to spawn actor");
		
		return;
	}
	
	U.GivePawnController(KWPawn(A));
}

exec function SummonCoords(string S)
{
	local array<string> TokenArray;
	local class<Actor> NewClass;
	local vector SpawnLoc;
	local Actor A;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 4)
	{
		Warn("Master Controller (SummonCoords) -- Missing arguments; aborting process");
		
		return;
	}
	
	NewClass = U.GetClassByString(TokenArray[0]);
	
	SpawnLoc.x = float(TokenArray[1]);
	SpawnLoc.y = float(TokenArray[2]);
	SpawnLoc.z = float(TokenArray[3]);
	
	if(!U.MFancySpawn(NewClass, SpawnLoc, rot(0, 0, 0), A, iSummonRetryAttempts))
	{
		U.CM("Failed to spawn actor");
		
		return;
	}
	
	U.GivePawnController(KWPawn(A));
}

exec function SetProp(string S, optional bool bSilent)
{
	local array<string> TokenArray;
	local Actor TargetActor;
	local string ActorTag, Variable, Value;
	local name ActorTagName;
	local int i;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 3)
	{
		Warn("Master Controller (SetProp) -- Missing arguments; aborting process");
		
		return;
	}
	
	if(Caps(TokenArray[0]) == "CURRENTPLAYER")
	{
		ActorTag = string(Pawn.Tag);
		ActorTagName = Pawn.Tag;
	}
	else
	{
		ActorTag = TokenArray[0];
		ActorTagName = U.SName(TokenArray[0]);
	}
	
	Variable = TokenArray[1];
	Value = TokenArray[2];
	
	// If further strings are found in the split strings provided, we assume it's all a single string and merge any further strings with the <Value>
	if(TokenArray.Length > 3)
	{
		for(i = 3; i < TokenArray.Length; i++)
		{
			Value = Value @ TokenArray[i];
		}
	}
	
	foreach AllActors(class'Actor', TargetActor, ActorTagName)
	{
		TargetActor.SetPropertyText(Variable, Value);
		
		if(!bSilent)
		{
			U.CM("Set Prop" @ ActorTag @ Variable @ "=" @ Value);
		}
	}
}

exec function string GetProp(string S, optional bool bSilent)
{
	local array<string> TokenArray;
	local Actor TargetActor;
	local string ActorTag, Variable, Value;
	local name ActorTagName;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 2)
	{
		Warn("Master Controller (GetProp) -- Missing arguments; aborting process");
		
		return "";
	}
	
	if(Caps(TokenArray[0]) == "CURRENTPLAYER")
	{
		ActorTagName = Pawn.Tag;
		ActorTag = string(Pawn.Tag);
	}
	else
	{
		ActorTagName = U.SName(TokenArray[0]);
		ActorTag = TokenArray[0];
	}
	
	Variable = TokenArray[1];
	
	foreach AllActors(class'Actor', TargetActor, ActorTagName)
	{
		Value = TargetActor.GetPropertyText(Variable);
		
		if(!bSilent)
		{
			U.CM("Get Prop" @ ActorTag @ Variable @ "=" @ Value);
		}
	}
	
	return Value;
}

exec function name WhoAmI()
{
	U.CMAndLog("I am currently:" @ string(Pawn.Name));
	
	return Pawn.Name;
}

exec function Rocket()
{
	GotoState('PlayerRocketing');
	
	U.CM("You feel like a rocket");
}

exec function Spider()
{
	GotoState('PlayerSpidering');
	
	U.CM("You feel like a spider");
}

exec function Driving()
{
	GotoState('PlayerDriving');
	
	U.CM("You feel like a desert bus");
}

exec function Announce(string Msg)
{
	U.Announce(Msg, fAnnTime, U.MakeColor(AnnColorR, AnnColorG, AnnColorB, 255));
	
	U.CM("Announcing");
}

exec function AnnounceTime(float F)
{
	fAnnTime = F;
	
	U.CM("Announcement settings changed: ( Announcement time =" @ string(fAnnTime) @ ")");
}

exec function AnnounceColor(string S)
{
	local array<string> TokenArray;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 3)
	{
		Warn("Master Controller (AnnounceColor) -- Missing arguments; aborting process");
		
		return;
	}
	
	AnnColorR = float(TokenArray[0]);
	AnnColorG = float(TokenArray[1]);
	AnnColorB = float(TokenArray[2]);
	
	U.CM("Announcement settings changed: ( Announcement color (Red):" @ string(AnnColorR) @ "| Announcement color (Green):" @ string(AnnColorG) @ "| Announcement color (Blue):" @ string(AnnColorB) @ ")");
}

exec function TP(string S)
{
	local array<string> TokenArray;
	local string X, Y, Z;
	local vector Loc;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 3)
	{
		Warn("Master Controller (TP) -- Missing arguments; aborting process");
		
		return;
	}
	
	X = TokenArray[0];
	Y = TokenArray[1];
	Z = TokenArray[2];
	
	Loc.X = float(X);
	Loc.Y = float(Y);
	Loc.Z = float(Z);
	
	OldTPLoc = Pawn.Location;
	
	if(!U.MFancySetLocation(Pawn, Loc, iTPRetryAttempts))
	{
		U.CM("Failed to teleport to:" @ X @ Y @ Z);
		
		return;
	}
	
	bCanTPBack = true;
	
	U.CM("Teleporting to:" @ X @ Y @ Z);
}

exec function TPBack()
{
	if(!bCanTPBack)
	{
		return;
	}
	
	if(bTPBackOncePerTP)
	{
		bCanTPBack = false;
	}
	
	if(!U.MFancySetLocation(Pawn, OldTPLoc, iTPRetryAttempts))
	{
		U.CM("Failed to teleport to:" @ string(OldTPLoc.X) @ string(OldTPLoc.Y) @ string(OldTPLoc.Z));
		
		return;
	}
	
	U.CM("Teleporting to:" @ string(OldTPLoc.X) @ string(OldTPLoc.Y) @ string(OldTPLoc.Z));
}

exec function WriteString(string S)
{
	U.CMAndLog(S);
}

exec function WriteStrings(string S)
{
	local array<string> TokenArray;
	local int i;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 1)
	{
		Warn("Master Controller (WriteStrings) -- Missing arguments; aborting process");
		
		return;
	}
	
	for(i = 0; i < TokenArray.Length; i++)
	{
		U.CMAndLog(TokenArray[i]);
	}
}

exec function UpdateInv()
{
	AddCoins(0);
	AddPotions(0);
	
	Log("Updated inventory");
}

exec function SetBoth(int I)
{
	SetCoins(I);
	SetPotions(I);
	
	U.CM("Set" @ string(I) @ "coins and potions to the player");
}

exec function AddBoth(int I)
{
	AddCoins(I);
	AddPotions(I);
	
	U.CM("Added" @ string(I) @ "coins and potions to the player");
}

exec function BossCheat()
{
	local BanditBoss Boss;
	
	SetMinPibBossHealth();
	SetMinFGMBossHealth();
	SetMinFatKnightHealth();
	
	foreach DynamicActors(class'BanditBoss', Boss)
	{
		U.SetHealth(Boss, 1.0);
	}
	
	U.CM("All main bosses are now at 1 HP");
}

exec function ChangeState(string S)
{
	local array<string> TokenArray;
	
	TokenArray = U.Split(S);
	
	if(TokenArray.Length < 1)
	{
		Warn("Master Controller (ChangeState) -- Missing arguments; aborting process");
		
		return;
	}
	
	NewState = U.SName(TokenArray[0]);
	
	if(TokenArray.Length > 1)
	{
		if(bool(TokenArray[1]))
		{
			Pawn.GotoState(NewState);
		}
		else
		{
			GotoState(NewState);
		}
	}
	else
	{
		GotoState(NewState);
	}
	
	U.CM("Switched to state:" @ NewState);
}

exec function ChangePhysics(int I)
{
	Pawn.SetPhysics(EPhysics(I));
	
	U.CM("Switched to physics:" @ string(Pawn.Physics));
}

exec function AntiAntiCheat()
{
	local MAntiCheat AC;
	
	foreach DynamicActors(class'MAntiCheat', AC)
	{
		AC.TickEnabled(false);
		U.FancyDestroy(AC);
	}
	
	U.CM("M.A.C. (Master's Anti-Cheat) has been permanently disabled");
}

exec function bool WaterJump()
{
	if(Pawn.IsA('SHPawn'))
	{
		if(Pawn.Physics == PHYS_WALKING && SHPawn(Pawn).bInWater == true)
		{
			Pawn.Falling();
			Pawn.PlayFalling();
			Pawn.SetPhysics(PHYS_FALLING);
			Pawn.Velocity.Z = Pawn.JumpZ;
			Pawn.bUpAndOut = true;
			
			return true;
		}
	}
	
	return false;
}

exec function bool AirJump()
{
	if(CanAirJump())
	{
		SHHeroPawn(Pawn).DoDoubleJump(false);
		bNotifyApex = true;
		
		return true;
	}
	
	return false;
}

exec function bool AirJumpLimited()
{
	if(CanAirJump())
	{
		if(iAirJumpCounter >= iAirJumpMax)
		{
			return false;
		}
		
		SHHeroPawn(Pawn).DoDoubleJump(false);
		bNotifyApex = true;
		
		iAirJumpCounter++;
		
		return true;
	}
	
	return false;
}

function bool CanAirJump() // This function is used in the AirJump command. Returns true if the player is capable of double jump, is not in water and is falling (true if velocity Z is negative)
{
	if(Pawn.IsA('SHPawn'))
	{
		return (Pawn.bCanDoubleJump && !SHPawn(Pawn).bInWater && Pawn.Velocity.Z < 0.0);
	}
	else
	{
		return (Pawn.bCanDoubleJump && Pawn.Velocity.Z < 0.0);
	}
}

exec function Execute(string S, optional bool bIsSleeping)
{
	local MConsoleCommandDelegate CCD;
	local array<string> TokenArray, ConsoleCommands;
	local float F;
	local int i, iCurrentCC;
	
	TokenArray = U.Split(S);
	
	if(!bIsSleeping)
	{
		if(TokenArray.Length < 1)
		{
			Warn("Master Controller (Execute) -- Missing arguments; aborting process");
			
			return;
		}
	}
	else if(TokenArray.Length < 2)
	{
		Warn("Master Controller (SleepFor) -- Missing arguments; aborting process");
		
		return;
	}
	
	if(ExecuteLoopCheck(TokenArray))
	{
		Warn("Master Controller (Execute) -- Infinite loop found; aborting process");
		
		return;
	}
	
	if(bIsSleeping)
	{
		F = float(TokenArray[0]);
	}
	
	ConsoleCommands[0] = TokenArray[int(bIsSleeping)];
	
	// String merger
	for(i = 1 + int(bIsSleeping); i < TokenArray.Length; i++)
	{
		// If the keyword "|" is used between the command, we queue another console command to run
		if(Caps(TokenArray[i]) == "|")
		{
			iCurrentCC++;
			
			ConsoleCommands[iCurrentCC] = "";
			
			continue;
		}
		
		if(ConsoleCommands[iCurrentCC] == "")
		{
			// Starting a new console command
			ConsoleCommands[iCurrentCC] = TokenArray[i];
		}
		else 
		{
			// Adding a second part to the console command
			ConsoleCommands[iCurrentCC] = ConsoleCommands[iCurrentCC] @ TokenArray[i];
		}
	}
	
	if(!bIsSleeping)
	{
		U.CM("Executing the following console commands:");
	}
	else
	{
		U.CM("Sleeping for" @ string(F) @ "seconds, then executing the following console commands:");
	}
	
	for(i = 0; i < ConsoleCommands.Length; i++)
	{
		U.CM(ConsoleCommands[i]);
	}
	
	CCD = Spawn(class'MConsoleCommandDelegate');
	
	if(bIsSleeping)
	{
		CCD.fSleepFor = F;
	}
	
	CCD.ConsoleCommandsToRun = ConsoleCommands;
	CCD.GotoState('ExecuteCommands');
}

function bool ExecuteLoopCheck(array<string> TokenArray) // Returns true if an infinite loop is about to be executed within Execute or SleepFor
{
	local bool bLoopFound;
	local int i;
	
	for(i = 0; i < TokenArray.Length; i++)
	{
		if(Caps(TokenArray[i]) == "EXECUTE" || Caps(TokenArray[i]) == "SLEEPFOR")
		{
			bLoopFound = true;
			
			break;
		}
	}
	
	return bLoopFound;
}

exec function SleepFor(string S)
{
	local array<string> TokenArray;
	
	TokenArray = U.Split(S);
	
	// If true, this console command will act like Execute instead of SleepFor, as for this to be true, it would mean no delay was given
	if(float(TokenArray[0]) < 0.0)
	{
		Execute(S);
	}
	else
	{
		Execute(S, true);
	}
}

exec function PlayASound(string S)
{
	local Sound SoundToPlay;
	
	SoundToPlay = U.PlayASound(S,, fPlayASoundVolume);
	
	U.CM("Playing sound:" @ string(SoundToPlay));
}

exec function PlayADialog(string S)
{
	if(Pawn.IsA('KWPawn'))
	{
		KWPawn(Pawn).DeliverLocalizedDialog(S, true, 0, "HPDialog",, true, 1.4, false);
		
		U.CM("Playing dialog:" @ S);
	}
	else
	{
		Warn("Master Controller (PlayADialog) -- Pawn isn't a KWPawn; aborting process");
	}
}

exec function PlayAMusic(string S)
{
	local string sCurrentMusic;
	
	sCurrentMusic = U.GetCurrentMusic();
	
	StopAllMusic(1.0);
	
	if(S != "")
	{
		PlayMusic(S, 1.0);
	}
	
	if(U.GetCurrentMusic() != sCurrentMusic)
	{
		if(U.GetCurrentMusic() != "")
		{
			U.CM("Playing music:" @ U.GetCurrentMusic());
		}
		else
		{
			U.CM("Stopping music");
		}
	}
	else
	{
		U.CM("Music name" @ S @ "is invalid");
	}
}

exec function RefreshJumpVars()
{
	if(Pawn.IsA('KWPawn'))
	{
		KWPawn(Pawn).SetJumpVars();
		
		U.CM("Refreshed all jump variables");
	}
	else
	{
		Warn("Master Controller (RefreshJumpVars) -- Pawn isn't a KWPawn; aborting process");
	}
}

exec function SetGameState(string S)
{
	KWGame(Level.Game).SetGameState(S);
	
	U.CM("Set GameState to:" @ KWGame(Level.Game).CurrentGameState);
}

exec function string GetGameState()
{
	U.CM("GameState is currently:" @ KWGame(Level.Game).CurrentGameState);
	
	return KWGame(Level.Game).CurrentGameState;
}

exec function DropCarryingActor(string S)
{
	if(Pawn.IsA('KWPawn'))
	{
		if(bool(S))
		{
			U.FancyDestroy(KWPawn(Pawn).aHolding);
		}
		
		KWPawn(Pawn).DropCarryingActor();
		
		U.CM("Dropping carried actor");
	}
}

exec function ConsoleKey(byte I)
{
	U.CC("Set ini:Engine.Engine.Console ConsoleKey" @ string(I));
	
	U.CM("Rebound the console key to key:" @ U.CC("KeyName" @ string(I)));
}

exec function ToggleHud()
{
	myHUD.bHideHud = !myHUD.bHideHud;
	
	U.CM("Toggled the visibility of the HUD to:" @ U.BoolToString(myHUD.bHideHud));
}

exec function PlayAMovie(string S)
{
	if(U.PlayMovie(S, true, false))
	{
		U.CM("Playing movie:" @ U.FormatMovieString(S));
	}
	else
	{
		U.CM("Failed to play movie:" @ U.FormatMovieString(S));
	}
}


// Command Aliases

exec function LogAIS()
{
	LogScriptedSequences();
}

exec function CE(name EventName)
{
	CauseEvent(EventName);
}

exec function UCE(name EventName)
{
	UnCauseEvent(EventName);
}

exec function SH(float F)
{
	SetHealth(F);
}

exec function SP(int I)
{
	SetPotions(I);
}

exec function SC(int I)
{
	SetCoins(I);
}

exec function SB(int I)
{
	SetPotions(I);
	SetCoins(I);
}

exec function AH(float F)
{
	AddHealth(F);
}

exec function AP(int I)
{
	AddPotions(I);
}

exec function AC(int I)
{
	AddCoins(I);
}

exec function AB(int I)
{
	AddPotions(I);
	AddCoins(I);
}

exec function BC()
{
	BossCheat();
}

exec function MV()
{
	MPakVersion();
}

exec function FD(bool B)
{
	FullDebug(B);
}

exec function AAC()
{
	AntiAntiCheat();
}


// States -- Note: multiple known KnowWonder and UE2 mechanics may overwrite a state entirely

state PlayerCanWaterJump extends PlayerWalking
{
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
	
	exec function Jump(optional float f)
	{
		if(!WaterJump())
		{
			super.Jump(f);
		}
	}
}

state PlayerCanAirJump extends PlayerWalking
{
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
	
	exec function Jump(optional float f)
	{
		if(!AirJump())
		{
			super.Jump(f);
		}
	}
}

state PlayerCanAirJumpLimited extends PlayerWalking
{
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
	
	exec function Jump(optional float f)
	{
		if(!AirJumpLimited())
		{
			super.Jump(f);
		}
	}
	
	function bool NotifyLanded(vector HitNormal)
	{
		iAirJumpCounter = 0;
		
		return bUpdating;
	}
	
	function PlayerTick(float DeltaTime)
	{
		if(Pawn == none)
		{
			return;
		}
		
		if(Pawn.IsInState('MountFinish'))
		{
			iAirJumpCounter = 0;
		}
		
		global.PlayerTick(DeltaTime);
	}
}

state PlayerCanWaterJumpAndAirJumpLimited extends PlayerWalking
{
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
	
	exec function Jump(optional float f)
	{
		if(!WaterJump())
		{
			super.Jump(f);
		}
		
		if(!AirJumpLimited())
		{
			super.Jump(f);
		}
	}
	
	function bool NotifyLanded(vector HitNormal)
	{
		iAirJumpCounter = 0;
		
		return bUpdating;
	}
	
	function PlayerTick(float DeltaTime)
	{
		if(Pawn == none)
		{
			return;
		}
		
		if(Pawn.IsInState('MountFinish'))
		{
			iAirJumpCounter = 0;
		}
		
		global.PlayerTick(DeltaTime);
	}
}

state PlayerAlwaysTripleJump extends PlayerWalking
{
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
	
	event NotifyJumpApex()
	{
		return;
	}
}

state PlayerCannotDoubleJump extends PlayerWalking
{
	function BeginState()
	{
		Pawn.bCanDoubleJump = false;
	}
	
	function EndState()
	{
		Pawn.bCanDoubleJump = Pawn.default.bCanDoubleJump;
	}
	
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
}

state PlayerCannotPunch extends PlayerWalking
{
	function Rotator GetRotationForPawnMove()
	{
		if(bUseCameraAxesForPawnMove)
		{
			return rCameraRot();
		}
		else
		{
			return Pawn.Rotation;
		}
	}
	
	function bool NotifyPhysicsVolumeChange(PhysicsVolume NewVolume)
	{
		super.NotifyPhysicsVolumeChange(NewVolume);
		
		return false;
	}
	
	exec function Fire(optional float f)
	{
		super.Fire(f);
	}
}


defaultproperties
{
	fTeleportDist=10000.0
	fAnnTime=1.0
	AnnColorR=255
	AnnColorG=255
	AnnColorB=255
	iAirJumpMax=1
	fPlayASoundVolume=0.4
	bModifyHealthSFX=true
	bModifyHealthKnockback=true
	iTPRetryAttempts=28
	iSummonRetryAttempts=75
	MinHitWall=-1.0
	AcquisitionYawRate=20000
	PlayerReplicationInfoClass=class'PlayerReplicationInfo'
	bHidden=true
	bHiddenEd=true
	bAlwaysMouseLook=true
	bZeroRoll=true
	bDynamicNetSpeed=true
	AnnouncerVolume=4
	MaxResponseTime=0.70
	OrthoZoom=40000.0
	CameraDist=9.0
	DesiredFOV=85.0
	DefaultFOV=85.0
	FlashScale=(X=1.0,Y=1.0,Z=1.0)
	MaxTimeMargin=0.35
	ProgressTimeOut=8.0
	QuickSaveString="Quick Saving"
	NoPauseMessage="Game is not pauseable"
	ViewingFrom="Now viewing from"
	OwnCamera="Now viewing from own camera"
	LocalMessageClass=class'LocalMessage'
	EnemyTurnSpeed=45000
	SpectateSpeed=600.0
	DynamicPingThreshold=400.0
	bEnablePickupForceFeedback=true
	bEnableWeaponForceFeedback=true
	bEnableDamageForceFeedback=true
	bEnableGUIForceFeedback=true
	bForceFeedbackSupported=true
	FovAngle=85.0
	Handedness=1.0
	bIsPlayer=true
	bCanOpenDoors=true
	bCanDoSpecial=true
	NetPriority=3.0
	bTravel=true
	bRotateToDesired=true
	bUseBaseCam=true
	bMovePawn=true
	bUseCameraAxesForPawnMove=true
	bShouldRotate=true
	bArrowKeysYaw=true
	strGameMenu="KWGame.MainMenuPage"
	strGameMenuSave="KWGame.MainMenuPage"
	bBehindView=true
	bNotifyApex=true
	RotationRate=(Pitch=4096,Yaw=45000,Roll=3072)
	bPauseWithSpecial=false
	PotionMusicHandle=-1
	Save0Image="storybookanimTX.box_button"
	Save1Image="storybookanimTX.box_button"
	Save2Image="storybookanimTX.box_button"
	Save3Image="storybookanimTX.box_button"
	Save4Image="storybookanimTX.box_button"
	Save5Image="storybookanimTX.box_button"
	DefaultSelectCursorType=none
	CameraClass=class'ShCam'
	rSnapRotation=(Pitch=-1,Yaw=0,Roll=0)
	rSnapRotationSpeed=(Pitch=7,Yaw=0,Roll=0)
	bDoOpacityForCamera=true
	CheatClass=none
	InputClass=class'ShPlayerInput'
	IngameWantedPosterPopUpImage="SH_Menu.WantedPosters.Full_Want_Shrek"
	bFadeInWantedPoster=true
	minsfx=Sound'UI.page_turn'
	bFirstCoin=true
}