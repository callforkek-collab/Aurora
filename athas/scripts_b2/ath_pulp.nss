// ath_pulp — tag-based «Мякоть кактуса»: сразу ATH_PULP_QUARTS к суточной норме.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    SetLocalInt(oUser, "ATH_DRUNK", GetLocalInt(oUser, "ATH_DRUNK") + ATH_PULP_QUARTS - 1);
    AthDrink(oUser);
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
