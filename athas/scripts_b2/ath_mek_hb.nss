// ath_mek_hb — OnHeartbeat живого мекиллота (карточка 14).
// Вода на земле от ATH_MEK_LURE кварт — идёт пить и ~2 минуты не возвращается.
// Иначе стережёт пруд: нападает на любого ближе ATH_MEK_GUARD_DIST к ATH_WP_POOL.

#include "ath_inc_b2"

void AthMekDrink()
{
    object oArea = GetArea(OBJECT_SELF);
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && AthQuartsIn(oObject) > 0
            && !GetIsObjectValid(GetItemPossessor(oObject)))
            DestroyObject(oObject);
        oObject = GetNextObjectInArea(oArea);
    }
}

void main()
{
    object oMek = OBJECT_SELF;
    int nBeats = GetLocalInt(oMek, "ATH_DRINK_BEATS");
    if (nBeats > 0)
    {
        SetLocalInt(oMek, "ATH_DRINK_BEATS", nBeats - 1);
        return;
    }

    // Приманка: вода, лежащая на земле.
    object oArea = GetArea(oMek);
    int nQuarts = 0;
    object oBait = OBJECT_INVALID;
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && !GetIsObjectValid(GetItemPossessor(oObject)))
        {
            int nIn = AthQuartsIn(oObject);
            if (nIn > 0)
            {
                nQuarts += nIn;
                oBait = oObject;
            }
        }
        oObject = GetNextObjectInArea(oArea);
    }
    if (nQuarts >= ATH_MEK_LURE)
    {
        ChangeToStandardFaction(oMek, STANDARD_FACTION_COMMONER);
        ClearAllActions(TRUE);
        ActionMoveToObject(oBait, FALSE, 2.0);
        ActionDoCommand(AthMekDrink());
        SetLocalInt(oMek, "ATH_DRINK_BEATS", ATH_MEK_DRINK_BEATS);
        AthTextToPCsIn(oArea, ATH_TXT2_MEK_LURE);
        return;
    }

    // Охрана пруда.
    object oPool = GetWaypointByTag(ATH_WP_POOL);
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, oPool);
    if (GetIsObjectValid(oPC) && GetArea(oPC) == oArea && GetDistanceBetween(oPC, oPool) < ATH_MEK_GUARD_DIST)
    {
        ChangeToStandardFaction(oMek, STANDARD_FACTION_HOSTILE);
        if (GetAttackTarget(oMek) != oPC)
            ActionAttack(oPC);
        return;
    }
    if (!GetIsInCombat(oMek))
    {
        ChangeToStandardFaction(oMek, STANDARD_FACTION_COMMONER);
        object oHome = GetWaypointByTag(ATH_WP_MEK_HOME);
        if (GetDistanceBetween(oMek, oHome) > 3.0)
            ActionMoveToObject(oHome);
    }
}
