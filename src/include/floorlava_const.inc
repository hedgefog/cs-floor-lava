#if defined _floorlava_const_included
  #endinput
#endif
#define _floorlava_const_included

stock const FLOORLAVA_TITLE[] = "The Floor is Lava";
stock const FLOORLAVA_VERSION[] = "1.0.0";
stock const FLOORLAVA_CHAT_PREFIX[] = "^4[The Floor is Lava]^1";

/*--------------------------------[ Constants ]--------------------------------*/

enum {
  FloorLava_WeaponId_Fists = 1,
  FloorLava_WeaponId_GymBall = 7,
  FloorLava_WeaponId_WineGrenade,
  FloorLava_WeaponId_Basketball,
  FloorLava_WeaponId_BoxingGloves
};

/*--------------------------------[ Libraries ]--------------------------------*/

stock const FloorLava_Library_Core[] = "floorlava";
stock const FloorLava_Library_Artifacts[] = "floorlava_artifacts";

/*--------------------------------[ Assets ]--------------------------------*/

stock const FloorLava_AssetLibrary[] = "floorlava";

stock const FloorLava_Asset_LavaModel[] = "entities.lava.model";
stock const FloorLava_Asset_GasCloudModel[] = "entities.gas.model";
stock const FloorLava_Asset_WaveBeamSprite[] = "common.sprites.wave-beam";
stock const FloorLava_Asset_Sky[] = "environment.sky";

stock const FloorLava_Asset_FistsViewModel[] = "weapons.fists.models.view";
stock const FloorLava_Asset_FistsPlayerModel[] = "weapons.fists.models.player";
stock const FloorLava_Asset_FistsWorldModel[] = "weapons.fists.models.world";

stock const FloorLava_Asset_BoxingGlovesViewModel[] = "weapons.boxing-gloves.models.view";
stock const FloorLava_Asset_BoxingGlovesPlayerModel[] = "weapons.boxing-gloves.models.player";
stock const FloorLava_Asset_BoxingGlovesWorldModel[] = "weapons.boxing-gloves.models.world";

stock const FloorLava_Asset_GymBallViewModel[] = "weapons.gymball.models.view";
stock const FloorLava_Asset_GymBallPlayerModel[] = "weapons.gymball.models.player";
stock const FloorLava_Asset_GymBallWorldModel[] = "weapons.gymball.models.world";

stock const FloorLava_Asset_WineGrenadeViewModel[] = "weapons.grenade-wine.models.view";
stock const FloorLava_Asset_WineGrenadePlayerModel[] = "weapons.grenade-wine.models.player";
stock const FloorLava_Asset_WineGrenadeWorldModel[] = "weapons.grenade-wine.models.world";

stock const FloorLava_Asset_BasketballViewModel[] = "weapons.basketball.models.view";
stock const FloorLava_Asset_BasketballPlayerModel[] = "weapons.basketball.models.player";
stock const FloorLava_Asset_BasketballWorldModel[] = "weapons.basketball.models.world";

stock const FloorLava_Asset_JetPackPlayerModel[] = "artifacts.jetpack.model";

stock const FloorLava_Asset_SuperPunchSound[] = "weapons.fists.sounds.super-punch";
stock const FloorLava_Asset_BottleBreakSound[] = "weapons.grenade-wine.sounds.break";
stock const FloorLava_Asset_PlayerScreamSound[] = "player.sounds.scream";
stock const FloorLava_Asset_PlayerLaughSound[] = "player.sounds.laugh";
stock const FloorLava_Asset_PlayerPainSound[] = "player.sounds.pain";
stock const FloorLava_Asset_PlayerChokeSound[] = "player.sounds.choke";
stock const FloorLava_Asset_RoundEndSound[] = "common.sounds.round-end";
stock const FloorLava_Asset_FistsHitSound[] = "weapons.fists.sounds.hit";
stock const FloorLava_Asset_JetPackFlameBurstSound[] = "artifacts.jetpack.sounds.flame-burst";
stock const FloorLava_Asset_JetPackAirBurstSound[] = "artifacts.jetpack.sounds.air-burst";
stock const FloorLava_Asset_BasketballBounceSound[] = "weapons.basketball.sounds.bounce";
stock const FloorLava_Asset_GymBallPopSound[] = "weapons.gymball.sounds.pop";

