#pragma semicolon 1

#include <amxmodx>
#include <engine>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#include <api_custom_weapons>
#include <api_entity_force>
#include <api_assets>

#include <floorlava>
#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define WEAPON_NAME WEAPON(Fists)
#define MEMBER WEAPON_MEMBER<Fists>

#define HIT_DELAY 0.35
#define SUPER_PUNCH_COOLDOWN 10.0

#define SOUND_VOLUME 0.225
#define SOUND_ATTN ATTN_IDLE

/*--------------------------------[ Message IDs ]--------------------------------*/

new gmsgBarTime;

/*--------------------------------[ Assets ]--------------------------------*/

new g_szViewModel[MAX_RESOURCE_PATH_LENGTH];
new g_szPlayerModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(FistsViewModel), g_szViewModel, charsmax(g_szViewModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(FistsPlayerModel), g_szPlayerModel, charsmax(g_szPlayerModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(SuperPunchSound));
  Asset_Precache(ASSET_LIBRARY, ASSET(WaveBeamSprite));
  Asset_Precache(ASSET_LIBRARY, ASSET(FistsHitSound));

  CW_RegisterClass(WEAPON_NAME);
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Create, "@Weapon_Create");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Deploy, "@Weapon_Deploy");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Idle, "@Weapon_Idle");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_PostFrame, "@Weapon_PostFrame");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_PrimaryAttack, "@Weapon_PrimaryAttack");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_SecondaryAttack, "@Weapon_SecondaryAttack");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_GetMaxSpeed, "@Weapon_GetMaxSpeed");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_CanDrop, "@Weapon_CanDrop");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Holster, "@Weapon_Holster");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_Smack, "@Weapon_Smack");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_SmackTraceAttack, "@Weapon_SmackTraceAttack");
  CW_ImplementClassMethod(WEAPON_NAME, CW_Method_MakeDecal, "@Weapon_MakeDecal");
}

public plugin_init() {
  register_plugin(WEAPON_PLUGIN(Fists), FLOORLAVA_VERSION, "Hedgehog Fog");

  gmsgBarTime = get_user_msgid("BarTime");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Weapon_Create(const this) {
  CW_CallBaseMethod();

  CW_SetMember(this, CW_Member_iId, FloorLava_WeaponId_Fists);
  CW_SetMember(this, CW_Member_flSwingDamage, 30.0);
  CW_SetMember(this, CW_Member_iSlot, 0);
  CW_SetMember(this, CW_Member_iPosition, 5);
  CW_SetMember(this, MEMBER(flForce), 1.0);
}

@Weapon_Deploy(const this) {
  CW_CallBaseMethod();

  CW_SetMember(this, MEMBER(bLeftHand), false);

  CW_SetMember(this, MEMBER(bSecondaryAttack), false);

  CW_CallNativeMethod(this, CW_Method_DefaultDeploy, g_szViewModel, g_szPlayerModel, 3, "knife");

  // CW_SetMember(this, CW_Member_iClip, 1);

  @Weapon_ShowProgress(this);
}

@Weapon_Idle(const this) {
  CW_CallBaseMethod();

  CW_CallNativeMethod(this, CW_Method_PlayAnimation, 0, 101.0 / 30.0);
}

@Weapon_PostFrame(const this) {
  if (CW_GetMember(this, MEMBER(bSuperAttack))) {
    new pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

    if ((pev(pPlayer, pev_flags) & FL_ONGROUND) || (pev(pPlayer, pev_movetype) == MOVETYPE_FLY)) {
      CW_SetMember(this, MEMBER(bSuperAttack), false);
    }
  }

  CW_CallBaseMethod();
}

@Weapon_PrimaryAttack(const this) {
  new pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");
  static bool:bLeftHand; bLeftHand = CW_GetMember(this, MEMBER(bLeftHand));

  // CW_SetMember(this, MEMBER(flForce), 1.0);
  CW_SetMember(this, MEMBER(bSecondaryAttack), false);

  static Float:flRange; flRange = 32.0;
  static Float:flSmackDelay; flSmackDelay = -1.0;

  static bool:bSuperAttack; bSuperAttack = CW_GetMember(this, MEMBER(bSuperAttack));

  if (bSuperAttack) {
    static Float:vecAngles[3]; pev(pPlayer, pev_v_angle, vecAngles);
    static Float:vecForward[3]; angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecForward);
    static Float:vecVelocity[3]; pev(pPlayer, pev_velocity, vecVelocity);
    flRange += floatmin(xs_vec_dot(vecForward, vecVelocity) * 0.1, 96.0);
    flSmackDelay = 0.0;
  }

  new pHit = CW_CallNativeMethod(this, CW_Method_DefaultSwing, 0.0, HIT_DELAY, flRange, flSmackDelay);
  if (bSuperAttack && pHit != FM_NULLENT) {
    @Player_LaunchByAim(pPlayer, 256.0);
  }

  CW_CallNativeMethod(this, CW_Method_PlayAnimation, bLeftHand ? 2 : 1, 30.0 / 85.0);

  // CW_SetMember(this, "flLastAttack", get_gametime());
}

