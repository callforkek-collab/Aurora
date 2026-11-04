// ath_boiled — tag-based «Выпаренная вода» (удачная): обычная кварта.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    AthDrink(GetItemActivator());
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
