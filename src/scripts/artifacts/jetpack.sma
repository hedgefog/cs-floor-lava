#pragma semicolon 1

#include <amxmodx>
#include <hamsandwich>
#include <fakemeta>
#tryinclude <reapi>

#include <api_assets>
#include <api_player_cosmetics>

#include <floorlava_player_artifacts>
#include <floorlava_internal>

/*--------------------------------[ Constants ]--------------------------------*/

#define ARTIFACT_ID ARTIFACT(JetPack)
#define ARTIFACT_STATUS_ICON "item_longjump"

#define JETPACK_CAPACITY 1000.0
#define JETPACK_BURST_CONSUMPTION 8.0
#define JETPACK_POWER 120.0
#define JETPACK_BURST_RATE 0.1
#define JETPACK_BURST_SOUND_DURATION 0.5

/*--------------------------------[ Plugin State ]--------------------------------*/

new Float:g_flGameTime = 0.0;

/*--------------------------------[ Player State ]--------------------------------*/

new Float:g_rgflPlayerCharge[MAX_PLAYERS + 1];
new Float:g_rgflPlayerNextBurst[MAX_PLAYERS + 1];
new Float:g_rgflPlayerNextBurstSound[MAX_PLAYERS + 1];

/*--------------------------------[ Plugin Initialization ]--------------------------------*/

public plugin_precache() {
  Asset_Precache(ASSET_LIBRARY, ASSET(JetPackPlayerModel));
  Asset_Precache(ASSET_LIBRARY, ASSET(JetPackFlameBurstSound));
  Asset_Precache(ASSET_LIBRARY, ASSET(JetPackAirBurstSound));

  FloorLava_PlayerArtifact_Register(ARTIFACT_ID, "Callback_Artifact_Activated", "Callback_Artifact_Deactivated");
}

public plugin_init() {
  register_plugin(ARTIFACT_PLUGIN(JetPack), FLOORLAVA_VERSION, "Hedgehog Fog");

  RegisterHamPlayer(Ham_Player_Jump, "HamHook_Player_Jump_Post", .Post = 1);

  register_event("ResetHUD", "Event_ResetHUD", "b");
}

public server_frame() {
  g_flGameTime = get_gametime();
}

/*--------------------------------[ Callbacks ]--------------------------------*/

public Callback_Artifact_Activated(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
  PlayerCosmetic_Equip(pPlayer, Asset_GetModelIndex(ASSET_LIBRARY, ASSET(JetPackPlayerModel)));
  g_rgflPlayerCharge[pPlayer] = JETPACK_CAPACITY;
}

public Callback_Artifact_Deactivated(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
  PlayerCosmetic_Unequip(pPlayer, Asset_GetModelIndex(ASSET_LIBRARY, ASSET(JetPackPlayerModel)));
}

/*--------------------------------[ Round Forwards ]--------------------------------*/

public Round_OnInit() {
  for (new pPlayer = 1; pPlayer <= MaxClients; ++pPlayer) {
    if (!is_user_connected(pPlayer)) continue;
    if (!FloorLava_PlayerArtifact_Has(pPlayer, ARTIFACT_ID)) continue;

    g_rgflPlayerCharge[pPlayer] = JETPACK_CAPACITY;
  }
}

/*--------------------------------[ Hooks ]--------------------------------*/

public Event_ResetHUD(const pPlayer) {
  @Player_UpdateStatusIcon(pPlayer);
}

public HamHook_Player_Jump_Post(const pPlayer) {
  if (!FloorLava_PlayerArtifact_Has(pPlayer, ARTIFACT_ID)) return HAM_IGNORED;

  if (pev(pPlayer, pev_flags) & FL_ONGROUND) {
    g_rgflPlayerNextBurst[pPlayer] = g_flGameTime + 0.25;
    return HAM_HANDLED;
  }

  if (g_rgflPlayerNextBurst[pPlayer] < g_flGameTime) {
    static Float:flOldCharge; flOldCharge = g_rgflPlayerCharge[pPlayer];
    
    if (g_rgflPlayerCharge[pPlayer]) {
      static Float:vecOrigin[3]; pev(pPlayer, pev_origin, vecOrigin);
      static Float:vecAngles[3]; pev(pPlayer, pev_angles, vecAngles);
      static Float:vecForward[3]; angle_vector(vecAngles, ANGLEVECTOR_FORWARD, vecForward);

      static Float:flCost; flCost = floatmin(JETPACK_BURST_CONSUMPTION, g_rgflPlayerCharge[pPlayer]);
      static Float:flPower; flPower = JETPACK_POWER * (flCost / JETPACK_BURST_CONSUMPTION);

      static Float:vecVelocity[3]; pev(pPlayer, pev_velocity, vecVelocity);
      vecVelocity[2] += flPower;
      set_pev(pPlayer, pev_velocity, vecVelocity);

      static iModelIndex; iModelIndex = engfunc(EngFunc_ModelIndex, "sprites/bexplo.spr");

      engfunc(EngFunc_MessageBegin, MSG_PAS, SVC_TEMPENTITY, vecOrigin, 0);
      write_byte(TE_EXPLOSION);
      engfunc(EngFunc_WriteCoord, (vecOrigin[0]) + (vecForward[0] * -16.0));
      engfunc(EngFunc_WriteCoord, (vecOrigin[1]) + (vecForward[1] * -16.0));
      engfunc(EngFunc_WriteCoord, (vecOrigin[2] - 16.0) + (vecForward[2] * -16.0));
      write_short(iModelIndex);
      write_byte(10 + random(10));
      write_byte(10);
      write_byte(TE_EXPLFLAG_NODLIGHTS | TE_EXPLFLAG_NOSOUND | TE_EXPLFLAG_NOPARTICLES);
      message_end();

      g_rgflPlayerCharge[pPlayer] = floatmax(g_rgflPlayerCharge[pPlayer] - JETPACK_BURST_CONSUMPTION, 0.0);
    }

    g_rgflPlayerNextBurst[pPlayer] = g_flGameTime + JETPACK_BURST_RATE;

    if (g_rgflPlayerNextBurstSound[pPlayer] < g_flGameTime) {
      if (g_rgflPlayerCharge[pPlayer]) {
        Asset_EmitSound(pPlayer, CHAN_STATIC, ASSET_LIBRARY, ASSET(JetPackFlameBurstSound));
        g_rgflPlayerNextBurstSound[pPlayer] = g_flGameTime + JETPACK_BURST_SOUND_DURATION;
      } else {
        Asset_EmitSound(pPlayer, CHAN_ITEM, ASSET_LIBRARY, ASSET(JetPackAirBurstSound));
        g_rgflPlayerNextBurstSound[pPlayer] = g_flGameTime + 1.0;
      }
    }

    if (flOldCharge != g_rgflPlayerCharge[pPlayer]) {
      if ((g_rgflPlayerCharge[pPlayer] / JETPACK_CAPACITY) <= 0.1 && (flOldCharge / JETPACK_CAPACITY) > 0.1) {
        client_cmd(pPlayer, "spk ^"fvox/warning power_level_is ten percent^"");
      }
    }
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
