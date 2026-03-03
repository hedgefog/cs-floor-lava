#pragma semicolon 1

#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <reapi>
#include <xs>

#include <api_assets>
#include <api_rounds>
#include <api_custom_entities>
#include <api_custom_weapons>

#include <floorlava_internal>
#include <floorlava_player_artifacts>

/*--------------------------------[ Constants ]--------------------------------*/

#define TASKID_CHECKWINCONDITIONS 1

#define HIDE_HUD_FLAGS HIDEHUD_CROSSHAIR

/*--------------------------------[ Entity State ]--------------------------------*/

new g_pLava = FM_NULLENT;
new g_pGasCloud = FM_NULLENT;

/*--------------------------------[ Plugin State ]--------------------------------*/

new Float:g_flMinSpawnPointHeight = 8192.0;
new Float:g_flMaxSpawnPointHeight = -8192.0;

new Float:g_flLavaSpeed = 0.0;
new Float:g_flLavaStartOffset = 0.0;
new Float:g_flGasStartOffset = 0.0;
new Float:g_flMinGameAreaHeight = 0.0;
new bool:g_bFreeForAll = false;
new g_iMaxMoney;

new bool:g_bGameInProgress = false;
new bool:g_bRoundExpired = false;
new Float:g_flGameTime = 0.0;

/*--------------------------------[ Player State ]--------------------------------*/

new g_rgiPlayerLastDmgBits[MAX_PLAYERS + 1];
new g_rgpPlayerToucher[MAX_PLAYERS + 1];
new Float:g_rgflPlayerToucherTime[MAX_PLAYERS + 1];
new Float:g_rgflPlayerNextBrun[MAX_PLAYERS + 1];

/*--------------------------------[ Forward Pointers ]--------------------------------*/

new g_fwPlayerBurnedOut;

/*--------------------------------[ Message IDs ]--------------------------------*/

new gmsgHideWeapon;

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(RoundEndSound));

  register_forward(FM_Spawn, "FMHook_Spawn_Post", 1);

  bind_pcvar_float(create_cvar(CVAR("lava_speed"), "8.0"), g_flLavaSpeed);
  bind_pcvar_float(create_cvar(CVAR("lava_start_offset"), "-220.0"), g_flLavaStartOffset);
  bind_pcvar_float(create_cvar(CVAR("gascloud_start_offset"), "128.0"), g_flGasStartOffset);
  bind_pcvar_float(create_cvar(CVAR("min_game_area_height"), "480.0"), g_flMinGameAreaHeight);
  bind_pcvar_num(get_cvar_pointer("mp_maxmoney"), g_iMaxMoney);

  g_pLava = @Lava_Create();
  g_pGasCloud = @GasCloud_Create();
}

