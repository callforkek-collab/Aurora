// ath_wax_honey — tag-based «Восковой шар с мёдом» (4 заряда). Раз в сутки +1d8 HP.

#include "x2_inc_switches"
#include "ath_inc_b2"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    int nDay = GetLocalInt(GetModule(), "ATH_DAYNUM") + 1;
    if (GetLocalInt(oUser, "ATH_HONEY_DAY") == nDay)
    {
        // Заряд уже списан движком — возвращаем его.
        object oItem = GetItemActivated();
        SetItemCharges(oItem, GetItemCharges(oItem) + 1);
        FloatingTextStringOnCreature(ATH_TXT2_HONEY_NO, oUser, FALSE);
    }
    else
    {
        SetLocalInt(oUser, "ATH_HONEY_DAY", nDay);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(d8()), oUser);
        FloatingTextStringOnCreature(ATH_TXT2_HONEY, oUser, FALSE);
    }
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
