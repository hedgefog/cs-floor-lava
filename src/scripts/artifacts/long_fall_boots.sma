#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#tryinclude <reapi>

#include <api_assets>

#include <floorlava_player_artifacts>
#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ARTIFACT_ID ARTIFACT(LongFallBoots)
#define ARTIFACT_STATUS_ICON "item_battery"

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  FloorLava_PlayerArtifact_Register(ARTIFACT_ID, "Callback_Artifact_Activated", "Callback_Artifact_Deactivated");
}

public plugin_init() {
  register_plugin(ARTIFACT_PLUGIN(LongFallBoots), FLOORLAVA_VERSION, "Hedgehog Fog");

  #if defined _reapi_included
    RegisterHookChain(RG_CSGameRules_FlPlayerFallDamage, "HC_GameRules_PlayerFallDamage");
  #else
    RegisterHamPlayer(Ham_TakeDamage, "HamHook_Player_TakeDamage", .Post = 0);
  #endif

  register_event("ResetHUD", "Event_ResetHUD", "b");
}

/*--------------------------------[ Callbacks ]--------------------------------*/

public Callback_Artifact_Activated(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

public Callback_Artifact_Deactivated(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

/*--------------------------------[ Events ]--------------------------------*/

public Event_ResetHUD(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

#if defined _reapi_included
  public HC_GameRules_PlayerFallDamage(const pPlayer) {
    if (FloorLava_PlayerArtifact_Has(pPlayer, ARTIFACT_ID)) {
      SetHookChainReturn(ATYPE_FLOAT, 0.0);
      return HC_SUPERCEDE;
    }

    return HC_CONTINUE;
  }
#else
  public HamHook_Player_TakeDamage(const pPlayer, const pInflictor, const pAttacker, Float:flDamage, iDamageBits) {
    if (!FloorLava_PlayerArtifact_Has(pPlayer, ARTIFACT_ID)) return HAM_IGNORED;

    if (iDamageBits & DMG_FALL) {
      SetHamParamFloat(4, 0.0);
      return HAM_SUPERCEDE;
    }

    return HAM_HANDLED;
  }
#endif

/*--------------------------------[ Methods ]--------------------------------*/

@Player_UpdateStatusIcon(const &this) {
  static gmsgStatusIcon = 0;
  if (!gmsgStatusIcon) {
    gmsgStatusIcon = get_user_msgid("StatusIcon");
  }

  if (FloorLava_PlayerArtifact_Has(this, ARTIFACT_ID)) {
    message_begin(MSG_ONE, gmsgStatusIcon, _, this);
    write_byte(1);
    write_string(ARTIFACT_STATUS_ICON);
    write_byte(180);
    write_byte(80);
    write_byte(40);
    message_end();
  } else {
    message_begin(MSG_ONE, gmsgStatusIcon, _, this);
    write_byte(0);
    write_string(ARTIFACT_STATUS_ICON);
    message_end();
  }
}