public plugin_init() {
  register_plugin(PLUGIN_NAME("Game Rules"), FLOORLAVA_VERSION, "Hedgehog Fog");

  gmsgHideWeapon = get_user_msgid("HideWeapon");

  register_dictionary("miscstats.txt");
  register_dictionary(DICTIONARY);

  RegisterHookChain(RG_CBasePlayer_OnSpawnEquip, "HC_Player_OnSpawnEquip");
  RegisterHookChain(RG_CSGameRules_FPlayerCanRespawn, "HC_Player_CanRespawn_Post", .post = 1);
  RegisterHookChain(RG_HandleMenu_ChooseAppearance, "HC_Player_ChooseAppearance_Post", .post = 1);

  RegisterHamPlayer(Ham_Spawn, "HamHook_Player_Spawn_Post", .Post = 1);
  RegisterHamPlayer(Ham_TakeDamage, "HamHook_Player_TakeDamage", .Post = 0);
  RegisterHamPlayer(Ham_TakeDamage, "HamHook_Player_TakeDamage_Post", .Post = 1);
  RegisterHamPlayer(Ham_Killed, "HamHook_Player_Killed_Post", .Post = 1);
  RegisterHamPlayer(Ham_Touch, "HamHook_Player_Touch_Post", .Post = 1);

  register_event("ResetHUD", "Event_ResetHUD", "b");

  register_message(gmsgHideWeapon, "Message_HideWeapon");
  register_message(get_user_msgid("TextMsg"), "Message_TextMsg");
  register_message(get_user_msgid("SendAudio"), "Message_SendAudio");

  CE_RegisterClassNativeMethodHook(ENTITY(Lava), CE_Method_Spawn, "CEHook_Lava_Spawn_Post", true);
  CE_RegisterClassNativeMethodHook(ENTITY(GasCloud), CE_Method_Spawn, "CEHook_GasCloud_Spawn_Post", true);

  g_fwPlayerBurnedOut = CreateMultiForward("FloorLava_OnPlayerBurnedOut", ET_IGNORE, FP_CELL);

  if (cvar_exists("mp_freeforall")) {
    bind_pcvar_num(get_cvar_pointer("mp_freeforall"), g_bFreeForAll);
  }

  #if defined _reapi_included
    set_member_game(m_bCTCantBuy, 1);
    set_member_game(m_bTCantBuy, 1);
  #else
    set_gamerules_int("CHalfLifeMultiplay", "m_bCTCantBuy", 1);
    set_gamerules_int("CHalfLifeMultiplay", "m_bTCantBuy", 1);
  #endif

  dllfunc(DLLFunc_Spawn, g_pLava);
  dllfunc(DLLFunc_Spawn, g_pGasCloud);

  set_task(0.1, "Task_Update", _, _, _, "b");
}

public plugin_natives() {
  register_native("FloorLava_IsFreeForAll", "Native_IsFreeForAll");
  register_native("FloorLava_CheckWinConditions", "Native_CheckWinConditions");
  register_native("FloorLava_IsGameInProgress", "Native_IsGameInProgress");
  register_native("FloorLava_CanPlayerTakeDamage", "Native_CanPlayerTakeDamage");
}

/*--------------------------------[ Natives ]--------------------------------*/

public bool:Native_IsFreeForAll(iPluginId, iArgc) {
  return g_bFreeForAll;
}

public bool:Native_IsGameInProgress(const iPluginId, const iArgc) {
  return g_bGameInProgress;
}

public Native_CheckWinConditions(const iPluginId, const iArgc) {
  CheckWinConditions();
}

public bool:Native_CanPlayerTakeDamage(const iPluginId, const iArgc) {
  new pPlayer = get_param(1);
  new pAttacker = get_param(2);

  return rg_is_player_can_takedamage(pPlayer, pAttacker);
}

/*--------------------------------[ Client Forwards ]--------------------------------*/

public client_disconnected(pPlayer) {
  CheckWinConditions(pPlayer);
}

public server_frame() {
  g_flGameTime = get_gametime();
}

/*--------------------------------[ Events ]--------------------------------*/

public Event_ResetHUD(pPlayer) {
  if (is_user_bot(pPlayer)) return;

  message_begin(MSG_ONE, gmsgHideWeapon, _, pPlayer);
  write_byte(HIDE_HUD_FLAGS);
  message_end();
}

/*--------------------------------[ Messages ]--------------------------------*/

public Message_HideWeapon() {
  set_msg_arg_int(1, ARG_BYTE, get_msg_arg_int(1) | HIDE_HUD_FLAGS);
}

public Message_TextMsg(const iMsgId, const iDest, const pPlayer) {
  if (!g_bFreeForAll) return PLUGIN_CONTINUE;

  static szMessage[32]; get_msg_arg_string(2, szMessage, charsmax(szMessage));

  if (equal(szMessage, "#Terrorists_Win")) return PLUGIN_HANDLED;
  if (equal(szMessage, "#CTs_Win")) return PLUGIN_HANDLED;
  if (equal(szMessage, "#Round_Draw")) return PLUGIN_HANDLED;

  return PLUGIN_CONTINUE;
}

