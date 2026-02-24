//================================================================================
// MOCAEssence. the OG custom collectible
//================================================================================
class MOCAEssence extends MOCACollectible;

defaultproperties
{
	DrawType=DT_Sprite
	Texture=Texture'HPParticle.hp_fx.Particles.Sparkle_BW'
	PickUpSound=Sound'HPSounds.menu_sfx.gui_rollover2'
	EventToSendOnPickup=EssencePickupEvent
	classStatusGroup=Class'MOCAStatusGroupEssence'
	classStatusItem=Class'MOCAStatusItemEssence'
	soundBounce=Sound'HPSounds.menu_sfx.gui_rollover3'
	AmbientGlow=220
	CollisionRadius=16.00
	CollisionHeight=24.00
	attachedParticleClass(0)=Class'MocaOmniPak.Essence_fx'
	bHidden=True
	AmbientSound=Sound'HPSounds.menu_sfx.sp_gui_amb_0001'
	SoundPitch=128
	SoundRadius=4
	SoundVolume=255
	bAttractedToHarry=True
}