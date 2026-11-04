// ath_smoke — OnUsed места для костра у центрального купола (карточка 11).
// 4 вязанки: везеры, кроме королевы, покидают улей; у входа ждут солдаты; в туннелях дым.

#include "ath_inc_b2"

void AthSmokeEnd()
{
    SetLocalInt(GetModule(), "ATH_SMOKED", 0);
    AthTextToPCsIn(GetObjectByTag(ATH_TAG_AREA_HIVE), ATH_TXT2_SMOKE_END);
}

void main()
{
    object oPC = GetLastUsedBy();
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_SMOKE_USED"))
        return;
    int nFuel = AthCountTagged(oPC, ATH_TAG_FUEL);
    if (nFuel < ATH_FUEL_NEED)
    {
        FloatingTextStringOnCreature(ATH_TXT2_FUEL_NEED + IntToString(nFuel) + " / "
                                     + IntToString(ATH_FUEL_NEED), oPC, FALSE);
        return;
    }
    AthTakeTagged(oPC, ATH_TAG_FUEL, ATH_FUEL_NEED);
    SetLocalInt(oModule, "ATH_SMOKE_USED", 1);
    SetLocalInt(oModule, "ATH_SMOKED", 1);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SMOKE_PUFF), GetLocation(OBJECT_SELF));
    FloatingTextStringOnCreature(ATH_TXT2_SMOKE, oPC, FALSE);

    // Все везеры, кроме королевы, уходят из улья.
    object oHive = GetObjectByTag(ATH_TAG_AREA_HIVE);
    object oObject = GetFirstObjectInArea(oHive);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && AthTagStarts(oObject, ATH_TAG_WZ)
            && GetTag(oObject) != ATH_TAG_QUEEN)
            DestroyObject(oObject);
        oObject = GetNextObjectInArea(oHive);
    }

    // Солдаты встают у входа.
    location lDome = GetLocation(GetWaypointByTag(ATH_WP_DOME_C));
    int i;
    for (i = 0; i < ATH_SMOKE_GUARDS; i++)
    {
        object oSoldier = CreateObject(OBJECT_TYPE_CREATURE, ATH_RES_WZ_SOLD, lDome);
        AssignCommand(oSoldier, ActionAttack(oPC));
    }
    AssignCommand(oModule, DelayCommand(ATH_SMOKE_TIME, AthSmokeEnd()));
}
