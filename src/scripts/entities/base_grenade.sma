#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#include <api_custom_entities>

#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ENTITY_NAME ENTITY(BaseGrenade)
#define METHOD ENTITY_METHOD<BaseGrenade>

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  CE_RegisterClass(ENTITY_NAME, _, true);

  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Create, "@Entity_Create");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Spawn, "@Entity_Spawn");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_InitPhysics, "@Entity_InitPhysics");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Touch, "@Entity_Touch");
  CE_ImplementClassMethod(ENTITY_NAME, CE_Method_Killed, "@Entity_Killed");

  CE_RegisterClassVirtualMethod(ENTITY_NAME, METHOD(TouchKill), "@Entity_TouchKill", CE_Type_Cell);
  CE_RegisterClassVirtualMethod(ENTITY_NAME, METHOD(Detonate), "@Entity_Detonate", CE_Type_Cell);
}

public plugin_init() {
  register_plugin(ENTITY_PLUGIN(BaseGrenade), FLOORLAVA_VERSION, "Hedgehog Fog");
}

/*--------------------------------[ Methods ]--------------------------------*/

@Entity_Create(const this) {
  CE_CallBaseMethod();

  CE_SetMemberVec(this, CE_Member_vecMins, Float:{-4.0, -4.0, -4.0}, false);
  CE_SetMemberVec(this, CE_Member_vecMaxs, Float:{4.0, 4.0, 4.0}, false);
}

@Entity_Spawn(const this) {
  CE_CallBaseMethod();
  
  set_pev(this, pev_health, 1.0);

  set_pev(this, pev_nextthink, get_gametime());
}

@Entity_InitPhysics(const this) {
  CE_CallBaseMethod();

  set_pev(this, pev_solid, SOLID_TRIGGER);
  set_pev(this, pev_movetype, MOVETYPE_TOSS);
  set_pev(this, pev_gravity, 0.5);
}

@Entity_Killed(this, pKiller, iShouldGib) {
  CE_CallMethod(this, METHOD(Detonate), pKiller);
  CE_CallBaseMethod(pKiller, iShouldGib);
}

@Entity_Touch(const this, const pToucher) {
  if (pToucher == pev(this, pev_owner)) return;
  if (pev(this, pev_deadflag) == DEAD_DEAD) return;
  if (pev(pToucher, pev_solid) <= SOLID_TRIGGER) return;

  CE_CallMethod(this, METHOD(TouchKill), pToucher);
}

@Entity_TouchKill(this, pDetonator) {
  ExecuteHamB(Ham_Killed, this, pDetonator, 0);
}

@Entity_Detonate(const this, const pDetonator) {}
