#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#include <xs>

#include <api_custom_entities>
#include <api_assets>
#include <screenfade_util>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ENTITY_NAME ENTITY(GasCloud)
#define MEMBER ENTITY_MEMBER<GasCloud>

/*--------------------------------[ Assets ]--------------------------------*/

new g_szModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin State ]--------------------------------*/

new Float:g_flGameTime = 0.0;

/*--------------------------------[ Player State ]--------------------------------*/

new Float:g_rgflPlayerNextInhale[MAX_PLAYERS + 1];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(GasCloudModel), g_szModel, charsmax(g_szModel));

  CE_RegisterClass(ENTITY_NAME);
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Create, "@GasCloud_Create");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Spawn, "@GasCloud_Spawn");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Think, "@GasCloud_Think");
}

public plugin_init() {
  register_plugin(ENTITY_PLUGIN(Gas Cloud), FLOORLAVA_VERSION, "Hedgehog Fog");
}

public server_frame() {
  g_flGameTime = get_gametime();
}

/*--------------------------------[ Methods ]--------------------------------*/

@GasCloud_Create(const this) {
  CE_CallBaseMethod();

  CE_SetMemberString(this, CE_Member_szModel, g_szModel);
  CE_SetMember(this, CE_Member_bForceVisible, true);

  CE_SetMember(this, MEMBER(flDamage), 25.0);
  CE_SetMember(this, MEMBER(flSpeed), 0.0);
  CE_SetMember(this, MEMBER(flNextDamage), 0.0);
}

@GasCloud_Spawn(const this) {
  CE_CallBaseMethod();

  set_pev(this, pev_solid, SOLID_TRIGGER);
  set_pev(this, pev_movetype, MOVETYPE_NOCLIP);
  set_pev(this, pev_nextthink, g_flGameTime);
  set_pev(this, pev_scale, 20.0);
  set_pev(this, pev_renderamt, 255.0);
  set_pev(this, pev_rendermode, kRenderTransAdd);
  set_pev(this, pev_framerate, 0.0);
  set_pev(this, pev_animtime, g_flGameTime);

  CE_SetMember(this, MEMBER(flNextLightUpdate), g_flGameTime);
}

@GasCloud_Think(const this) {
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
  vecAVelocity[1] = 25.0 * (flSpeed / 8.0);
  set_pev(this, pev_avelocity, vecAVelocity);

  if (Float:CE_GetMember(this, MEMBER(flNextDamage)) <= g_flGameTime) {
    static Float:flDamage; flDamage = CE_GetMember(this, MEMBER(flDamage));

    if (flDamage) {
      for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
        if (!is_user_connected(pPlayer)) continue;

        static Float:vecPlayerAbsmax[3]; pev(pPlayer, pev_absmax, vecPlayerAbsmax);

        if ((vecPlayerAbsmax[2] - 16.0) >= vecOrigin[2]) {
          static const Float:flMinAmt = 80.0;
          static const Float:flMaxAmt = 220.0;
          static Float:flHeightRatio; flHeightRatio = floatmin(((vecPlayerAbsmax[2] - vecOrigin[2]) / 256.0), 1.0);

          static Float:flFade; flFade = (255.0 - ((255.0 - flMaxAmt) + flMinAmt)) * flHeightRatio;
          UTIL_ScreenFade(pPlayer, {180, 80, 40}, _, 1.0, floatround(flMinAmt + flFade));

          if (is_user_alive(pPlayer) && g_rgflPlayerNextInhale[pPlayer] <= g_flGameTime) {
            ExecuteHamB(Ham_TakeDamage, pPlayer, this, this, flDamage * flHeightRatio, DMG_SLOWBURN | DMG_ACID);
            g_rgflPlayerNextInhale[pPlayer] = g_flGameTime + 1.5;
          }
        }
      }
    }

    CE_SetMember(this, MEMBER(flNextDamage), g_flGameTime + 0.1);
  }

  set_pev(this, pev_ltime, g_flGameTime);
  set_pev(this, pev_nextthink, g_flGameTime + 0.025);
}
