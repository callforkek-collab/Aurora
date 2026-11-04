// ath_camp_out — OnExit триггера лагеря. За его пределами охрана не преследует.

#include "ath_inc_b2"

void main()
{
    object oPC = GetExitingObject();
    DeleteLocalInt(oPC, "ATH_IN_CAMP");
    if (!GetLocalInt(GetModule(), "ATH_CAMP_ALARM"))
        return;
    object oArea = GetArea(OBJECT_SELF);
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && AthTagStarts(oObject, ATH_TAG_CAMP)
            && GetAttackTarget(oObject) == oPC)
            AssignCommand(oObject, ClearAllActions(TRUE));
        oObject = GetNextObjectInArea(oArea);
    }
}