public Message_SendAudio(const iMsgId, const iDest, const pPlayer) {
  if (!g_bFreeForAll) return PLUGIN_CONTINUE;

  static szMessage[32]; get_msg_arg_string(2, szMessage, charsmax(szMessage));

  if (equal(szMessage[7], "terwin")) return PLUGIN_HANDLED;
  if (equal(szMessage[7], "ctwin")) return PLUGIN_HANDLED;
  if (equal(szMessage[7], "rounddraw")) return PLUGIN_HANDLED;

  return PLUGIN_CONTINUE;
}

/*--------------------------------[ Hooks ]--------------------------------*/

public CEHook_Lava_Spawn_Post(const pLava) {
  if (pLava == g_pLava) {
    new Float:flLavaHeight = g_flMinSpawnPointHeight + g_flLavaStartOffset;
    
    new Float:vecLavaOrigin[3] = {0.0, 0.0, 0.0};
    vecLavaOrigin[2] = flLavaHeight;

    engfunc(EngFunc_SetOrigin, pLava, vecLavaOrigin);

    UpdateLavaSpeed();
  }
}

public CEHook_GasCloud_Spawn_Post(const pGasCloud) {
  if (pGasCloud == g_pGasCloud) {
    new Float:flLavaHeight = g_flMinSpawnPointHeight + g_flLavaStartOffset;
    new Float:flGasHeight = g_flMaxSpawnPointHeight + g_flGasStartOffset;
    
    new Float:vecGasOrigin[3] = {0.0, 0.0, 0.0};
    vecGasOrigin[2] = floatmax(flGasHeight, flLavaHeight + g_flMinGameAreaHeight);

    engfunc(EngFunc_SetOrigin, pGasCloud, vecGasOrigin);

    UpdateLavaSpeed();
  }
}

public FMHook_Spawn_Post(const pEntity) {
  if (!pev_valid(pEntity)) return;

  static szClassname[32]; pev(pEntity, pev_classname, szClassname, charsmax(szClassname));

  if (equal(szClassname, "info_player_start") || equal(szClassname, "info_player_deathmatch")) {
    static Float:vecLavaOrigin[3]; pev(pEntity, pev_origin, vecLavaOrigin);
    static Float:vecDown[3]; xs_vec_set(vecDown, vecLavaOrigin[0], vecLavaOrigin[1], vecLavaOrigin[2] - 8192.0);

    engfunc(EngFunc_TraceLine, vecLavaOrigin, vecDown, IGNORE_MONSTERS, 0, 0);
    get_tr2(0, TR_vecEndPos, vecLavaOrigin);

    g_flMinSpawnPointHeight = floatmin(g_flMinSpawnPointHeight, vecLavaOrigin[2]);
    g_flMaxSpawnPointHeight = floatmax(g_flMaxSpawnPointHeight, vecLavaOrigin[2]);
  }
}

public HC_Player_CanRespawn_Post(const pPlayer) {
  if (GetHookChainReturn(ATYPE_INTEGER)) {
    static Float:vecLavaOrigin[3]; pev(g_pLava, pev_origin, vecLavaOrigin);

    if (vecLavaOrigin[2] >= g_flMinSpawnPointHeight) {
      SetHookChainReturn(ATYPE_INTEGER, 0);
      return HC_SUPERCEDE;
    }
  }

  return HC_CONTINUE;
}

public HC_Player_ChooseAppearance_Post(const pPlayer) {
  CheckWinConditions();
}

public HC_Player_OnSpawnEquip(const pPlayer) {
  rg_remove_all_items(pPlayer);
  CW_Give(pPlayer, WEAPON(Fists));

  FloorLava_PlayerArtifact_TakeAll(pPlayer);

  return HC_SUPERCEDE;
}

