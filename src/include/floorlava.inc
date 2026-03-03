#if defined _floorlava_included
  #endinput
#endif
#define _floorlava_included

#include <floorlava_const>

#pragma reqlib floorlava

/*--------------------------------[ Natives ]--------------------------------*/

/**
 * Checks if the game is currently in Free For All mode.
 * 
 * @return          true if FFA mode is active, false otherwise
 */
native bool:FloorLava_IsFreeForAll();

/**
 * Checks if the game is currently in progress.
 * 
 * @return          true if game is in progress, false otherwise
 */
native bool:FloorLava_IsGameInProgress();

/**
 * Triggers a check of the win conditions.
 */
native FloorLava_CheckWinConditions();

native bool:FloorLava_CanPlayerTakeDamage(const pPlayer, const pAttacker);

/*--------------------------------[ Forwards ]--------------------------------*/

/**
 * Called when the plugin configuration has finished loading.
 */
forward FloorLava_OnConfigLoaded();

/**
 * Called when a player is burned out by lava.
 * 
 * @param pPlayer   Player entity index
 */
forward FloorLava_OnPlayerBurnedOut(const pPlayer);
