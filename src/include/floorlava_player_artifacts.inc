#if defined _floorlava_artifacts_included
  #endinput
#endif
#define _floorlava_artifacts_included

#pragma reqlib floorlava_artifacts

/*--------------------------------[ Natives ]--------------------------------*/

/**
 * Registers a new artifact type.
 * 
 * @param szId              Artifact identifier
 * @param szActivateFunc    Function to call when artifact is activated
 * @param szDeactivateFunc  Function to call when artifact is deactivated
 * @return                  Artifact handle (internal ID)
 */
native FloorLava_PlayerArtifact_Register(const szId[], const szActivateFunc[], const szDeactivateFunc[]);

/**
 * Checks if an artifact is registered.
 * 
 * @param szId    Artifact identifier
 * @return        true if artifact is registered, false otherwise
 */
native bool:FloorLava_PlayerArtifact_IsRegistered(const szId[]);

/**
 * Gets the internal handle for an artifact by its ID.
 * 
 * @param szId    Artifact identifier
 * @return        Artifact handle, or -1 if not found
 */
native FloorLava_PlayerArtifact_GetHandle(const szId[]);

/**
 * Gives an artifact to a player.
 * 
 * @param pPlayer   Player entity index
 * @param szId      Artifact identifier
 * @return          true if artifact was given, false otherwise
 */
native bool:FloorLava_PlayerArtifact_Give(const pPlayer, const szId[]);

/**
 * Removes an artifact from a player.
 * 
 * @param pPlayer   Player entity index
 * @param szId      Artifact identifier
 * @return          true if artifact was removed, false otherwise
 */
native bool:FloorLava_PlayerArtifact_Take(const pPlayer, const szId[]);

/**
 * Removes an artifact from a specific slot.
 * 
 * @param pPlayer   Player entity index
 * @param iSlot     Artifact slot index
 * @return          true if artifact was removed, false otherwise
 */
native bool:FloorLava_PlayerArtifact_TakeBySlot(const pPlayer, const iSlot);

/**
 * Removes all artifacts from a player.
 * 
 * @param pPlayer   Player entity index
 * @return          true if artifacts were removed
 */
native bool:FloorLava_PlayerArtifact_TakeAll(const pPlayer);

/**
 * Checks if a player has a specific artifact.
 * 
 * @param pPlayer   Player entity index
 * @param szId      Artifact identifier
 * @return          true if player has the artifact, false otherwise
 */
native bool:FloorLava_PlayerArtifact_Has(const pPlayer, const szId[]);

/**
 * Finds the next artifact a player has, starting from an offset.
 * 
 * @param pPlayer   Player entity index
 * @param iOffset   Starting offset (-1 for first artifact)
 * @param szId      Buffer to store artifact ID
 * @param iLen      Maximum length of buffer
 * @return          Next slot index, or -1 if no more artifacts found
 */
native FloorLava_PlayerArtifact_Find(const pPlayer, const iOffset, szId[], const iLen);
