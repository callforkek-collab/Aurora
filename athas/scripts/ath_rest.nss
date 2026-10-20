// ath_rest — Module OnPlayerRest. Без половины нормы воды отдохнуть нельзя.
// Отдых в тени днём снимает утомление от жары и снижает норму воды вдвое.

#include "ath_inc_thirst"

void main()
{
    object oPC = GetLastPCRested();
    int nType = GetLastRestEventType();

    if (nType == REST_EVENTTYPE_REST_STARTED)
    {
        if (GetLocalInt(oPC, "ATH_DRUNK") * 2 < AthGetNeed(oPC))
        {
            AssignCommand(oPC, ClearAllActions());
            FloatingTextStringOnCreature(ATH_TXT_REST_THIRST, oPC, FALSE);
            return;
        }
    }
    else if (nType == REST_EVENTTYPE_REST_FINISHED)
    {
        int bShade = GetLocalInt(oPC, "ATH_IN_SHADE");
        if (bShade || !GetLocalInt(GetArea(oPC), "ATH_HOT"))
            AthRemoveTagged(oPC, "ATH_HEAT");
        if (bShade && GetIsDay() && !GetLocalInt(oPC, "ATH_HALF_NEED"))
        {
            SetLocalInt(oPC, "ATH_HALF_NEED", 1);
            SendMessageToPC(oPC, ATH_TXT_REST_SHADE);
        }
    }

    ExecuteScript("x2_mod_def_rest", OBJECT_SELF);
}