public HamHook_Player_Spawn_Post(const pPlayer) {
  if (!is_user_alive(pPlayer)) return HAM_IGNORED;

  g_rgpPlayerToucher[pPlayer] = 0;
  g_rgflPlayerToucherTime[pPlayer] = 0.0;

  if (g_bGameInProgress) {
    RequestWinConditionsCheck();
  }

  return HAM_HANDLED;
}

public HamHook_Player_Touch_Post(const pPlayer, const pToucher) {
  static pPlayerToucher; pPlayerToucher = 0;
  
  if (IS_PLAYER(pToucher)) {
    pPlayerToucher = pToucher;
  } else {
    static pOwner; pOwner = pev(pToucher, pev_owner);

    if (IS_PLAYER(pOwner)) {
      pPlayerToucher = pOwner;
    }
  }

  if (pPlayerToucher) {
    g_rgpPlayerToucher[pPlayer] = pPlayerToucher;
    g_rgflPlayerToucherTime[pPlayer] = g_flGameTime;
  }
}

public HamHook_Player_TakeDamage(const pPlayer, const pInflictor, const pAttacker, Float:flDamage, iDamageBits) {
  if (!IS_PLAYER(pAttacker) || pAttacker == pPlayer) {
    new pLastToucher = @Player_GetLastToucher(pPlayer);

    if (pLastToucher) {
      SetHamParamEntity2(2, 0);
      SetHamParamEntity2(3, pLastToucher);
    }
  }

  g_rgiPlayerLastDmgBits[pPlayer] = iDamageBits;
}

public HamHook_Player_TakeDamage_Post(const pPlayer, const pInflictor, const pAttacker, Float:flDamage, iDamageBits) {
  set_ent_data_float(pPlayer, "CBasePlayer", "m_flVelocityModifier", 1.0);
  g_rgiPlayerLastDmgBits[pPlayer] = 0;
}

public HamHook_Player_Killed_Post(const pPlayer, const pKiller, iShouldGib) {
  if (g_rgiPlayerLastDmgBits[pPlayer] & DMG_BURN) {
    set_pev(pPlayer, pev_effects, pev(pPlayer, pev_effects) | EF_NODRAW);
    ExecuteForward(g_fwPlayerBurnedOut, _, pPlayer);
  }

  FloorLava_PlayerArtifact_TakeAll(pPlayer);

  RequestWinConditionsCheck();
}

/*--------------------------------[ Round Forwards ]--------------------------------*/

public Round_OnInit() {
  g_bGameInProgress = false;
  g_bRoundExpired = false;
  UpdateLavaSpeed();

  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (!is_user_connected(pPlayer)) continue;

    new iTeam = get_ent_data(pPlayer, "CBasePlayer", "m_iTeam");
    if (iTeam != 1 && iTeam != 2) continue;

    @Player_AddMoney(pPlayer, 1000);
  }
}

public Round_OnStart() {
  g_bGameInProgress = true;

  set_dhudmessage(180, 40, 20, -1.0, 0.25, 1, 0.0, 3.0, 0.1, 2.0);
  show_dhudmessage(0, "%L", LANG_PLAYER, "FLOORLAVA_LAVA_RISING");

  UpdateLavaSpeed();

  CheckWinConditions();
}

public Round_OnEnd() {
  g_bGameInProgress = false;

  UpdateLavaSpeed();

  Asset_PlayClientSound(0, ASSET_LIBRARY, ASSET(RoundEndSound));
}

public Round_OnExpired() {
  g_bRoundExpired = true;
  UpdateLavaSpeed();
}

public Round_CheckResult:Round_OnCanStartCheck() {
  new iPlayersNum = 0;

  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (!is_user_connected(pPlayer)) continue;
    new iTeam = get_ent_data(pPlayer, "CBasePlayer", "m_iTeam");
    if (iTeam != 1 && iTeam != 2) continue;

    iPlayersNum++;
  }

  return iPlayersNum > 0 ? Round_CheckResult_Continue : Round_CheckResult_Supercede;
}

