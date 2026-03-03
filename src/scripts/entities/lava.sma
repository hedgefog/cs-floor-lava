#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#include <api_custom_entities>
#include <api_assets>
#include <screenfade_util>
#include <function_pointer>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ENTITY_NAME ENTITY(Lava)
#define MEMBER ENTITY_MEMBER<Lava>

/*--------------------------------[ Assets ]--------------------------------*/

new g_szLavaModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin State ]--------------------------------*/

new Float:g_flGameTime = 0.0;

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(LavaModel), g_szLavaModel, charsmax(g_szLavaModel));

  CE_RegisterClass(ENTITY_NAME);
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Create, "@Lava_Create");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Spawn, "@Lava_Spawn");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Think, "@Lava_Think");
}

public plugin_init() {
  register_plugin(ENTITY_PLUGIN(Lava), FLOORLAVA_VERSION, "Hedgehog Fog");
}

public server_frame() {
  g_flGameTime = get_gametime();
}

/*--------------------------------[ Methods ]--------------------------------*/

@Lava_Create(const this) {
  CE_CallBaseMethod();

  CE_SetMemberString(this, CE_Member_szModel, g_szLavaModel);
  CE_SetMember(this, CE_Member_bForceVisible, true);

  CE_SetMember(this, MEMBER(flSpeed), 0.0);
  CE_SetMember(this, MEMBER(flDamage), 100.0);
  CE_SetMember(this, MEMBER(flNextDamage), 0.0);
  CE_SetMember(this, MEMBER(flNextLightUpdate), 0.0);
}

@Lava_Spawn(const this) {
  CE_CallBaseMethod();

  set_pev(this, pev_solid, SOLID_TRIGGER);
  set_pev(this, pev_movetype, MOVETYPE_NOCLIP);
  set_pev(this, pev_nextthink, g_flGameTime);

  CE_SetMember(this, MEMBER(flNextLightUpdate), g_flGameTime);
}

@Lava_Think(const this) {
  CE_CallBaseMethod();

  static Float:flLTime; pev(this, pev_ltime, flLTime);
  static Float:flDelta; flDelta = g_flGameTime - flLTime;
  static Float:flSpeed; flSpeed = CE_GetMember(this, MEMBER(flSpeed));
  static Float:vecOrigin[3]; pev(this, pev_origin, vecOrigin);

  if (flSpeed) {
    vecOrigin[2] = floatmin(vecOrigin[2] + (flSpeed * flDelta), 4096.0);
    set_pev(this, pev_origin, vecOrigin);

  }

  static Float:vecAVelocity[3]; xs_vec_set(vecAVelocity, 0.0, 0.0, 0.0);
  vecAVelocity[1] = 1.0 * (flSpeed / 8.0);
  set_pev(this, pev_avelocity, vecAVelocity);

  // set_pev(this, pev_effects, EF_INVLIGHT);
  // engfunc(EngFunc_SetOrigin, this, vecOrigin);

  if (Float:CE_GetMember(this, MEMBER(flNextDamage)) <= g_flGameTime) {
    static Float:flDamage; flDamage = CE_GetMember(this, MEMBER(flDamage));

    if (flDamage) {
      for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
        if (!is_user_connected(pPlayer)) continue;

        static Float:vecPlayerAbsMin[3]; pev(pPlayer, pev_absmin, vecPlayerAbsMin);
        static Float:vecPlayerAbsmax[3]; pev(pPlayer, pev_absmax, vecPlayerAbsmax);

        if ((vecPlayerAbsmax[2] - 16.0) <= vecOrigin[2]) {
          UTIL_ScreenFade(pPlayer, {250, 80, 40}, _, 1.0, 220);
        }

        if (is_user_alive(pPlayer)) {
          if (vecPlayerAbsMin[2] < (vecOrigin[2] - 1.0)) {
            ExecuteHamB(Ham_TakeDamage, pPlayer, this, this, flDamage, DMG_BURN);

            static Float:vecEffectOrigin[3];
            pev(pPlayer, pev_origin, vecEffectOrigin);
            vecEffectOrigin[2] = vecOrigin[2];

            new pFireFffect = CE_Create("fire", vecEffectOrigin);
            engfunc(EngFunc_SetSize, pFireFffect, {-32.0, -32.0, -32.0}, {32.0, 32.0, 32.0});
            dllfunc(DLLFunc_Spawn, pFireFffect);
            set_pev(pFireFffect, pev_movetype, MOVETYPE_NONE);
            CE_SetMember(pFireFffect, CE_Member_flNextKill, g_flGameTime + 0.75);
          }
        }
      }
    }

    CE_SetMember(this, MEMBER(flNextDamage), g_flGameTime + 0.1);
  }

  if (Float:CE_GetMember(this, MEMBER(flNextLightUpdate)) < g_flGameTime) {
    engfunc(EngFunc_MessageBegin, MSG_ALL, SVC_TEMPENTITY, vecOrigin, 0);
    write_byte(TE_DLIGHT);
    engfunc(EngFunc_WriteCoord, vecOrigin[0]);
    engfunc(EngFunc_WriteCoord, vecOrigin[1]);
    engfunc(EngFunc_WriteCoord, vecOrigin[2]);
    write_byte(10);
    write_byte(255);
    write_byte(105);
    write_byte(0);
    write_byte(2);
    write_byte(0);
    message_end();
    
    CE_SetMember(this, MEMBER(flNextLightUpdate), g_flGameTime + 0.1);
  }

  set_pev(this, pev_ltime, g_flGameTime);
  set_pev(this, pev_nextthink, g_flGameTime + 0.025);
}
