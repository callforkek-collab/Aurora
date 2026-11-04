// ath_yypr — tag-based «Хвоя ипра» (Single Use): чай. Действует при следующем полном отдыхе.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    SetLocalInt(oUser, "ATH_TEA", 1);
    FloatingTextStringOnCreature(ATH_TXT2_TEA, oUser, FALSE);
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