public Round_CheckResult:Round_OnCheckWinConditions() {
  return Round_CheckResult_Supercede;
}

RequestWinConditionsCheck() {
  remove_task(TASKID_CHECKWINCONDITIONS);
  set_task(0.1, "Task_CheckWinConditions", TASKID_CHECKWINCONDITIONS);
}

/*--------------------------------[ Player Methods ]--------------------------------*/

@Player_GetLastToucher(const &this) {
  if (!g_rgpPlayerToucher[this]) return 0;
  if (g_flGameTime - g_rgflPlayerToucherTime[this] >= 5.0) return 0;
  if (!rg_is_player_can_takedamage(this, g_rgpPlayerToucher[this])) return 0;

  return g_rgpPlayerToucher[this];
}

@Player_AddMoney(const &this, iAmount) {
  cs_set_user_money(this, min(cs_get_user_money(this) + iAmount, g_iMaxMoney));
}

/*--------------------------------[ Lava Methods ]--------------------------------*/

@Lava_Create() {
  new pLava = CE_Create(ENTITY(Lava), Float:{0.0, 0.0, -8192.0}, false);
  dllfunc(DLLFunc_Spawn, pLava);

  return pLava;
}

/*--------------------------------[ GasCloud Methods ]--------------------------------*/

@GasCloud_Create() {
  new pGas = CE_Create(ENTITY(GasCloud), Float:{0.0, 0.0, 8192.0}, false);
  dllfunc(DLLFunc_Spawn, pGas);

  return pGas;
}

/*--------------------------------[ Functions ]--------------------------------*/

CheckWinConditions(pIgnorePlayer = 0) {
  if (!g_bGameInProgress) return;

  new iAliveTPlayersNum = 0;
  new iAliveCTPlayersNum = 0;
  // new iTPlayersNum = 0;
  // new iCTPlayersNum = 0;
  new iPlayersNum = 0;
  
  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (pPlayer == pIgnorePlayer) continue;
    if (!is_user_connected(pPlayer)) continue;

    new iTeam = get_ent_data(pPlayer, "CBasePlayer", "m_iTeam");

    switch (iTeam) {
        case 1: {
        iPlayersNum++;
        // iTPlayersNum++;
        if (is_user_alive(pPlayer)) iAliveTPlayersNum++;
      }
      case 2: {
        iPlayersNum++;
        // iCTPlayersNum++;
        if (is_user_alive(pPlayer)) iAliveCTPlayersNum++;
      }
    }
  }

  if (!iPlayersNum) return;
  if (iPlayersNum == iAliveTPlayersNum + iAliveCTPlayersNum) return;

  if (g_bFreeForAll) {
    if (iAliveTPlayersNum + iAliveCTPlayersNum < 2) {
      new pWinner = FindAlivePlayer();

      if (pWinner) {
        ExecuteHamB(Ham_AddPoints, pWinner, 10, false);
        @Player_AddMoney(pWinner, 2000);
        client_print(0, print_center, "%L", LANG_PLAYER, "FLOORLAVA_PLAYER_WIN", pWinner);
        client_print_color(0, print_team_grey, "%s %L", FLOORLAVA_CHAT_PREFIX, LANG_PLAYER, "FLOORLAVA_PLAYER_WIN_CHAT", pWinner);
      } else {
        client_print(0, print_center, "%L", LANG_PLAYER, "FLOORLAVA_ROUND_DRAW");
        client_print_color(0, print_team_grey, "%s %L", FLOORLAVA_CHAT_PREFIX, LANG_PLAYER, "FLOORLAVA_ROUND_DRAW_CHAT");
      }

      Round_DispatchWin(3);
    }
  } else {
    new iWinnerTeam = 0;

    if (iAliveTPlayersNum || iAliveCTPlayersNum) {
      if (!iAliveTPlayersNum) {
        iWinnerTeam = 2;
      } else if (!iAliveCTPlayersNum) {
        iWinnerTeam = 1;
      }
    } else {
      iWinnerTeam = 3;
    }

    if (iWinnerTeam) {
      switch (iWinnerTeam) {
        case 1: client_print_color(0, print_team_red, "%s %L", FLOORLAVA_CHAT_PREFIX, LANG_PLAYER, "FLOORLAVA_TEAM_WIN_CHAT", LANG_PLAYER, "TERRORISTS");
        case 2: client_print_color(0, print_team_blue, "%s %L", FLOORLAVA_CHAT_PREFIX, LANG_PLAYER, "FLOORLAVA_TEAM_WIN_CHAT", LANG_PLAYER, "CTS");
        case 3: client_print_color(0, print_team_grey, "%s %L", FLOORLAVA_CHAT_PREFIX, LANG_PLAYER, "FLOORLAVA_ROUND_DRAW_CHAT");
      }

      Round_DispatchWin(iWinnerTeam);
    }

    for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
      if (!is_user_connected(pPlayer)) continue;

      new iTeam = get_ent_data(pPlayer, "CBasePlayer", "m_iTeam");
      if (iTeam != 1 && iTeam != 2) continue;

      @Player_AddMoney(pPlayer, iTeam == iWinnerTeam ? 2000 : 1000);
    }
  }
}