/*--------------------------------[ Entities ]--------------------------------*/

stock const FloorLava_Entity_BaseGrenade[] = "floorlava_base_grenade";
stock const FloorLava_Entity_Lava[] = "floorlava_lava";
stock const FloorLava_Entity_GasCloud[] = "floorlava_gascloud";
stock const FloorLava_Entity_WineGrenade[] = "floorlava_winegrenade";
stock const FloorLava_Entity_Basketball[] = "floorlava_basketball";
stock const FloorLava_Entity_GymBall[] = "floorlava_gymball";

/*--------------------------------[ Lava Entity Members ]--------------------------------*/

stock const FloorLava_Entity_Lava_Member_flSpeed[] = "flSpeed";
stock const FloorLava_Entity_Lava_Member_flDamage[] = "flDamage";
stock const FloorLava_Entity_Lava_Member_flNextDamage[] = "flNextDamage";
stock const FloorLava_Entity_Lava_Member_flNextLightUpdate[] = "flNextLightUpdate";

/*--------------------------------[ Gas Cloud Entity Members ]--------------------------------*/

stock const FloorLava_Entity_GasCloud_Member_flSpeed[] = "flSpeed";
stock const FloorLava_Entity_GasCloud_Member_flDamage[] = "flDamage";
stock const FloorLava_Entity_GasCloud_Member_flNextDamage[] = "flNextDamage";
stock const FloorLava_Entity_GasCloud_Member_flNextLightUpdate[] = "flNextLightUpdate";

/*--------------------------------[ BaseGrenade Entity Methods ]--------------------------------*/

stock const FloorLava_Entity_BaseGrenade_Method_TouchKill[] = "TouchKill";
stock const FloorLava_Entity_BaseGrenade_Method_Detonate[] = "Detonate";

/*--------------------------------[ Basketball Entity Methods ]--------------------------------*/

stock const FloorLava_Entity_Basketball_Method_BounceSound[] = "BounceSound";

/*--------------------------------[ Weapons ]--------------------------------*/

stock const FloorLava_Weapon_Fists[] = "floorlava/v100/weapon_fists";
stock const FloorLava_Weapon_BoxingGloves[] = "floorlava/v100/weapon_boxing_gloves";
stock const FloorLava_Weapon_GymBall[] = "floorlava/v100/weapon_gymball";
stock const FloorLava_Weapon_WineGrenade[] = "floorlava/v100/weapon_winegrenade";
stock const FloorLava_Weapon_Basketball[] = "floorlava/v100/weapon_basketball";

/*--------------------------------[ Fists Weapon Members ]--------------------------------*/

stock const FloorLava_Weapon_Fists_Member_flForce[] = "flForce";
stock const FloorLava_Weapon_Fists_Member_bSecondaryAttack[] = "bSecondaryAttack";
stock const FloorLava_Weapon_Fists_Member_bLeftHand[] = "bLeftHand";
stock const FloorLava_Weapon_Fists_Member_bSuperAttack[] = "bSuperAttack";

/*--------------------------------[ Artifacts ]--------------------------------*/

stock const FloorLava_Artifact_ThermalSuit[] = "thermalsuit";
stock const FloorLava_Artifact_LongFallBoots[] = "longfallboots";
stock const FloorLava_Artifact_JetPack[] = "jetpack";

/*--------------------------------[ Shop ]--------------------------------*/

stock const FloorLava_Shop[] = "floorlava";
stock const FloorLava_ShopItem_WineGrenade[] = "floorlava.wine-grenade";
stock const FloorLava_ShopItem_GymBall[] = "floorlava.gymball";
stock const FloorLava_ShopItem_ThermalSuit[] = "floorlava.thermal-suit";
stock const FloorLava_ShopItem_LongFallBoots[] = "floorlava.long-fall-boots";
stock const FloorLava_ShopItem_JetPack[] = "floorlava.jetpack";
stock const FloorLava_ShopItem_BoxingGloves[] = "floorlava.boxing-gloves";
stock const FloorLava_ShopItem_Basketball[] = "floorlava.basketball";

/*--------------------------------[ Dictionary ]--------------------------------*/

stock const FloorLava_Dictionary[] = "floorlava.txt";
