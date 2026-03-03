#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include <api_custom_weapons>
#include <api_custom_entities>
#include <api_assets>
#include <weapon_base_throwable_const>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define WEAPON_NAME WEAPON(GymBall)

/*--------------------------------[ Assets ]--------------------------------*/

new g_szViewModel[MAX_RESOURCE_PATH_LENGTH];
new g_szPlayerModel[MAX_RESOURCE_PATH_LENGTH];
new g_szWorldModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(GymBallViewModel), g_szViewModel, charsmax(g_szViewModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(GymBallPlayerModel), g_szPlayerModel, charsmax(g_szPlayerModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(GymBallWorldModel), g_szWorldModel, charsmax(g_szWorldModel));

  CW_RegisterClass(WEAPON_NAME, Weapon_BaseThrowable);
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Create, "@Weapon_Create");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Deploy, "@Weapon_Deploy");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Idle, "@Weapon_Idle");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_PrimaryAttack, "@Weapon_PrimaryAttack");

  CW_RegisterClassMethod(WEAPON_NAME, Weapon_BaseThrowable_Method_Throw, "@Weapon_Throw");
  CW_RegisterClassMethod(WEAPON_NAME, Weapon_BaseThrowable_Method_SpawnProjectile, "@Weapon_SpawnProjectile");
  // CW_Ammo_Register("gymball", 3);
}

public plugin_init() {
  register_plugin(WEAPON_PLUGIN(GymBall), FLOORLAVA_VERSION, "Hedgehog Fog");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Weapon_Create(const this) {
  CW_CallBaseMethod();

  CW_SetMemberString(this, CW_Member_szModel, g_szWorldModel);

  CW_SetMember(this, CW_Member_iId, FloorLava_WeaponId_GymBall);
  CW_SetMember(this, CW_Member_iPrimaryAmmoType, 3);
  // CW_SetMemberString(this, CW_Member_szPrimaryAmmo, "gymball");
  CW_SetMember(this, CW_Member_iSlot, 3);
  CW_SetMember(this, CW_Member_iPosition, 4);
  CW_SetMemberString(this, CW_Member_szIcon, "gymball");

  CW_SetMember(this, Weapon_BaseThrowable_Member_flThrowForce, 750.0);
}

@Weapon_Deploy(const this) {
  CW_CallBaseMethod();

  CW_CallNativeMethod(this, CW_Method_DefaultDeploy, g_szViewModel, g_szPlayerModel, 3, "grenade");
}

@Weapon_Idle(const this) {
  CW_CallBaseMethod();

  static Float:flStartThrow; flStartThrow = CW_GetMember(this, Weapon_BaseThrowable_Member_flStartThrow);
  static Float:flReleaseThrow; flReleaseThrow = CW_GetMember(this, Weapon_BaseThrowable_Member_flReleaseThrow);
  static bool:bRedeploy; bRedeploy = CW_GetMember(this, Weapon_BaseThrowable_Member_bRedeploy);

  if (!flStartThrow && flReleaseThrow == -1.0 && !bRedeploy) {
    CW_CallNativeMethod(this, CW_Method_PlayAnimation, 0, 11.0 / 30.0);
  }
}

@Weapon_PrimaryAttack(const this) {
  if (CW_CallBaseMethod()) {
    CW_CallNativeMethod(this, CW_Method_PlayAnimation, 1, 0.5);
  }
}

@Weapon_Throw(const this) {
  CW_CallBaseMethod();
  CW_CallNativeMethod(this, CW_Method_PlayAnimation, 2);
}

@Weapon_SpawnProjectile(const this) {
  static pPlayer; pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");
  static Float:vecAngles[3]; pev(pPlayer, pev_v_angle, vecAngles);
  static Float:vecForward[3]; angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecForward);
  static Float:vecSrc[3]; ExecuteHam(Ham_Player_GetGunPosition, pPlayer, vecSrc);

  xs_vec_add_scaled(vecSrc, vecForward, 16.0, vecSrc);

  new pGrenade = CE_Create(ENTITY(GymBall), vecSrc);
  if (pGrenade == FM_NULLENT) return FM_NULLENT;

  dllfunc(DLLFunc_Spawn, pGrenade);

  set_pev(pGrenade, pev_owner, pPlayer);

  return pGrenade;
}
