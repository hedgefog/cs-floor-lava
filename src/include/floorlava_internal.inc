#if defined _floorlava_internal_included
  #endinput
#endif
#define _floorlava_internal_included

#include <floorlava_const>

/*--------------------------------[ Common Macros ]--------------------------------*/

#if !defined IS_PLAYER
  #define IS_PLAYER(%1) (%1 >= 1 && %1 <= MaxClients)
#endif

#if !defined BIT
  #define BIT(%1) (1 << (%1))
#endif

/*--------------------------------[ CVar & Command Macros ]--------------------------------*/

#define CVAR(%1) "floorlava_" + %1
#define COMMAND(%1) "floorlava_" + %1

/*--------------------------------[ Plugin Registration Macros ]--------------------------------*/

#define PLUGIN_NAME(%1) "[The Floor is Lava] " + %1
#define ENTITY_PLUGIN(%1) "[Entity] (The Floor is Lava) " + #%1
#define WEAPON_PLUGIN(%1) "[Weapon] (The Floor is Lava) " + #%1
#define ARTIFACT_PLUGIN(%1) "[The Floor is Lava] Artifact - " + #%1
#define SHOP_ITEM_PLUGIN(%1) "[The Floor is Lava] Shop Item - " + #%1
#define FEATURE_PLUGIN(%1) "[The Floor is Lava] " + %1

/*--------------------------------[ Namespace Macros ]--------------------------------*/

#define NAMESPACE(%1) FloorLava_%1
#define NAMESPACE_FIELD<%1>(%2) NAMESPACE(%1)_%2

/*--------------------------------[ Library Shortcuts ]--------------------------------*/

#define LIBRARY(%1) NAMESPACE_FIELD<Library>(%1)

/*--------------------------------[ Asset Shortcuts ]--------------------------------*/

#define ASSET_LIBRARY NAMESPACE(AssetLibrary)
#define ASSET(%1) NAMESPACE_FIELD<Asset>(%1)

/*--------------------------------[ Entity Shortcuts ]--------------------------------*/

#define ENTITY(%1) NAMESPACE_FIELD<Entity>(%1)
#define ENTITY_DATA<%1>(%2,%3) ENTITY(%2)_%1_%3
#define ENTITY_METHOD<%1>(%2) ENTITY_DATA<Method>(%1,%2)
#define ENTITY_MEMBER<%1>(%2) ENTITY_DATA<Member>(%1,%2)

/*--------------------------------[ Weapon Shortcuts ]--------------------------------*/

#define WEAPON(%1) NAMESPACE_FIELD<Weapon>(%1)
#define WEAPON_DATA<%1>(%2,%3) WEAPON(%2)_%1_%3
#define WEAPON_METHOD<%1>(%2) WEAPON_DATA<Method>(%1,%2)
#define WEAPON_MEMBER<%1>(%2) WEAPON_DATA<Member>(%1,%2)

/*--------------------------------[ Artifact Shortcuts ]--------------------------------*/

#define ARTIFACT(%1) NAMESPACE_FIELD<Artifact>(%1)

/*--------------------------------[ Shop Shortcuts ]--------------------------------*/

#define SHOP NAMESPACE(Shop)
#define SHOP_ITEM(%1) NAMESPACE_FIELD<ShopItem>(%1)

/*--------------------------------[ Dictionary Shortcuts ]--------------------------------*/

#define DICTIONARY NAMESPACE(Dictionary)
#define DICTIONARY_KEY(%1) NAMESPACE_FIELD<DictionaryKey>(%1)
