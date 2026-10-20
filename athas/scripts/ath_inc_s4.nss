// ath_inc_s4 — жаждущие охранники (сцена 4): появление, уход, бой.

#include "ath_inc_thirst"

int AthIsThirsty(object oObject)
{
    return GetObjectType(oObject) == OBJECT_TYPE_CREATURE
        && GetStringLeft(GetTag(oObject), GetStringLength(ATH_TAG_THIRSTY)) == ATH_TAG_THIRSTY
        && !GetIsDead(oObject);
}

// Запускает сцену 4 для oPC (один раз за игру).
void AthSpawnThirsty(object oPC)
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_S4") || !GetLocalInt(oModule, "ATH_WAGON_BURNED"))
        return;
    SetLocalInt(oModule, "ATH_S4", 1);
    AthJournalAll(ATH_J_GUARDS);

    location lSpawn = GetLocation(GetWaypointByTag(ATH_WP_GUARDS));
    int i;
    for (i = 0; i < ATH_THIRSTY_GUARDS; i++)
        CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_THIRSTY, lSpawn);
    object oLeader = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_THIRSTY_L, lSpawn);
    AssignCommand(oLeader, ActionMoveToObject(oPC, TRUE, 3.0));
    AssignCommand(oLeader, ActionStartConversation(oPC, ATH_DLG_THIRSTY, FALSE, FALSE));
}

// До nCount охранников (кроме главаря) уходит; nCount < 0 — уходят все.
void AthThirstyLeave(object oArea, int nCount)
{
    object oExit = GetWaypointByTag(ATH_WP_GUARDS_EXIT);
    int nGone = 0;
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject) && (nCount < 0 || nGone < nCount))
    {
        if (AthIsThirsty(oObject) && (nCount < 0 || GetTag(oObject) != ATH_TAG_THIRSTY_L))
        {
            AssignCommand(oObject, ClearAllActions());
            AssignCommand(oObject, ActionMoveToObject(oExit, TRUE));
            DestroyObject(oObject, 30.0);
            nGone++;
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void AthThirstyFight(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (AthIsThirsty(oObject))
            ChangeToStandardFaction(oObject, STANDARD_FACTION_HOSTILE);
        oObject = GetNextObjectInArea(oArea);
    }
}
