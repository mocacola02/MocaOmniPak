//================================================================================
// MOCAWand. Not really going to touch this further, even for v3.0.
//================================================================================
class MOCAWand extends baseWand;

var bool bIsAiming;
var bool bInvisiWand;
var MOCAharry MocaPlayerHarry;

var Color DefaultColorToUse;

event PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Owner.IsA('MOCAharry') )
	{
		MocaPlayerHarry = MOCAharry(Owner);

		LightRadius = MocaPlayerHarry.WandGlowRange;

		Log("InvisiWand? "$string(MocaPlayerHarry.bInvisibleWeapon));

		if ( MocaPlayerHarry.bInvisibleWeapon )
		{
			Mesh = None;
			ThirdPersonMesh = None;
			FireOffset = vect(0,0,0);
			bInvisiWand = True;
		}
	}
	else
	{
		Destroy();
	}
}


event Tick (float fTimeDelta)
{
	Super.Tick(fTimeDelta);
	if ( bIsAiming )
	{
		if ( !ClassIsChildOf(CurrentSpell,class'MOCAbaseSpell') )
		{
			fxChargeParticles.Textures[0] = GetParticleTexture(CurrentSpell);
			GetParticleColor(CurrentSpell);
			GetLightColor(CurrentSpell);
		}
		else
		{
			local class<MOCAbaseSpell> MocaSpell;

			MocaSpell = class<MOCAbaseSpell>( CurrentSpell );

			fxChargeParticles.Textures[0] = MocaSpell.Default.AimParticleTexture;

			fxChargeParticles.ColorStart.Base = MocaSpell.Default.AimParticleStartColor;
			fxChargeParticles.ColorStart.Rand = MocaSpell.Default.AimParticleStartColor;

			fxChargeParticles.ColorEnd.Base = MocaSpell.Default.AimParticleEndColor;
			fxChargeParticles.ColorEnd.Rand = MocaSpell.Default.AimParticleEndColor;

			LightBrightness = MocaSpell.Default.AimLightBrightness;
			LightHue = MocaSpell.Default.AimLightHue;
			LightSaturation = MocaSpell.Default.AimLightSaturation;
		}

		if ( PlayerHarry.SpellCursor.aCurrentTarget == None )
		{
			LightBrightness = 128;
			LightSaturation = 255;
			fxChargeParticles.Textures[0] = Texture'HPParticle.hp_fx.Particles.flare4';
			fxChargeParticles.ColorStart.Base = DefaultColorToUse;
			fxChargeParticles.ColorEnd.Base = DefaultColorToUse;
		}
	}
}

function StartChargingSpell (bool bChargeSpell, optional bool in_bHarryUsingSword, optional Class<baseSpell> ChargeSpellClass)
{
	Super.StartChargingSpell(bChargeSpell,in_bHarryUsingSword,ChargeSpellClass);
	bIsAiming = True;
	fxChargeParticles.bEmit = True;
	LightType = LT_Steady;
}

function StopChargingSpell()
{
	Super.StopChargingSpell();
	bIsAiming = False;
	fxChargeParticles.bEmit = False;
	LightType = LT_None;
}

function Texture GetParticleTexture (Class<baseSpell> spellClass)
{
	switch (spellClass)
	{
		case Class'spellFlipendo':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		case Class'spellLumos':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		case Class'spellAlohomora':
			return Texture'HPParticle.hp_fx.Particles.Key3';
		case Class'spellSkurge':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		case Class'spellRictusempra':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		case Class'spellDiffindo':
			return Texture'HPParticle.hp_fx.Particles.Les_Sparkle_03';
		case Class'spellSpongify':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		case Class'spellDuelRictusempra':
			return Texture'HPParticle.hp_fx.Particles.Les_Sparkle_04';
		case Class'spellDuelMimblewimble':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		case Class'spellDuelExpelliarmus':
			return Texture'HPParticle.hp_fx.Particles.flare4';
		default: break;
	}

	return Texture'HPParticle.hp_fx.Particles.flare4';
}

