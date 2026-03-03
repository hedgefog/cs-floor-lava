#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>

#include <api_assets>

#include <floorlava_player_artifacts>
#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ARTIFACT_ID ARTIFACT(ThermalSuit)
#define ARTIFACT_STATUS_ICON "suit_full"

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  FloorLava_PlayerArtifact_Register(ARTIFACT_ID, "Callback_Artifact_Activated", "Callback_Artifact_Deactivated");
}

public plugin_init() {
  register_plugin(ARTIFACT_PLUGIN(ThermalSuit), FLOORLAVA_VERSION, "Hedgehog Fog");

  RegisterHamPlayer(Ham_TakeDamage, "HamHook_Player_TakeDamage", .Post = 0);

  register_event("ResetHUD", "Event_ResetHUD", "b");
}

/*--------------------------------[ Callbacks ]--------------------------------*/

public Callback_Artifact_Activated(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

public Callback_Artifact_Deactivated(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

/*--------------------------------[ Hooks ]--------------------------------*/

public Event_ResetHUD(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

public HamHook_Player_TakeDamage(const pPlayer, const pInflictor, const pAttacker, Float:flDamage, iDamageBits) {
  if (!FloorLava_PlayerArtifact_Has(pPlayer, ARTIFACT_ID)) return HAM_IGNORED;

  if (iDamageBits & DMG_SLOWBURN) {
    SetHamParamFloat(4, 0.0);
    return HAM_SUPERCEDE;
  }

  return HAM_HANDLED;
}

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