@Weapon_SecondaryAttack(const this) {
  new pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

  // CW_SetMember(this, MEMBER(flForce), 1.0);
  CW_SetMember(this, MEMBER(bSecondaryAttack), true);
  CW_SetMember(this, MEMBER(bSuperAttack), true);

  @Player_LaunchByAim(pPlayer, 480.0);

  CW_CallNativeMethod(this, CW_Method_DefaultSwing, 0.0, HIT_DELAY, 96.0);

  CW_CallNativeMethod(this, CW_Method_PlayAnimation, 5, 30.0 / 85.0);

  CW_SetMember(this, CW_Member_flNextSecondaryAttack, get_gametime() + SUPER_PUNCH_COOLDOWN);
  @Weapon_ShowProgress(this);
}

@Weapon_Smack(const this) {
  static pHit; pHit = CW_CallBaseMethod();

  static pPlayer; pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

  if (pHit != FM_NULLENT) {
    static bool:bSuperAttack; bSuperAttack = CW_GetMember(this, MEMBER(bSuperAttack));

    if (bSuperAttack) {
      if (!CW_GetMember(this, MEMBER(bSecondaryAttack))) {
        if (@Player_SuperGroundPunch(pPlayer)) {
          pHit = 0;
        }
      }

      CW_SetMember(this, MEMBER(bSuperAttack), bSuperAttack = false);
    }

    Asset_EmitSound(pPlayer, CHAN_WEAPON, ASSET_LIBRARY, ASSET(FistsHitSound));
  }

  CW_SetMember(this, MEMBER(bLeftHand), !CW_GetMember(this, MEMBER(bLeftHand)));

  return pHit;
}

@Weapon_SmackTraceAttack(const this) {
  static pHit; pHit = CW_GetMember(this, CW_Member_pSwingHit);

  if (pHit == FM_NULLENT) return;

  static pPlayer; pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

  static bool:bSuperAttack; bSuperAttack = CW_GetMember(this, MEMBER(bSuperAttack));
  static Float:flForce; flForce = CW_GetMember(this, MEMBER(flForce));
  static Float:flPushForce; flPushForce = flForce * 512.0;

  if (bSuperAttack) {
    flPushForce *= 1.5;
  }

  if (IS_PLAYER(pHit)) {
    @Player_Push(pHit, pPlayer, flPushForce);
  } else {
    if (pHit > 0 && pev(pHit, pev_takedamage) != DAMAGE_NO) {
      CW_CallBaseMethod();
    }
  }
}

Float:@Weapon_GetMaxSpeed(const this) {
  return 250.0;
}

@Weapon_CanDrop(const this) {
  return false;
}

@Weapon_Holster(const this) {
  CW_CallBaseMethod();

  new pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

  if (!is_user_connected(pPlayer)) return;

  @Weapon_HideProgress(this);
}

@Weapon_ShowProgress(const this) {
  new pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

  static Float:flNextSecondaryAttack; flNextSecondaryAttack = CW_GetMember(this, CW_Member_flNextSecondaryAttack);
  if (flNextSecondaryAttack < 1.0) return;

  message_begin(MSG_ONE, gmsgBarTime, _, pPlayer);
  write_short(floatround(flNextSecondaryAttack - get_gametime()));
  message_end();
}

@Weapon_HideProgress(const this) {
  new pPlayer = get_ent_data_entity(this, "CBasePlayerItem", "m_pPlayer");

  static Float:flNextSecondaryAttack; flNextSecondaryAttack = CW_GetMember(this, CW_Member_flNextSecondaryAttack);
  if (!flNextSecondaryAttack) return;

  message_begin(MSG_ONE, gmsgBarTime, _, pPlayer);
  write_short(0);
  message_end();
}

@Weapon_MakeDecal(const this) {}

/*--------------------------------[ Player Methods ]--------------------------------*/