function GetParticleColor (Class<baseSpell> spellClass)
{
	switch (spellClass)
	{
		case Class'spellFlipendo':
			fxChargeParticles.ColorStart.Base.R = 254; fxChargeParticles.ColorStart.Base.G = 142; fxChargeParticles.ColorStart.Base.B = 61; fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 201; fxChargeParticles.ColorEnd.Base.G = 85;  fxChargeParticles.ColorEnd.Base.B = 46; fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellLumos':
			fxChargeParticles.ColorStart.Base.R = 255; fxChargeParticles.ColorStart.Base.G = 237; fxChargeParticles.ColorStart.Base.B = 15;  fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 191; fxChargeParticles.ColorEnd.Base.B = 60;  fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellAlohomora':
			fxChargeParticles.ColorStart.Base.R = 253; fxChargeParticles.ColorStart.Base.G = 152; fxChargeParticles.ColorStart.Base.B = 0;   fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 202; fxChargeParticles.ColorEnd.Base.B = 40;  fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellSkurge':
			fxChargeParticles.ColorStart.Base.R = 34;  fxChargeParticles.ColorStart.Base.G = 67;  fxChargeParticles.ColorStart.Base.B = 255; fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 113; fxChargeParticles.ColorEnd.Base.G = 6;   fxChargeParticles.ColorEnd.Base.B = 164; fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellRictusempra':
			fxChargeParticles.ColorStart.Base.R = 207; fxChargeParticles.ColorStart.Base.G = 46;  fxChargeParticles.ColorStart.Base.B = 50;  fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 111; fxChargeParticles.ColorEnd.Base.B = 55;  fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellDiffindo':
			fxChargeParticles.ColorStart.Base.R = 121; fxChargeParticles.ColorStart.Base.G = 255; fxChargeParticles.ColorStart.Base.B = 11;  fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 121;   fxChargeParticles.ColorEnd.Base.G = 255;   fxChargeParticles.ColorEnd.Base.B = 11;   fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellSpongify':
			fxChargeParticles.ColorStart.Base.R = 143; fxChargeParticles.ColorStart.Base.G = 63;  fxChargeParticles.ColorStart.Base.B = 192; fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 43;  fxChargeParticles.ColorEnd.Base.G = 62;  fxChargeParticles.ColorEnd.Base.B = 138; fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellDuelRictusempra':
			fxChargeParticles.ColorStart.Base.R = 207; fxChargeParticles.ColorStart.Base.G = 46;  fxChargeParticles.ColorStart.Base.B = 50;  fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 111; fxChargeParticles.ColorEnd.Base.B = 55;  fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellDuelMimblewimble':
			fxChargeParticles.ColorStart.Base.R = 34;  fxChargeParticles.ColorStart.Base.G = 67;  fxChargeParticles.ColorStart.Base.B = 255; fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 113; fxChargeParticles.ColorEnd.Base.G = 6;   fxChargeParticles.ColorEnd.Base.B = 164; fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		case Class'spellDuelExpelliarmus':
			fxChargeParticles.ColorStart.Base.R = 255; fxChargeParticles.ColorStart.Base.G = 237; fxChargeParticles.ColorStart.Base.B = 15;  fxChargeParticles.ColorStart.Base.A = 0;
			fxChargeParticles.ColorEnd.Base.R = 255; fxChargeParticles.ColorEnd.Base.G = 191; fxChargeParticles.ColorEnd.Base.B = 60;  fxChargeParticles.ColorEnd.Base.A = 0;
			return;
		default:
			break;
	}
	return;
}

