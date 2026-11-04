// ath_inc_aara — исход сцены с ааракокрами (карточка 8).

#include "ath_inc_b2"

// Если в локации не осталось ни одной ааракокры, а водонос жив — он спасён:
// умирает сам, но восковой шар цел.
void AthAaraCheck(object oArea)
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, "ATH_B8_DONE"))
        return;
    object oWezer = OBJECT_INVALID;
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsDead(oObject))
        {
            if (AthTagStarts(oObject, ATH_TAG_AARA) && !GetLocalInt(oObject, "ATH_FLED"))
                return;
            if (GetTag(oObject) == ATH_TAG_WZ_FETCH)
                oWezer = oObject;
        }
        oObject = GetNextObjectInArea(oArea);
    }
    if (!GetIsObjectValid(oWezer))
        return;
    SetLocalInt(oWezer, "ATH_RESCUED", 1);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oWezer);
}