UpdateLavaSpeed() {
  if (g_pLava == FM_NULLENT) return;

  if (g_bGameInProgress) {
    if (!g_bRoundExpired) {
      CE_SetMember(g_pLava, FloorLava_Entity_Lava_Member_flSpeed, g_flLavaSpeed);
      CE_SetMember(g_pGasCloud, FloorLava_Entity_GasCloud_Member_flSpeed, g_flLavaSpeed);
    } else {
      CE_SetMember(g_pLava, FloorLava_Entity_Lava_Member_flSpeed, g_flLavaSpeed * 10.0);
      CE_SetMember(g_pGasCloud, FloorLava_Entity_GasCloud_Member_flSpeed, g_flLavaSpeed * 10.0);
    }
  } else {
    CE_SetMember(g_pLava, FloorLava_Entity_Lava_Member_flSpeed, 0.0);
    CE_SetMember(g_pGasCloud, FloorLava_Entity_GasCloud_Member_flSpeed, 0.0);
  }
}

HotSurfaceThink() {
  static const Float:flHeatRange = 32.0;

  static Float:vecLavaOrigin[3]; pev(g_pLava, pev_origin, vecLavaOrigin);

  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (!is_user_alive(pPlayer)) continue;
    if (~pev(pPlayer, pev_flags) & FL_ONGROUND) continue;
    if (pev(pPlayer, pev_waterlevel)) continue;

    static Float:vecPlayerAbsMin[3]; pev(pPlayer, pev_absmin, vecPlayerAbsMin);
    static Float:flDistanceToLava; flDistanceToLava = floatmax(vecPlayerAbsMin[2] - vecLavaOrigin[2], 0.0);

    if (flDistanceToLava > flHeatRange) continue;

    if (g_rgflPlayerNextBrun[pPlayer] <= g_flGameTime) {
      ExecuteHamB(Ham_TakeDamage, pPlayer, 0, 0, 10.0 * (flDistanceToLava / flHeatRange), DMG_SLOWBURN);
      g_rgflPlayerNextBrun[pPlayer] = g_flGameTime + 1.0;
    }
  }
}

FindAlivePlayer(iStart = 1) {
  for (new pPlayer = iStart; pPlayer <= MaxClients; ++pPlayer) {
    if (is_user_alive(pPlayer)) return pPlayer;
  }

  return 0;
}

/*--------------------------------[ Tasks ]--------------------------------*/

public Task_CheckWinConditions() {
  CheckWinConditions();
}

public Task_Update() {
  UpdateLavaSpeed();
  HotSurfaceThink();
}
