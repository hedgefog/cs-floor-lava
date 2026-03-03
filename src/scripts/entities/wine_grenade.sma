#pragma semicolon 1

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>
#include <xs>

#include <api_custom_entities>
#include <api_player_effects>
#include <api_assets>

#include <floorlava>
#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ENTITY_NAME ENTITY(WineGrenade)
#define METHOD ENTITY_METHOD<BaseGrenade>

#define RADIUS 36.0

/*--------------------------------[ Assets ]--------------------------------*/

new g_szModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(WineGrenadeWorldModel), g_szModel, charsmax(g_szModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(BottleBreakSound));

  CE_RegisterClass(ENTITY_NAME, ENTITY(BaseGrenade));
  CE_RegisterClassMethod(ENTITY_NAME, METHOD(Detonate), "@Entity_Detonate", CE_Type_Cell);
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Create, "@Entity_Create");
}

public plugin_init() {
  register_plugin(ENTITY_PLUGIN(WineGrenade), FLOORLAVA_VERSION, "Hedgehog Fog");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Entity_Create(const this) {
  CE_CallBaseMethod();

  CE_SetMemberString(this, CE_Member_szModel, g_szModel);
}

@Entity_Detonate(const this, const pDetonator) {
  CE_CallBaseMethod(pDetonator);

  static pOwner; pOwner = pev(this, pev_owner);
  static Float:vecOrigin[3]; pev(this, pev_origin, vecOrigin);
  static Float:vecVelocity[3]; pev(this, pev_velocity, vecVelocity);
  static Float:vecMoveDirection[3]; xs_vec_normalize(vecVelocity, vecMoveDirection);
  
  for (new pPlayer = 1; pPlayer <= MaxClients; pPlayer++) {
    if (!is_user_alive(pPlayer)) continue;
    if (!FloorLava_CanPlayerTakeDamage(pPlayer, pOwner)) continue;

    static Float:vecPlayerOrigin[3]; pev(pPlayer, pev_origin, vecPlayerOrigin);

    if (get_distance_f(vecOrigin, vecPlayerOrigin) > RADIUS) continue;

    PlayerEffect_Set(pPlayer, "dizziness", true, 5.0);
    ExecuteHamB(Ham_Touch, pPlayer, this);
  }

  static iSprayModelIndex;
  if (!iSprayModelIndex) {
    iSprayModelIndex = engfunc(EngFunc_ModelIndex, "sprites/bloodspray.spr");
  }

  static iParticleModelIndex;
  if (!iParticleModelIndex) {
    iParticleModelIndex = engfunc(EngFunc_ModelIndex, "sprites/blood.spr");
  }

  engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
  write_byte(TE_ELIGHT);
  write_short(0);
  write_coord_f(vecOrigin[0]);
  write_coord_f(vecOrigin[1]);
  write_coord_f(vecOrigin[2]);
  write_coord_f(RADIUS);
  write_byte(100);
  write_byte(36);
  write_byte(30);
  write_byte(2);
  write_coord(12);
  message_end();

  engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
  write_byte(TE_BLOODSPRITE);
  write_coord_f(vecOrigin[0] - vecMoveDirection[0]);
  write_coord_f(vecOrigin[1] - vecMoveDirection[1]);
  write_coord_f(vecOrigin[2] - vecMoveDirection[2]);
  write_short(iSprayModelIndex);
  write_short(iParticleModelIndex);
  write_byte(228);
  write_byte(5);
  message_end();

  Asset_EmitSound(this, CHAN_BODY, ASSET_LIBRARY, ASSET(BottleBreakSound));
}
