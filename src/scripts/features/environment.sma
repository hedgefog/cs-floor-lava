#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>

#include <api_assets>

#include <floorlava_const>

#pragma unused g_pFog
new g_pFog = FM_NULLENT;

public plugin_precache() {
  Asset_Precache(FloorLava_AssetLibrary, FloorLava_Asset_Sky);
  g_pFog = CreateFog();
}

public plugin_init() {
  register_plugin("[The Floor is Lava] Environment", FLOORLAVA_VERSION, "Hedgehog Fog");

  UpdateLight();
}

UpdateLight() {
  set_cvar_string("sv_skyname", "floorlava1");
  set_cvar_num("sv_skycolor_r", 180);
  set_cvar_num("sv_skycolor_g", 80);
  set_cvar_num("sv_skycolor_b", 40);
}

CreateFog() {
  new pFog = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "env_fog"));

  UTIL_SetKVD(pFog, "density" , "0.0008", "env_fog");
  UTIL_SetKVD(pFog, "rendercolor", "180 40 20", "env_fog");

  return pFog;
}

stock UTIL_SetKVD(pEntity, const szKey[], const szValue[], const szClassname[] = "") {
  set_kvd(0, KV_ClassName, szClassname);
  set_kvd(0, KV_KeyName, szKey);
  set_kvd(0, KV_Value, szValue);
  set_kvd(0, KV_fHandled, 0);

  return dllfunc(DLLFunc_KeyValue, pEntity, 0);
}
