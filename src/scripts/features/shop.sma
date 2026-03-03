#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>

#include <api_shops>
#include <api_custom_weapons>

#include <floorlava_player_artifacts>
#include <floorlava_internal>

public plugin_init() {
  register_plugin(PLUGIN_NAME("Shop"), FLOORLAVA_VERSION, "Hedgehog Fog");

  register_dictionary(DICTIONARY);

  Shop_Register(FloorLava_Shop);
  Shop_SetFlags(FloorLava_Shop, Shop_Flag_ItemPage);
  Shop_SetTitle(FloorLava_Shop, "The Floor is Lava Shop");
  Shop_SetGuardCallback(FloorLava_Shop, "Callback_Shop_Guard");

  if (FloorLava_PlayerArtifact_IsRegistered(ARTIFACT(LongFallBoots))) {
    Shop_Item_Register(SHOP_ITEM(LongFallBoots));
    Shop_Item_SetTitle(SHOP_ITEM(LongFallBoots), "FLOORLAVA_ITEM_LONGFALLBOOTS", true);
    Shop_Item_SetDescription(SHOP_ITEM(LongFallBoots), "FLOORLAVA_ITEM_LONGFALLBOOTS_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(LongFallBoots), "Callback_ShopItem_LongFallBoots_Purchase");
    Shop_Item_SetGuardCallback(SHOP_ITEM(LongFallBoots), "Callback_ShopItem_LongFallBoots_Guard");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(LongFallBoots), 800);
  }

  if (CW_IsClassRegistered(WEAPON(GymBall))) {
    Shop_Item_Register(SHOP_ITEM(GymBall));
    Shop_Item_SetTitle(SHOP_ITEM(GymBall), "FLOORLAVA_ITEM_GYMBALL", true);
    Shop_Item_SetDescription(SHOP_ITEM(GymBall), "FLOORLAVA_ITEM_GYMBALL_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(GymBall), "Callback_ShopItem_GymBall_Purchase");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(GymBall), 1000);
  }

  if (CW_IsClassRegistered(WEAPON(WineGrenade))) {
    Shop_Item_Register(SHOP_ITEM(WineGrenade));
    Shop_Item_SetTitle(SHOP_ITEM(WineGrenade), "FLOORLAVA_ITEM_WINEGRENADE", true);
    Shop_Item_SetDescription(SHOP_ITEM(WineGrenade), "FLOORLAVA_ITEM_WINEGRENADE_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(WineGrenade), "Callback_ShopItem_WineGrenade_Purchase");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(WineGrenade), 1000);
  }

  if (CW_IsClassRegistered(WEAPON(Basketball))) {
    Shop_Item_Register(SHOP_ITEM(Basketball));
    Shop_Item_SetTitle(SHOP_ITEM(Basketball), "FLOORLAVA_ITEM_BASKETBALL", true);
    Shop_Item_SetDescription(SHOP_ITEM(Basketball), "FLOORLAVA_ITEM_BASKETBALL_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(Basketball), "Callback_ShopItem_Basketball_Purchase");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(Basketball), 1000);
  }

  if (CW_IsClassRegistered(WEAPON(BoxingGloves))) {
    Shop_Item_Register(SHOP_ITEM(BoxingGloves));
    Shop_Item_SetTitle(SHOP_ITEM(BoxingGloves), "FLOORLAVA_ITEM_BOXINGGLOVES", true);
    Shop_Item_SetDescription(SHOP_ITEM(BoxingGloves), "FLOORLAVA_ITEM_BOXINGGLOVES_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(BoxingGloves), "Callback_ShopItem_BoxingGloves_Purchase");
    Shop_Item_SetGuardCallback(SHOP_ITEM(BoxingGloves), "Callback_ShopItem_BoxingGloves_Guard");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(BoxingGloves), 1500);
  }

  if (FloorLava_PlayerArtifact_IsRegistered(ARTIFACT(ThermalSuit))) {
    Shop_Item_Register(SHOP_ITEM(ThermalSuit));
    Shop_Item_SetTitle(SHOP_ITEM(ThermalSuit), "FLOORLAVA_ITEM_THERMALSUIT", true);
    Shop_Item_SetDescription(SHOP_ITEM(ThermalSuit), "FLOORLAVA_ITEM_THERMALSUIT_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(ThermalSuit), "Callback_ShopItem_ThermalSuit_Purchase");
    Shop_Item_SetGuardCallback(SHOP_ITEM(ThermalSuit), "Callback_ShopItem_ThermalSuit_Guard");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(ThermalSuit), 5000);
  }

  if (FloorLava_PlayerArtifact_IsRegistered(ARTIFACT(JetPack))) {
    Shop_Item_Register(SHOP_ITEM(JetPack));
    Shop_Item_SetTitle(SHOP_ITEM(JetPack), "FLOORLAVA_ITEM_JETPACK", true);
    Shop_Item_SetDescription(SHOP_ITEM(JetPack), "FLOORLAVA_ITEM_JETPACK_DESC", true);
    Shop_Item_SetPurchaseCallback(SHOP_ITEM(JetPack), "Callback_ShopItem_JetPack_Purchase");
    Shop_Item_SetGuardCallback(SHOP_ITEM(JetPack), "Callback_ShopItem_JetPack_Guard");
    Shop_AddItem(FloorLava_Shop, SHOP_ITEM(JetPack), 8000);
  }

  RegisterHamPlayer(Ham_Spawn, "HamHook_Player_Spawn_Post", .Post = 1);

  register_clcmd("buyequip", "Command_Shop");
}

/*--------------------------------[ Commands ]--------------------------------*/

public Command_Shop(const pPlayer) {
  amxclient_cmd(pPlayer, "shop", FloorLava_Shop);

  return PLUGIN_HANDLED;
}

/*--------------------------------[ Hooks ]--------------------------------*/

public HamHook_Player_Spawn_Post(const pPlayer) {
  set_dhudmessage(255, 80, 40, -1.0, 0.75, 0, 0.0, 5.0, 0.1, 2.0);
  show_dhudmessage(pPlayer, "%L", pPlayer, "FLOORLAVA_PURCHASE_HINT");
}

/*--------------------------------[ Shop Callbacks ]--------------------------------*/

public Callback_Shop_Guard(const pPlayer) {
  if (!is_user_alive(pPlayer)) return false;

  return true;
}

/*--------------------------------[ Long Fall Boots Item ]--------------------------------*/

public Callback_ShopItem_LongFallBoots_Purchase(const pPlayer) {
  FloorLava_PlayerArtifact_Give(pPlayer, ARTIFACT(LongFallBoots));
  return true;
}

public Callback_ShopItem_LongFallBoots_Guard(const pPlayer) {
  return !FloorLava_PlayerArtifact_Has(pPlayer, FloorLava_Artifact_LongFallBoots);
}

/*--------------------------------[ Gym Ball Item ]--------------------------------*/

public Callback_ShopItem_GymBall_Purchase(const pPlayer) {
  CW_Give(pPlayer, WEAPON(GymBall));
  return true;
}

/*--------------------------------[ Wine Grenade Item ]--------------------------------*/

public Callback_ShopItem_WineGrenade_Purchase(const pPlayer) {
  CW_Give(pPlayer, WEAPON(WineGrenade));
  return true;
}

/*--------------------------------[ Basketball Item ]--------------------------------*/

public Callback_ShopItem_Basketball_Purchase(const pPlayer) {
  CW_Give(pPlayer, WEAPON(Basketball));
  return true;
}

/*--------------------------------[ Boxing Gloves Item ]--------------------------------*/

public Callback_ShopItem_BoxingGloves_Purchase(const pPlayer) {
  CW_Give(pPlayer, WEAPON(BoxingGloves));
  return true;
}

public Callback_ShopItem_BoxingGloves_Guard(const pPlayer) {
  return !CW_PlayerHasWeapon(pPlayer, FloorLava_Weapon_BoxingGloves);
}

/*--------------------------------[ Thermal Suit Item ]--------------------------------*/

public Callback_ShopItem_ThermalSuit_Purchase(const pPlayer) {
  FloorLava_PlayerArtifact_Give(pPlayer, ARTIFACT(ThermalSuit));
  return true;
}

public Callback_ShopItem_ThermalSuit_Guard(const pPlayer) {
  return !FloorLava_PlayerArtifact_Has(pPlayer, FloorLava_Artifact_ThermalSuit);
}

/*--------------------------------[ JetPack Item ]--------------------------------*/

public Callback_ShopItem_JetPack_Purchase(const pPlayer) {
  FloorLava_PlayerArtifact_Give(pPlayer, ARTIFACT(JetPack));
  return true;
}

public Callback_ShopItem_JetPack_Guard(const pPlayer) {
  return !FloorLava_PlayerArtifact_Has(pPlayer, FloorLava_Artifact_JetPack);
}
