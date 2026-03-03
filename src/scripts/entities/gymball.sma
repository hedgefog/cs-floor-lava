#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#include <api_custom_entities>
#include <api_entity_force>
#include <api_assets>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ENTITY_NAME ENTITY(GymBall)
#define METHOD ENTITY_METHOD<BaseGrenade>

#define RADIUS 52.0

/*--------------------------------[ Assets ]--------------------------------*/

new g_szModel[MAX_RESOURCE_PATH_LENGTH];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(GymBallWorldModel), g_szModel, charsmax(g_szModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(GymBallPopSound));
  Asset_Precache(ASSET_LIBRARY, ASSET(WaveBeamSprite));

  CE_RegisterClass(ENTITY_NAME, ENTITY(BaseGrenade));
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Create, "@Entity_Create");
  CE_RegisterClassMethod(ENTITY_NAME, METHOD(Detonate), "@Entity_Detonate", CE_Type_Cell);
}

public plugin_init() {
  register_plugin(ENTITY_PLUGIN(Gymball), FLOORLAVA_VERSION, "Hedgehog Fog");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Entity_Create(const this) {
  CE_CallBaseMethod();

  CE_SetMemberString(this, CE_Member_szModel, g_szModel);
}

@Entity_Detonate(const this, const pDetonator) {
  CE_CallBaseMethod(pDetonator);

  static Float:vecOrigin[3]; pev(this, pev_origin, vecOrigin);

  new pTarget = 0;
  while ((pTarget = engfunc(EngFunc_FindEntityInSphere, pTarget, vecOrigin, RADIUS)) > 0) {
    if (pev(pTarget, pev_deadflag) != DEAD_NO) continue;

    static iMoveType; iMoveType = pev(pTarget, pev_movetype);
    if (iMoveType == MOVETYPE_NONE) continue;
    if (iMoveType == MOVETYPE_NOCLIP) continue;
    if (iMoveType == MOVETYPE_FOLLOW) continue;
    if (iMoveType == MOVETYPE_PUSH) continue;

    static Float:flTakeDamage; pev(pTarget, pev_takedamage, flTakeDamage);
    if (flTakeDamage == DAMAGE_NO) continue;

    EntityForce_AddFromOrigin(pTarget, vecOrigin, 500.0, EntityForce_Flag_Attack | EntityForce_Flag_Launch);
    ExecuteHamB(Ham_Touch, pTarget, this);
  }

  static const Float:flLifeTime = 0.2;

  static iModelIndex; iModelIndex = Asset_GetModelIndex(ASSET_LIBRARY, ASSET(WaveBeamSprite));

  engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, vecOrigin, 0);
  write_byte(TE_BEAMTORUS);
  engfunc(EngFunc_WriteCoord, vecOrigin[0]);
  engfunc(EngFunc_WriteCoord, vecOrigin[1]);
  engfunc(EngFunc_WriteCoord, vecOrigin[2]);
  engfunc(EngFunc_WriteCoord, 0.0);
  engfunc(EngFunc_WriteCoord, 0.0);
  engfunc(EngFunc_WriteCoord, vecOrigin[2] + (RADIUS / flLifeTime));
  write_short(iModelIndex);
  write_byte(0);
  write_byte(0);
  write_byte(floatround(flLifeTime * 10));
  write_byte(32);
  write_byte(0);
  write_byte(60);
  write_byte(60);
  write_byte(120);
  write_byte(10);
  write_byte(0);
  message_end();

  Asset_EmitSound(this, CHAN_BODY, ASSET_LIBRARY, ASSET(GymBallPopSound));
}