function GetLightColor (Class<baseSpell> spellClass)
{
	switch (spellClass)
	{
		case Class'spellFlipendo':
			LightBrightness = 100;
			LightHue = 24;
			LightSaturation = 0;
			return;
		case Class'spellLumos':
			LightBrightness = 128;
			LightHue = 42;
			LightSaturation = 0;
			return;
		case Class'spellAlohomora':
			LightBrightness = 128;
			LightHue = 42;
			LightSaturation = 0;
			return;
		case Class'spellSkurge':
			LightBrightness = 128;
			LightHue = 145;
			LightSaturation = 32;
			return;
		case Class'spellRictusempra':
			LightBrightness = 100;
			LightHue = 0;
			LightSaturation = 0;
			return;
		case Class'spellDiffindo':
			LightBrightness = 100;
			LightHue = 80;
			LightSaturation = 0;
			return;
		case Class'spellSpongify':
			LightBrightness = 100;
			LightHue = 192;
			LightSaturation = 50;
			return;
		case Class'spellDuelRictusempra':
			LightBrightness = 100;
			LightHue = 0;
			LightSaturation = 0;
			return;
		case Class'spellDuelMimblewimble':
			LightBrightness = 128;
			LightHue = 145;
			LightSaturation = 32;
			return;
		case Class'spellDuelExpelliarmus':
			LightBrightness = 128;
			LightHue = 42;
			LightSaturation = 0;
			return;
		default:
			break;
	}
	return;
}

function Class<baseSpell> GetClassFromSpellType (ESpellType SpellType)
{
	local Class<baseSpell> ClassFromType;
	ClassFromType = GetMocaClassFromType(SpellType);
	Log("We found the spell class "$string(ClassFromType));
	return ClassFromType;
}

function ChooseSpell (ESpellType SpellType, optional bool bForceSelection)
{
	SetCurrentSpell(GetMocaClassFromType(SpellType));
}

function SetCurrentSpell (Class<baseSpell> spellClass, optional bool bForceSelection)
{
	Log("Attempting to set spell");

	if ( Owner.IsA('MOCAharry') )
	{
		local ESpellType MatchingType;
		Log("We're MOCAharry");
		MatchingType = GetTypeFromMocaClass(spellClass);

		if ( MocaPlayerHarry.IsInSpellBook(MatchingType) || bForceSelection )
		{
			Log("Found spell in list, setting to "$string(spellClass));
			CurrentSpell = spellClass;
		}

		else
		{
			Log("Could not find spell in list");
			if ( bUseDebugMode )
			{
				PlayerHarry.ClientMessage("HARRY CAN NOT USE THIS SPELL YET!!!! -> "$string(spellClass));
			}
		}
	}

	else if ( Owner.IsA('harry') )
	{
		if ( harry(Owner).IsInSpellBook(spellClass.Default.SpellType) || bForceSelection )
		{
			Log("Setting current spell to "$string(spellClass));
			CurrentSpell = spellClass;
		} 
    
		else
		{
			Log("Can't set spell. Not in spellbook?");
			if ( bUseDebugMode )
			{
				PlayerHarry.ClientMessage("HARRY CAN NOT USE THIS SPELL YET!!!! -> "$string(spellClass));
			}
		}
	}

	else
	{
		Log("not sure what harry we are, set spell anyway");
		CurrentSpell = spellClass;
	}
}

function ESpellType GetTypeFromMocaClass (class<baseSpell> TestSpell)
{
	local int i;

	for ( i = 0; i < ArrayCount(MocaPlayerHarry.SpellMapping); i++ )
	{
		if ( MocaPlayerHarry.SpellMapping[i].SpellToAssign == TestSpell )
		{
			Log("Found mapping at index "$i$" with slot "$MocaPlayerHarry.SpellMapping[i].SpellSlot);
			return MocaPlayerHarry.SpellMapping[i].SpellSlot;
		}
	}

	Log("No mapping found for "$string(TestSpell));
	return SPELL_None;
}

function class<baseSpell> GetMocaClassFromType(ESpellType SpellType)
{
	local int i;

	for ( i = 0; i < ArrayCount(MocaPlayerHarry.SpellMapping); i++ )
	{
		if ( MocaPlayerHarry.SpellMapping[i].SpellSlot == SpellType )
		{
			Log("Found mapping at index "$i$" with class "$string(MocaPlayerHarry.SpellMapping[i].SpellToAssign));
			return MocaPlayerHarry.SpellMapping[i].SpellToAssign;
		}
	}

	Log("No mapping found for "$GetEnum(enum'ESpellType', SpellType));
	return None;
}

