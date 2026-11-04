// ath_wax_water — tag-based «Восковой шар с водой» (4 заряда = 4 кварты).

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    AthDrink(GetItemActivator());
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
