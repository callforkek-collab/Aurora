// ath_boiled_bad — tag-based «Выпаренная вода» (неудачная): выглядит так же, но яд остался.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    AthDrink(oUser);
    if (GetRacialType(oUser) != RACIAL_TYPE_ELF)
        AssignCommand(oUser, DelayCommand(ATH_POOL_ONSET, AthPoolPoison(oUser)));
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
