// ath_thorns_pull — tag-based скрипт предмета «Шипы тимириса» (тег ath_thorns_pull).
// Шаблон: Cast Spell: Unique Power Self Only (Single Use). Вытащить шипы: ещё 2 урона, кровотечение прекращается.

#include "x2_inc_switches"
#include "ath_inc_s6"

void main()
{
    if (GetUserDefinedItemEventNumber() != X2_ITEM_EVENT_ACTIVATE)
        return;
    object oUser = GetItemActivator();
    if (GetLocalInt(oUser, "ATH_THORNS") > 0)
    {
        DeleteLocalInt(oUser, "ATH_THORNS");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(2, DAMAGE_TYPE_PIERCING), oUser);
        FloatingTextStringOnCreature(ATH_TXT_THORNS_OUT, oUser, FALSE);
    }
    SetExecutedScriptReturnValue(X2_EXECUTE_SCRIPT_END);
}
