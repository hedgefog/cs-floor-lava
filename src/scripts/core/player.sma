#pragma semicolon 1

#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#include <api_assets>
#include <api_entity_force>

#include <floorlava>
#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define PUNCH_ANGLE_FEEDBACK 0.375

#define USE_SOUND "common/wpn_denyselect.wav"

/*--------------------------------[ Player State ]--------------------------------*/

new g_rgiPlayerDamageBits[MAX_PLAYERS + 1];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(PlayerLaughSound));
  Asset_Precache(ASSET_LIBRARY, ASSET(PlayerPainSound));
  Asset_Precache(ASSET_LIBRARY, ASSET(PlayerChokeSound));
  Asset_Precache(ASSET_LIBRARY, ASSET(PlayerScreamSound));
}

public plugin_init() {
  register_plugin(PLUGIN_NAME("Player"), FLOORLAVA_VERSION, "Hedgehog Fog");

  RegisterHamPlayer(Ham_TakeDamage, "HamHook_Player_TakeDamage", .Post = 0);
  RegisterHamPlayer(Ham_TakeDamage, "HamHook_Player_TakeDamage_Post", .Post = 1);
  RegisterHamPlayer(Ham_Killed, "HamHook_Player_Killed_Post", .Post = 1);
  RegisterHamPlayer(Ham_Touch, "HamHook_Player_Touch_Post", .Post = 1);
  RegisterHamPlayer(Ham_PainSound, "HamHook_Player_PainSound", .Post = 0);

  register_forward(FM_EmitSound, "FMHook_EmitSound");
}

/*--------------------------------[ Forward Handlers ]--------------------------------*/

public FloorLava_OnPlayerBurnedOut(const pPlayer) {
  Asset_EmitSound(pPlayer, CHAN_VOICE, ASSET_LIBRARY, ASSET(PlayerScreamSound));
}

/*--------------------------------[ Hooks ]--------------------------------*/

public HamHook_Player_Killed_Post(const pPlayer, const pKiller) {
  if (IS_PLAYER(pKiller)) {
    Asset_EmitSound(pKiller, CHAN_VOICE, ASSET_LIBRARY, ASSET(PlayerLaughSound));
  }
}

public HamHook_Player_TakeDamage(const pPlayer, const pInflictor, const pAttacker, Float:flDamage, iDamageBits) {
  g_rgiPlayerDamageBits[pPlayer] = iDamageBits;
}

public HamHook_Player_TakeDamage_Post(const pPlayer, const pInflictor, const pAttacker, Float:flDamage, iDamageBits) {
  g_rgiPlayerDamageBits[pPlayer] = DMG_GENERIC;
}

public HamHook_Player_PainSound(const pPlayer) {
  if (g_rgiPlayerDamageBits[pPlayer] & DMG_ACID) {
    Asset_EmitSound(pPlayer, CHAN_VOICE, ASSET_LIBRARY, ASSET(PlayerChokeSound));
  } else {
    Asset_EmitSound(pPlayer, CHAN_VOICE, ASSET_LIBRARY, ASSET(PlayerPainSound));
  }

  return HAM_SUPERCEDE;
}

public EntityForce_OnForceAdd(const pEntity, const Float:vecForce[3], EntityForce_Flags:iFlags) {
  if (IS_PLAYER(pEntity)) {
    @Player_PushFeedback(pEntity, vecForce, iFlags & EntityForce_Flag_Attack ? 1 : -1);
  }
}

public HamHook_Player_Touch_Post(const pPlayer, const pToucher) {
  if (IS_PLAYER(pToucher) && FloorLava_CanPlayerTakeDamage(pPlayer, pToucher)) {
    EntityForce_TransferMomentum(pPlayer, pToucher, 0.85);
  }
}

public FMHook_EmitSound(const pPlayer, iChannel, const szSound[]) {
  if (equal(szSound, USE_SOUND)) return FMRES_SUPERCEDE;

  return FMRES_IGNORED;
}

/*--------------------------------[ Methods ]--------------------------------*/

@Player_PushFeedback(const &this, const Float:vecForce[3], iDirection) {
  static Float:vecAngles[3]; pev(this, pev_angles, vecAngles);
  static Float:vecForward[3]; angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecForward);
  static Float:vecRight[3]; angle_vector(vecAngles, ANGLEVECTOR_RIGHT, vecRight);
  static Float:vecDirection[3]; xs_vec_normalize(vecForce, vecDirection);

  static Float:flPunchRatio; flPunchRatio = (floatmin(xs_vec_len(vecForce) / 500.0, 1.0));
  static Float:flPunchAngle; flPunchAngle = flPunchRatio * (90.0 * PUNCH_ANGLE_FEEDBACK) * iDirection;

  static Float:vecPunchAngle[3];
  vecPunchAngle[0] = xs_vec_dot(vecDirection, vecForward) * flPunchAngle;
  vecPunchAngle[1] = xs_vec_dot(vecDirection, vecRight) * -flPunchAngle;
  vecPunchAngle[2] = 0.0;

  if (xs_vec_len(vecPunchAngle)) {
    set_pev(this, pev_punchangle, vecPunchAngle);
  }
}
