// ath_s3_fire — поджог повозки (конец сцены 3). Выполняется на модуле.
// Дверь в L1 запирается навсегда, эльфы уходят, через ATH_BURN_TIME повозка становится пепелищем.

#include "ath_inc_thirst"

void AthSpawnAtAll(string sWaypointTag, string sResRef, string sNewTag = "")
{
    int i = 0;
    object oPoint = GetObjectByTag(sWaypointTag, i);
    while (GetIsObjectValid(oPoint))
    {
        CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, GetLocation(oPoint), FALSE, sNewTag);
        i++;
        oPoint = GetObjectByTag(sWaypointTag, i);
    }
}

void AthDestroyAll(string sTag)
{
    int i = 0;
    object oObject = GetObjectByTag(sTag, i);
    while (GetIsObjectValid(oObject))
    {
        DestroyObject(oObject);
        i++;
        oObject = GetObjectByTag(sTag, i);
    }
}

int AthAnyoneHasMap()
{
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetIsObjectValid(GetItemPossessedBy(oPC, ATH_TAG_MAP)))
            return TRUE;
        oPC = GetNextPC();
    }
    return FALSE;
}

// Повозка догорела: остов, тайник с находками и (если её никто не взял) карта капитана.
void AthBecomeWreck()
{
    AthDestroyAll(ATH_TAG_WAGON_PART);
    AthDestroyAll("ATH_FIRE");
    AthSpawnAtAll(ATH_WP_WRECK, ATH_RES_WRECK);

    object oCache = CreateObject(OBJECT_TYPE_PLACEABLE, ATH_RES_CACHE, GetLocation(GetWaypointByTag(ATH_WP_CACHE)));
    CreateItemOnObject(ATH_RES_CHARCOAL, oCache, 5);
    CreateItemOnObject(ATH_RES_SHARD, oCache);
    CreateItemOnObject(ATH_RES_SHARD, oCache);
    CreateItemOnObject(ATH_RES_GLASS, oCache);
    if (!AthAnyoneHasMap())
        CreateItemOnObject(ATH_RES_MAP, oCache);
    SetLocalInt(GetModule(), "ATH_WRECK_READY", 1);
}

void main()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_WAGON_BURNED"))
        return;
    SetLocalInt(oModule, "ATH_WAGON_BURNED", 1);

    object oDoor = GetObjectByTag(ATH_TAG_WAGON_DOOR);
    AssignCommand(oDoor, ActionCloseDoor(oDoor));
    SetLocked(oDoor, TRUE);

    AthSpawnAtAll(ATH_WP_FIRE, ATH_RES_FLAME, "ATH_FIRE");
    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == GetArea(oDoor))
            FloatingTextStringOnCreature(ATH_TXT_FIRE, oPC, FALSE);
        oPC = GetNextPC();
    }

    // Мирные эльфы уходят за край карты.
    if (!GetLocalInt(oModule, "ATH_ELVES_HOSTILE"))
    {
        object oExit = GetWaypointByTag(ATH_WP_ELF_EXIT);
        object oArea = GetArea(oDoor);
        object oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE
                && GetStringLeft(GetTag(oObject), GetStringLength(ATH_TAG_ELF)) == ATH_TAG_ELF)
            {
                AssignCommand(oObject, ClearAllActions());
                AssignCommand(oObject, ActionMoveToObject(oExit, TRUE));
                DestroyObject(oObject, 25.0);
            }
            oObject = GetNextObjectInArea(oArea);
        }
    }

    DelayCommand(ATH_BURN_TIME, AthBecomeWreck());
}
