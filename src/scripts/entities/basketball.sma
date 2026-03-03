#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include <api_custom_entities>
#include <api_entity_force>
#include <api_assets>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ENTITY_NAME ENTITY(Basketball)
#define METHOD ENTITY_METHOD<Basketball>

#define RADIUS 36.0

/*--------------------------------[ Assets ]--------------------------------*/

new g_szModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(BasketballWorldModel), g_szModel, charsmax(g_szModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(BasketballBounceSound));

  CE_RegisterClass(ENTITY_NAME);

  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Create, "@Entity_Create");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Spawn, "@Entity_Spawn");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_InitPhysics, "@Entity_InitPhysics");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Touch, "@Entity_Touch");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Think, "@Entity_Think");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_TraceAttack, "@Entity_TraceAttack");

  CE_RegisterClassMethod(ENTITY_NAME, METHOD(BounceSound), "@Entity_BounceSound");
}

public plugin_init() {
  register_plugin(ENTITY_PLUGIN(Basketball), FLOORLAVA_VERSION, "Hedgehog Fog");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Entity_Create(const this) {
  CE_CallBaseMethod();

  CE_SetMemberString(this, CE_Member_szModel, g_szModel);
  CE_SetMemberVec(this, CE_Member_vecMins, Float:{-6.0, -6.0, -6.0});
  CE_SetMemberVec(this, CE_Member_vecMaxs, Float:{6.0, 6.0, 6.0});
}

@Entity_InitPhysics(const this) {
  set_pev(this, pev_solid, SOLID_BBOX);
  set_pev(this, pev_movetype, MOVETYPE_BOUNCE);
  set_pev(this, pev_friction, 0.01);
  set_pev(this, pev_gravity, 0.9);
  set_pev(this, pev_takedamage, DAMAGE_AIM);
}

@Entity_Spawn(const this) {
  set_pev(this, pev_nextthink, get_gametime());
  set_pev(this, pev_health, 99999.0);
}

@Entity_Touch(const this, const pToucher) {
  static Float:vecVelocity[3]; pev(this, pev_velocity, vecVelocity);

  CE_CallBaseMethod(pToucher);

  static Float:flSpeed; flSpeed = xs_vec_len(vecVelocity);

  if (!flSpeed) return;

  if (pToucher) {
    static iToucherMoveType; iToucherMoveType = pev(pToucher, pev_movetype);
    if (iToucherMoveType != MOVETYPE_NONE && iToucherMoveType != MOVETYPE_NOCLIP && iToucherMoveType != MOVETYPE_FOLLOW && iToucherMoveType != MOVETYPE_PUSH) {
      static Float:vecForce[3]; xs_vec_mul_scalar(vecVelocity, 0.85, vecForce);
      EntityForce_Add(pToucher, vecForce);

      if (IS_PLAYER(pToucher)) {
        if (flSpeed > 200.0) {
          ExecuteHamB(Ham_PainSound, pToucher);
        }
      }
    }
  }

  if (~pev(this, pev_flags) & FL_ONGROUND) {
    CE_CallMethod(this, METHOD(BounceSound));
  }

  xs_vec_mul_scalar(vecVelocity, 0.85, vecVelocity);
  set_pev(this, pev_velocity, vecVelocity);
}

@Entity_BounceSound(const this) {
  static Float:vecVelocity[3]; pev(this, pev_velocity, vecVelocity);
  static Float:flSpeed; flSpeed = xs_vec_len(vecVelocity);

  static Float:flSpeedRatio; flSpeedRatio = flSpeed / 320.0;
  static Float:flVolume; flVolume = floatmin(0.8 + (0.2 * flSpeedRatio), 1.0);
  static iPitch; iPitch = min(95 + random(15) + floatround(flSpeedRatio * 125), 255);
  Asset_EmitSound(this, CHAN_BODY, ASSET_LIBRARY, ASSET(BasketballBounceSound), .flVolume = flVolume, .iPitch = iPitch);
}

@Entity_Think(const this) {
  CE_CallBaseMethod();

  static Float:flGameTime; flGameTime = get_gametime();
  static Float:vecVelocity[3]; pev(this, pev_velocity, vecVelocity);
  static iWaterLevel; iWaterLevel = pev(this, pev_waterlevel);
  static Float:flNextKill; flNextKill = Float:CE_GetMember(this, CE_Member_flNextKill);

  if (iWaterLevel == 3) {
    set_pev(this, pev_movetype, MOVETYPE_FLY);

    xs_vec_mul_scalar(vecVelocity, 0.8, vecVelocity);
    vecVelocity[2] += 8.0;
    set_pev(this, pev_velocity, vecVelocity);
  } else if (iWaterLevel == 0) {
    set_pev(this, pev_movetype, MOVETYPE_BOUNCE);
  } else {
    vecVelocity[2] -= 8.0;
    set_pev(this, pev_velocity, vecVelocity);
  }

  static Float:flSpeed; flSpeed = xs_vec_len_2d(vecVelocity);

  if (flSpeed > 8.0) {
    if (flSpeed > 32.0) {
      static Float:vecMoveAngles[3]; vector_to_angle(vecVelocity, vecMoveAngles);

      static Float:vecAngleVelocity[3];
      xs_vec_cross(Float:{0.0, 0.0, 1.0}, vecVelocity, vecAngleVelocity);
      xs_vec_normalize(vecAngleVelocity, vecAngleVelocity);
      xs_vec_mul_scalar(vecAngleVelocity, (flSpeed / 100.0) * 180.0, vecAngleVelocity);

      set_pev(this, pev_avelocity, vecAngleVelocity);
    }
  } else {
    if (!flNextKill) {
      set_pev(this, pev_solid, SOLID_NOT);
      CE_SetMember(this, CE_Member_flNextKill, flGameTime + 3.0);
    }
  }

  if (flNextKill) {
    set_pev(this, pev_rendermode, kRenderTransTexture);
    set_pev(this, pev_renderamt, floatclamp(flNextKill - flGameTime, 0.0, 1.0) * 255.0);
  }

  set_pev(this, pev_nextthink, flGameTime + 0.01);
}

@Entity_TraceAttack(const this, const pAttacker, Float:flDamage, const Float:vecDirection[3], const pTrace, iDamageBits) {
  CE_CallBaseMethod(pAttacker, flDamage, vecDirection, pTrace, iDamageBits);

  static Float:flForce; flForce = floatclamp(2048.0 * (flDamage / 100.0), iDamageBits & DMG_CLUB ? 300.0 : 0.0, 1024.0);

  static Float:vecForce[3]; xs_vec_mul_scalar(vecDirection, flForce, vecForce);

  EntityForce_Add(this, vecForce);
}