function Projectile ProjectileFire2 (Class<Projectile> ProjClass, float ProjSpeed, bool bWarn, optional bool bUseWeaponForProjRot, optional Actor aTarget)
{
	local Vector vStart;
	local Vector vEnd;
	local Rotator R;
	local Projectile proj;

	if ( !bInvisiWand )
	{
		Owner.MakeNoise(Pawn(Owner).SoundDampening);
		if ( bUsingSword )
		{
			vStart = Pawn(Owner).WeaponLoc - (Vec(0.0,0.0,fSwordLength * fSwordFXTime / fSwordFXTimeSpan) >> Pawn(Owner).WeaponRot);
			vEnd = harry(Owner).SpellCursor.Location;
			if ( bUseWeaponForProjRot )
			{
				R = Pawn(Owner).WeaponRot;
			} 
			else 
			{
				if ( vEnd == vect(0.00,0.00,0.00) )
				{
					R = harry(Owner).Cam.Rotation;
				} 
				else 
				{
					R = rotator(vEnd - vStart);
				}
			}
			proj = Spawn(ProjClass,Owner,,vStart,R);
		} 
		else 
		{
			vStart = Pawn(Owner).WeaponLoc + (Vec(0.0,0.0,20.0) >> Pawn(Owner).WeaponRot);
			if ( bUseWeaponForProjRot )
			{
				R = Pawn(Owner).WeaponRot;
			} 
			else 
			{
				if ( Owner.IsA('harry') )
				{
					R = harry(Owner).Cam.Rotation;
				} 
				else 
				{
					R = Pawn(Owner).Rotation;
				}
			}
			proj = Spawn(ProjClass,Owner,,vStart,R);
			if ( aTarget.IsA('BossRailMove') )
			{
				baseSpell(proj).SeekSpeed *= 0.25;
			}
			if ( proj == None )
			{
				if ( Pawn(Owner).IsA('PlayerPawn') )
				{
					vStart = PlayerPawn(Owner).Location + Vec(0.0,0.0,PlayerPawn(Owner).EyeHeight);
				} 
				else //{
					if ( Pawn(Owner).IsA('Pawn') )
					{
						vStart = Pawn(Owner).Location;
					}
			//}
				proj = Spawn(ProjClass,Owner,,vStart,R);
			}
		}
	}
	else
	{
		vStart = Pawn(Owner).WeaponLoc - (Vec(0.0,0.0,20.0) >> Pawn(Owner).WeaponRot);

		if ( Owner.IsA('harry') )
		{
			R = harry(Owner).Cam.Rotation;
		}
		else
		{
			R = Pawn(Owner).Rotation;
		}

		proj = Spawn(ProjClass,Owner,,vStart,R);

		if ( aTarget.IsA('BossRailMove') )
		{
			baseSpell(proj).SeekSpeed *= 0.25;
		}

		if ( proj == None )
		{
			if ( Pawn(Owner).IsA('PlayerPawn') )
			{
				vStart = PlayerPawn(Owner).Location + Vec(0.0,0.0,PlayerPawn(Owner).EyeHeight);
			}
			else if ( Pawn(Owner).IsA('Pawn') )
			{
				vStart = Pawn(Owner).Location;
			}

			proj = Spawn(ProjClass,Owner,,vStart,R);
		}
	}

	return proj;
}


defaultproperties
{
	LightBrightness=128
	LightSaturation=255
	bReallyDynamicLight=True
	LightEffect=LE_WateryShimmer
	LightRadius=6
	LightType=LT_None
	fxChargeParticleFXClass=Class'MocaOmniPak.MOCAWandParticles'
	InventoryGroup=2

	DefaultColorToUse=(R=255,G=255,B=255,A=0)
}