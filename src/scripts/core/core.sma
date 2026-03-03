#pragma semicolon 1

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>

#include <api_assets>
#include <api_custom_entities>

#include <floorlava_internal>

/*--------------------------------[ Forward Pointers ]--------------------------------*/

new g_pfwConfigLoaded;

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Library_Load(ASSET_LIBRARY);

  CE_RegisterNullClass("info_map_parameters");
  CE_RegisterNullClass("func_bomb_target");
  CE_RegisterNullClass("func_escapezone");
  CE_RegisterNullClass("func_hostage_rescue");
  CE_RegisterNullClass("hostage_entity");
  CE_RegisterNullClass("info_bomb_target");
  CE_RegisterNullClass("info_vip_start");
  CE_RegisterNullClass("info_hostage_rescue");
  CE_RegisterNullClass("monster_scientist");
  CE_RegisterNullClass("weapon_c4");
  CE_RegisterNullClass("func_buyzone");
  CE_RegisterNullClass("armoury_entity");
  CE_RegisterNullClass("weapon_shield");
  CE_RegisterNullClass("game_player_equip");
  CE_RegisterNullClass("player_weaponstrip");
  CE_RegisterNullClass("item_healthkit");
  CE_RegisterNullClass("item_battery");
  CE_RegisterNullClass("func_vip_safetyzone");

  hook_cvar_change(create_cvar(CVAR("version"), FLOORLAVA_VERSION, FCVAR_SERVER), "CvarHook_Version");
}

public plugin_init() {
  register_plugin(FLOORLAVA_TITLE, FLOORLAVA_VERSION, "Hedgehog Fog");
  register_dictionary(DICTIONARY);

  register_forward(FM_GetGameDescription, "FMHook_GetGameDescription");

  register_clcmd("radio1", "Command_Radio1");
  register_clcmd("radio2", "Command_Radio2");
  register_clcmd("radio3", "Command_Radio3");
  register_clcmd("radio4", "Command_Radio4");

  register_message(get_user_msgid("SendAudio"), "Message_SendAudio");

  g_pfwConfigLoaded = CreateMultiForward("FloorLava_OnConfigLoaded", ET_IGNORE);
}

public plugin_cfg() {
  new szConfigDir[32]; get_configsdir(szConfigDir, charsmax(szConfigDir));
  new szMapName[64]; get_mapname(szMapName, charsmax(szMapName));

  server_cmd("exec %s/floorlava.cfg", szConfigDir);
  server_cmd("exec %s/floorlava/%s.cfg", szConfigDir, szMapName);
  server_exec();

  ExecuteForward(g_pfwConfigLoaded);
}

public plugin_natives() {
  register_library(LIBRARY(Core));
}

/*--------------------------------[ Commands ]--------------------------------*/

public Command_Radio1(const pPlayer) {
  return PLUGIN_HANDLED;
}

public Command_Radio2(const pPlayer) {
  return PLUGIN_HANDLED;
}

public Command_Radio3(const pPlayer) {
  return PLUGIN_HANDLED;
}

public Command_Radio4(const pPlayer) {
  return PLUGIN_HANDLED;
}

/*--------------------------------[ Hooks ]--------------------------------*/

public CvarHook_Version(const pCvar) {
  set_pcvar_string(pCvar, FLOORLAVA_VERSION);
}

public FMHook_GetGameDescription() {
  static szGameName[32];
  format(szGameName, charsmax(szGameName), "%s %s", FLOORLAVA_TITLE, FLOORLAVA_VERSION);
  forward_return(FMV_STRING, szGameName);

  return FMRES_SUPERCEDE;
}

public Message_SendAudio()  {
  static szAudio[8]; get_msg_arg_string(2, szAudio, charsmax(szAudio));

  return equali(szAudio, "%!MRAD_", 7) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}
