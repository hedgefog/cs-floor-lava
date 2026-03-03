#pragma semicolon 1

#include <amxmodx>

#include <api_custom_weapons>
#include <api_assets>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define WEAPON_NAME WEAPON(BoxingGloves)
#define FISTS_MEMBER WEAPON_MEMBER<Fists>

/*--------------------------------[ Assets ]--------------------------------*/

new g_szViewModel[MAX_RESOURCE_PATH_LENGTH];
new g_szPlayerModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(BoxingGlovesViewModel), g_szViewModel, charsmax(g_szViewModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(BoxingGlovesPlayerModel), g_szPlayerModel, charsmax(g_szPlayerModel));

  CW_RegisterClass(WEAPON_NAME, WEAPON(Fists));
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Create, "@Weapon_Create");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Deploy, "@Weapon_Deploy");
}

public plugin_init() {
  register_plugin(WEAPON_PLUGIN(BoxingGloves), FLOORLAVA_VERSION, "Hedgehog Fog");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Weapon_Create(const this) {
  CW_CallBaseMethod();

  CW_SetMember(this, CW_Member_iId, FloorLava_WeaponId_BoxingGloves);
  CW_SetMember(this, CW_Member_flSwingDamage, 50.0);
  CW_SetMember(this, CW_Member_iSlot, 0);
  CW_SetMember(this, CW_Member_iPosition, 1);
  CW_SetMember(this, FISTS_MEMBER(flForce), 1.5);
}

@Weapon_Deploy(const this) {
  CW_CallBaseMethod();

  CW_CallNativeMethod(this, CW_Method_DefaultDeploy, g_szViewModel, g_szPlayerModel, 3, "knife");
}