bool:@Player_SuperGroundPunch(const this) {
  static Float:vecVelocity[3]; pev(this, pev_velocity, vecVelocity);
  if (vecVelocity[2] >= 0.0) return false;

  static Float:vecOrigin[3]; pev(this, pev_origin, vecOrigin);
  // static Float:vecViewAngles[3]; pev(this, pev_v_angle, vecViewAngles);
  // static Float:vecForward[3]; angle_vector(vecViewAngles, ANGLEVECTOR_FORWARD, vecForward);
  static Float:vecForward[3]; xs_vec_set(vecForward, 0.0, 0.0, -1.0);

  // static Float:flForce; flForce = -vecVelocity[2] * 1.5;
  static Float:flForce; flForce = xs_vec_dot(vecForward, vecVelocity);
  static Float:flRange; flRange = (flForce / 500.0) * 128.0;

  static Float:vecEnd[3]; xs_vec_add_scaled(vecOrigin, vecForward, flRange, vecEnd);
  engfunc(EngFunc_TraceLine, vecOrigin, vecEnd, IGNORE_MONSTERS, 0, 0);
  get_tr2(0, TR_vecEndPos, vecEnd);

  static Float:vecAbsMin[3]; pev(this, pev_absmin, vecAbsMin);
  if (vecEnd[2] > vecAbsMin[2]) return false;

  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (pPlayer == this) continue;
    if (!is_user_alive(pPlayer)) continue;
    if (!FloorLava_CanPlayerTakeDamage(pPlayer, this)) continue;

    static Float:flDistance; flDistance = entity_range(this, pPlayer);
    if (flDistance > flRange) continue;

    static Float:vecTarget[3]; pev(pPlayer, pev_origin, vecTarget);
    static Float:flDistanceRatio; flDistanceRatio = 1.0 - (flDistance / flRange);
    static Float:flRangeForce; flRangeForce = flForce * floatmin(0.5 + flDistanceRatio, 1.0);

    static Float:vecForce[3];
    xs_vec_sub(vecTarget, vecEnd, vecForce);
    xs_vec_normalize(vecForce, vecForce);
    xs_vec_mul_scalar(vecForce, flRangeForce, vecForce);

    EntityForce_Add(pPlayer, vecForce, EntityForce_Flag_Launch | EntityForce_Flag_Attack);
    ExecuteHamB(Ham_Touch, pPlayer, this);
  }

  static Float:flEffectZ; flEffectZ = vecAbsMin[2] + 4.0;

  static const Float:flLifeTime = 0.25;

  message_begin_f(MSG_PAS, SVC_TEMPENTITY, vecOrigin);
  write_byte(TE_BEAMDISK);
  write_coord_f(vecOrigin[0]);
  write_coord_f(vecOrigin[1]);
  write_coord_f(flEffectZ);
  write_coord_f(0.0);
  write_coord_f(0.0);
  write_coord_f(flEffectZ + (flRange / flLifeTime));
  write_short(Asset_GetModelIndex(ASSET_LIBRARY, ASSET(WaveBeamSprite)));
  write_byte(0);
  write_byte(0);
  write_byte(floatround(flLifeTime * 10));
  write_byte(0);
  write_byte(0);
  write_byte(180);
  write_byte(180);
  write_byte(180);
  write_byte(80);
  write_byte(0);
  message_end();

  Asset_EmitSound(this, CHAN_STATIC, ASSET_LIBRARY, ASSET(SuperPunchSound));

  return true;
}

@Player_LaunchByAim(this, Float:flForce) {
  static Float:vecViewAngles[3]; pev(this, pev_v_angle, vecViewAngles);
  static Float:vecDirection[3]; angle_vector(vecViewAngles, ANGLEVECTOR_FORWARD, vecDirection);
  static Float:vecForce[3]; xs_vec_mul_scalar(vecDirection, flForce, vecForce);

  EntityForce_Add(this, vecForce, EntityForce_Flag_Launch);
}

@Player_Push(const &this, const &pPusher, Float:flForce) {
  if (!FloorLava_CanPlayerTakeDamage(this, pPusher)) return;

  // static Float:vecSrc[3]; ExecuteHamB(Ham_EyePosition, pPusher, vecSrc);
  // static Float:vecEnd[3]; pev(this, pev_origin, vecEnd);
  static Float:vecPusherVelocity[3]; pev(pPusher, pev_velocity, vecPusherVelocity);
  // static Float:vecPusherSpeed; vecPusherSpeed = xs_vec_len(vecPusherVelocity);

  static Float:vecDirection[3];
  pev(pPusher, pev_v_angle, vecDirection);
  vecDirection[0] = 0.0;
  angle_vector(vecDirection, ANGLEVECTOR_FORWARD, vecDirection);

  // xs_vec_sub(vecEnd, vecSrc, vecDirection);
  // xs_vec_normalize(vecDirection, vecDirection);

  static Float:vecForce[3];
  // xs_vec_set(vecForce, 0.0, 0.0, 0.0);
  // xs_vec_add_scaled(vecForce, vecDirection, flForce, vecForce);
  xs_vec_mul_scalar(vecDirection, flForce, vecForce);
  xs_vec_add_scaled(vecForce, vecDirection, xs_vec_dot(vecDirection, vecPusherVelocity), vecForce);

  if (xs_vec_dot(vecDirection, vecForce) < 0.0) {
    xs_vec_set(vecForce, 0.0, 0.0, 0.0);
  }

  // xs_vec_add(vecForce, vecPusherVelocity, vecForce);

  static Float:flTotalForce; flTotalForce = xs_vec_len(vecForce);

  if (flTotalForce > 0.0) {
    EntityForce_Add(this, vecForce, EntityForce_Flag_Attack);
  }

  if (flTotalForce > flForce) {
    ExecuteHamB(Ham_PainSound, this);
  }

  ExecuteHamB(Ham_Touch, this, pPusher);
}
